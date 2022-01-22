
require 'linkeddata'


DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
BS = RDF::Vocabulary.new("http://rdf.biosemantics.org/ontologies/fdp-o#")

class DCATResource
    attr_accessor :baseURI
    attr_accessor :parentURI
    attr_accessor :accessRights, :conformsTo, :contactName, :contactEmail, :creator,:title,:description,:release_date,:modification_date,
    :publisher,:identifier,:license, :language
    attr_accessor :dataset,:keyword,:landingPage,:qualifiedRelation,:theme,:service,:themeTaxonomy,:homepage 
    attr_accessor :types
    attr_accessor :g  # the graph


    def initialize(types: [DCAT.Resource], baseURI: "http://example.org", parentURI: "http://example.org.parent", accessRights: nil, conformsTo: nil, 
        contactEmail: nil,contactName: nil, creator: nil, 
        title: nil, description: nil, issued: nil, modified: nil, publisher: nil, identifier: nil, license: nil, language: "http://id.loc.gov/vocabulary/iso639-1/en", 
        dataset: nil, keyword: nil, landingPage: nil, qualifiedRelation: nil, theme: nil,
        service: nil, themeTaxonomy: nil, homepage: nil, 
        **args )

        @accessRights = accessRights
        @conformsTo = conformsTo
        @contactName = contactName
        @contactEmail = contactEmail
#        @resource_creator = resource_creator
        @title = title
        @description = description
        @issued = issued
        @modified = modified
        @publisher = publisher
        @identifier = identifier
        @license = license
        @language = language

        @dataset = dataset
        @keyword = keyword
        @landingPage = landingPage
        @qualifiedRelation = qualifiedRelation
        @theme = theme
        @service = service
        @themeTaxonomy = themeTaxonomy
        @homepage = homepage

        @baseURI = RDF::URI(baseURI)
        @parentURI = RDF::URI(parentURI)
        @types = types

        @g = RDF::Graph.new()
    end
    
    def build()
        
        self.types.each do |type|
            self.g << [self.baseURI, RDF.type, type]
        end
        
        self.g << [self.baseURI, RDF::Vocab::RDFS.label, @title] if @title
        self.g << [self.baseURI, RDF::Vocab::DC.isPartOf, @parentURI] if @parentURI

        #DCAT
        %w[dataset keyword landingPage qualifiedRelation theme service themeTaxonomy].each do |f|
            (pred, value) = get_pred_value(f, "DCAT")
            next unless pred and value
            self.g << [self.baseURI, pred, value]
        end

        #DCT
        %w[accessRights conformsTo title description identifier license language creator].each do |f|
            (pred, value) = get_pred_value(f, "DCT")
            next unless pred and value
            self.g << [self.baseURI, pred, value]
        end
        %w[issued modified].each do |f|
            (pred, value) = get_pred_value(f, "DCT", "TIME")
            next unless pred and value
            self.g << [self.baseURI, pred, value]
            self.g << [self.baseURI, BS.issued, value]
            self.g << [self.baseURI, BS.modified, value]
            
        end

        #FOAF
        %w[homepage].each do |f|
            (pred, value) = get_pred_value(f, "FOAF")
            next unless pred and value
            self.g << [self.baseURI, pred, value]
        end

        # COMPLEX

        #identifier 
        # contactPoint
        if @contactEmail or @contactName
            bnode = RDF::Node.new()
            self.g << [self.baseURI, DCAT.contactPoint, bnode]
            self.g << [bnode, RDF.type, RDF::URI.new("http://www.w3.org/2006/vcard/ns#Individual")]
            self.g << [bnode, RDF::URI.new("http://www.w3.org/2006/vcard/ns#fn"), @contactName] if @contactName
            self.g << [bnode, RDF::URI.new("http://www.w3.org/2006/vcard/ns#hasEmail"), @contactEmail] if @contactEmail
        end
            
        #publisher
        if @publisher
            bnode = RDF::Node.new()
            self.g << [self.baseURI, RDF::Vocab::DC.publisher, bnode]
            self.g << [bnode, RDF.type, FOAF.Agent]
            self.g << [bnode, FOAF.name, @publisher]
        end
  
        #accessRights
        if @accessRights
            self.g << [self.baseURI, RDF::Vocab::DC.accessRights, RDF::URI.new(@accessRights)]
            self.g << [RDF::URI.new(@accessRights), RDF.type, RDF::Vocab::DC.rightsStatement]
        end
    end

    def serialize(format: :turtle)
            puts @g.dump(:turtle)
    end

    def get_pred_value(pred, vocab, datatype = nil)
        urire = Regexp.new("((http|https)://)(www.)?[a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,8}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)")
        sym = '@'+pred
        case vocab
        when "DCT"
            pred = RDF::Vocab::DC[pred]
        when "DCAT"
            pred = DCAT[pred]
        when "FOAF"
            pred = FOAF[pred]
        end

        thisvalue = self.instance_variable_get(sym)
        return [nil,nil] unless thisvalue
        if datatype == "TIME"
            now = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
            value = RDF::Literal.new(thisvalue, datatype: RDF::URI("http://www.w3.org/2001/XMLSchema#dateTime"))
            if !(value.valid?)
                value = RDF::Literal.new(thisvalue, datatype: RDF::URI("http://www.w3.org/2001/XMLSchema#date"))
                if !(value.valid?)
                    RDF::Literal.new(now, datatype: RDF::URI("http://www.w3.org/2001/XMLSchema#dateTime"))
                end
            end                
        elsif urire.match(thisvalue)
            value = RDF::URI.new(thisvalue)
        end
        return [pred, value]
    end

end


# %w() array of strings
# %r() regular expression.
# %q() string
# %x() a shell command (returning the output string)
# %i() array of symbols (Ruby >= 2.0.0)
# %s() symbol
# %() (without letter) shortcut for %Q()
