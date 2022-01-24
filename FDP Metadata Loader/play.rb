require './resource.rb'
require './catalog.rb'
require './dataset.rb'
require './distribution.rb'
require './access_service.rb'
require 'esv'

data = File.read("example.xls")
data = ESV.parse(data)
data = data.filter_map {|d| [d[0], d[1]] if d[0]}
hash = Hash[*data.flatten]

puts hash.inspect
# abort

catalog = DCATCatalog.new(
    serverURL: "http://localhost:7070",
    baseURI: "http://localhost:7070",
    parentURI: "http://localhost:7070",
    title: hash['cat_title'],  
    description: hash['cat_description'],
    hasVersion: hash['cat_hasVersion'],
    issued: hash['cat_issued'], 
    modified: hash['cat_modified'],
    publisher: hash['cat_publisher'], 
    license:hash['cat_license'], 
    accessRights: hash['cat_accessRights'], 
    creator:  hash['cat_creator'],
    creatorName:  hash['cat_creatorName'],
    contactEmail:  hash['cat_contactEmail'], 
    contactName:  hash['cat_contactName'],  
)

parentURI = catalog.identifier

dataset = DCATDataset.new(
    serverURL: "http://localhost:7070",
    baseURI: "http://localhost:7070",
    parentURI: parentURI,
    title: hash['dset_title'],  
    description: hash['dset_description'],
    hasVersion: hash['dset_hasVersion'],
    issued: hash['dset_issued'], 
    modified: hash['dset_modified'],
    publisher: hash['dset_publisher'], 
    license:hash['dset_license'], 
    accessRights: hash['dset_accessRights'], 
    creator:  hash['dset_creator'],
    creatorName:  hash['dset_creatorName'],
    contactEmail:  hash['dset_contactEmail'], 
    contactName:  hash['dset_contactName'],
    landingPage: hash['dset_landingPage'],
    theme: hash['dset_theme'],
)
catalog.dataset= dataset.identifier.to_s
catalog.write_catalog


catalog.publish
dataset.publish