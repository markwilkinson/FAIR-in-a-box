require 'rest-client'
require 'json'

#domain = "http://fdp.duchennedatafoundation.org:8080"
#domain = "http://localhost:8080"
permaURI = "https://w3id.org/duchenne-fdp"
server = "http://fdp.duchennedatafoundation.org:8080"

catalog = File.read("catalog.ttl")
dataset = File.read("dataset.ttl")
distribution = File.read("distribution.ttl")


cat_title = "Duchenne Data Platform Catalog"
cat_description = "The Duchenne Data Platform (DDP) Catalog"
cat_issued = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
cat_modified = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
cat_publisher = "Stichting Parent Project Productions"
cat_license = "https://raw.githubusercontent.com/creativecommons/cc.licenserdf/master/cc/licenserdf/licenses/creativecommons.org_publicdomain_zero_1.0_.rdf"
#cat_themes = File.read("cat_themes.ttl")
cat_rights = "This metadata file has no restrictions"


dset_title = "Duchenne Data Platform"
dset_description = "The Duchenne Data Platform (DDP) is a patient-led registry. Patients are the owners of their data and have their own ‘data lockers’ where they can not only collect their Patient Reported Outcomes (PROs) but can also upload their data from other sources such as hospitals and wearables."
dset_issued = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
dset_modified = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
dset_publisher = "Mark D Wilkinson"
dset_license = "https://raw.githubusercontent.com/creativecommons/cc.licenserdf/master/cc/licenserdf/licenses/creativecommons.org_publicdomain_zero_1.0_.rdf"
#dset_keywords =  "Becker Muscular Dystrophy"@en, "Clinical data"@en, "Duchenne Muscular Dystrophy"@en, "Genetic data"@en, "PROMs"@en, "PROs"@en
dset_contact = "https://w3id.org/duchenne-fdp/dataset/d877ac76-87ba-461f-803b-3a8a90a2e965#contact";
#dset_themes = File.read("dset_themes.ttl")
dset_rights = "This metadata file has no restrictions"
dset_landingPage = "https://duchenne.nl"
dset_rightsURI = "https://en.wikipedia.org/wiki/All_rights_reserved"
dset_creator_orcid = "https://orcid.org/0000-0003-2160-9395"
dset_contact_email = "mailto:info@duchenne.nl"


dist_title = "Patient Clinical Data"
dist_description = "Database the Common Data Elements (CDEs) for Rare Diseases Registrations produced by the European Commission, Joint Research Centre, and additional clinical observations of patients in the Duchenne Parent Project."
dist_version = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
dist_issued = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
dist_modified = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
dist_publisher = "Stichting Parent Project Productions"
dist_contact = "Roos de Jonge"
dist_contact_email = "mailto:info@duchenne.nl"
dist_accessRights = "https://some.location.that.explains/howtogetaccess/"
dist_endpoint_description = "https://some.location.that.explains/how.to.query/"
dist_endpoint = "http://fdp.duchennedatafoundation.org:7200/sparql"
dist_schema = "http://fairdata.systems:8890/DAV/home/LDP/duchenne/duchenne-shacl.ttl"
dist_license = "http://rdflicense.appspot.com/rdflicense/cc-by-nc-nd3.0/rdf"
dist_rightsURI = "https://en.wikipedia.org/wiki/All_rights_reserved"
dist_rightsStatement = "All rights reserved"
dist_mediaType = "application/sparql-results+json"

rightsURL = "http://example.org"


# curl -X POST -H "Accept: application/json" \
#     -H "Content-Type: application/json" \
#     -d '{ "email": "user@example.com", "password": "secret" }' \
#     https://fdp.example.com/tokens

payload = '{ "email": "' + ENV['FDPUSER'] + '", "password": "' + ENV['FDPPASS'] + '" }'
resp = RestClient.post("#{server}/tokens", payload, headers={content_type: 'application/json'})
    
token = JSON.parse(resp.body)["token"]


puts token
headers = {content_type: 'text/turtle', authorization: "Bearer #{token}", accept: "text/turtle"}
#puts headers; abort

