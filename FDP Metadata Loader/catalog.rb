class DCATCatalog < DCATResource
    attr_accessor :primaryTopic
    attr_accessor :type
    
    # def initialize(primary_topic: nil, baseuri: "http://example.org", access_rights: nil, conforms_to: nil, contact_point: nil, resource_creator: nil, 
    #     title: nil, release_date: nil, modification_date: nil, publisher: nil, identifier: nil, license: nil  )
    def initialize(**args)
        super

        self.types = [DCAT.Catalog, DCAT.Resource]
    end
    

end