# c = "<http://fairdata.systems:8080/catalog/52ba5ab0-3b49-4e19-9e1f-9955ae246c33>
# <http://fairdata.systems:8080/catalog/ce3a9349-4b6f-476c-8a6f-b43dea29b3e8>
# <http://fairdata.systems:8080/catalog/060dc6f5-67da-47fa-902f-2d8d56bea8a4>
# <http://fairdata.systems:8080/catalog/19b046bb-334c-4a54-81b7-9639d8d653a5>
# <http://fairdata.systems:8080/catalog/005f02a9-d743-4216-8217-b732b1ddf2aa>
# <http://fairdata.systems:8080/catalog/b63f46ed-f8d0-4974-8565-ff9111607e49>
# <http://fairdata.systems:8080/catalog/e2f88f1e-f3af-40f2-8653-4d5144e4b5e2>
# <http://fairdata.systems:8080/catalog/9a7721c9-2dc8-4f89-b3c6-048b2e23b8b3>
# <http://fairdata.systems:8080/catalog/088413e7-b244-4fef-ae3a-ab5f333484f8>
# <http://fairdata.systems:8080/catalog/f741940b-fabb-4255-8cd4-755eec2c2257>"
# c = c.split
# puts c
# puts c.class 

# c.each do |url|
#     url.gsub!(/>/,"")
#     url.gsub!(/</,"")
#     puts url
#     resp = RestClient.delete(url, headers)
#     puts = resp.headers.to_s
# end
   


# abort

puts "writing cat"
catinit = <<END
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .

<> a dcat:Catalog, dcat:Resource ;
    dct:title "test" ;
    dct:hasVersion "1.0" ;
    dct:publisher [ a foaf:Agent ; foaf:name "Example User" ] ;
    dct:isPartOf <#{permaURI}> .
    
END
resp = RestClient.post("#{server}/catalog", catinit, headers)
catlocation = resp.headers[:location]
puts "catalolg written to #{catlocation}\n\n"

catalog = catalog % {catalog: catlocation, domain: permaURI, cat_title: cat_title, cat_description: cat_description, cat_issued: cat_issued,
    cat_modified: cat_modified, cat_publisher: cat_publisher, cat_license: cat_license,  cat_rights: cat_rights }
puts catalog + "\n\n\n"

location = catlocation.gsub(permaURI, server)
puts "rewriting cat to #{location}/meta/state}"

resp = RestClient.put(location, catalog, headers)
puts resp.headers.to_s
resp = RestClient.put("#{location}/meta/state", '{ "current": "PUBLISHED" }', headers={authorization: "Bearer #{token}",  content_type: 'application/json'})







datainit = <<END2
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .

<> a dcat:Dataset, dcat:Resource ;
    dct:title "test" ;
    dct:hasVersion "1.0" ;
    dct:publisher [ a foaf:Agent ; foaf:name "Example User" ] ;
    dcat:theme <http://purl.obolibrary.org/obo/GENEPIO_0001793> ;
    dct:isPartOf <#{catlocation}> .
    
END2
puts datainit
puts
resp = RestClient.post("#{server}/dataset", datainit, headers)
datalocation = resp.headers[:location]
puts "dataset written to #{datalocation}\n\n"
# dset_title = "Duchenne Data Platform"
# dset_description = "The Duchenne Data Platform (DDP) is a patient-led registry. Patients are the owners of their data and have their own ‘data lockers’ where they can not only collect their Patient Reported Outcomes (PROs) but can also upload their data from other sources such as hospitals and wearables."
# dset_issued = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
# dset_modified = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
# dset_publisher = "Mark D Wilkinson"
# dset_license = "https://raw.githubusercontent.com/creativecommons/cc.licenserdf/master/cc/licenserdf/licenses/creativecommons.org_publicdomain_zero_1.0_.rdf"
# #dset_keywords =  "Becker Muscular Dystrophy"@en, "Clinical data"@en, "Duchenne Muscular Dystrophy"@en, "Genetic data"@en, "PROMs"@en, "PROs"@en
# dset_contact = "https://w3id.org/duchenne-fdp/dataset/d877ac76-87ba-461f-803b-3a8a90a2e965#contact";
# #dset_themes = File.read("dset_themes.ttl")
# dset_rights = "This metadata file has no restrictions"
# dset_rightsURI = "https://en.wikipedia.org/wiki/All_rights_reserved"
# dset_landingPage = "https://duchenne.nl"
# dset_creator_orcid = "https://orcid.org/0000-0003-2160-9395"

location = datalocation.gsub(permaURI, server)
puts "rewriting dataset to #{location}"
dataset = dataset % {catalog: catlocation, domain: permaURI, dataset: datalocation, 
    dset_title: dset_title, dset_description: dset_description, dset_issued: dset_issued, dset_modified: dset_modified, 
    dset_publisher: dset_publisher, dset_license: dset_license, dset_contact: dset_contact, dset_rights: dset_rights, dset_rightsURI: dset_rightsURI,
    dset_landingPage: dset_landingPage, dset_creator_orcid: dset_creator_orcid, dset_contact_email: dset_contact_email,
}
puts "\n\n\n" + dataset + "\n\n\n"

resp = RestClient.put(location, dataset, headers)
puts resp.headers.to_s
resp = RestClient.put("#{location}/meta/state", '{ "current": "PUBLISHED" }', headers={authorization: "Bearer #{token}",  content_type: 'application/json'})









distinit = <<END2
@prefix dcat: <http://www.w3.org/ns/dcat#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .

<> a dcat:Distribution, dcat:Resource ;
    dct:title "test" ;
    dct:hasVersion "1.0" ;
    dct:publisher [ a foaf:Agent ; foaf:name "Example User" ] ;
    dct:isPartOf <#{datalocation}> ;
    dcat:mediaType "application/sparql-results+json" .
    
END2
puts distinit
puts; puts

resp = RestClient.post("#{server}/distribution", distinit, headers)
distlocation = resp.headers[:location]
puts "distribution written to #{distlocation}\n\n"

location = distlocation.gsub(permaURI, server)

# dist_title = "Patient Clinical Data"
# dist_description = "Database the Common Data Elements (CDEs) for Rare Diseases Registrations produced by the European Commission, Joint Research Centre, and additional clinical observations of patients in the Duchenne Parent Project."
# dist_version = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
# dist_issued = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
# dist_modified = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L')
# dist_publisher = "Stichting Parent Project Productions"
# dist_contact = "Roos de Jonge"
# dist_contact_email = "mailto:info@duchenne.nl"
# dist_accessRights = "https://some.location.that.explains/howtogetaccess/"
# dist_endpoint_description = "https://some.location.that.explains/how.to.query/"
# dist_endpoint = "http://fdp.duchennedatafoundation.org:7200/sparql"
# dist_schema = "http://fairdata.systems:8890/DAV/home/LDP/duchenne/duchenne-shacl.ttl"
# dist_license = "http://rdflicense.appspot.com/rdflicense/cc-by-nc-nd3.0/rdf"
# dist_rightsURI = "https://en.wikipedia.org/wiki/All_rights_reserved"
# dist_rightsStatement = "All rights reserved"
# dist_mediaType = "application/sparql-results+json"


distribution = distribution % {catalog: catlocation, domain: permaURI, dataset: datalocation, distribution: distlocation,
    dist_title: dist_title, dist_description: dist_description, dist_version: dist_version, dist_issued:dist_issued, 
    dist_modified: dist_modified, dist_publisher: dist_publisher, dist_contact: dist_contact, dist_contact_email: dist_contact_email, 
    dist_accessRights: dist_accessRights, dist_endpoint_description: dist_endpoint_description, dist_endpoint: dist_endpoint, 
    dist_schema: dist_schema, dist_license: dist_license, dist_rightsURI: dist_rightsURI, dist_rightsStatement: dist_rightsStatement, 
    dist_mediaType: dist_mediaType, 
}
puts distribution
puts "putting to #{location}"
resp = RestClient.put(location, distribution, headers)
puts resp.headers.to_s
resp = RestClient.put("#{location}/meta/state", '{ "current": "PUBLISHED" }', headers={authorization: "Bearer #{token}", content_type: 'application/json'})

