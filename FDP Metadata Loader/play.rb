require './resource.rb'
require './catalog.rb'
require './dataset.rb'
require './distribution.rb'
require 'esv'

data = File.read("example.xls")
data = ESV.parse(data)
data = data.filter_map {|d| [d[0], d[1]] if d[0]}
hash = Hash[*data.flatten]

a = DCATCatalog.new(
    baseURI: "http://my.root.org",
    parentURI: "http://my.root.parent.org",
    accessRights: hash['cat_accessRights'], 
    conformsTo: nil, 
    contactEmail:  hash['cat_contactEmail'], 
    contactName:  hash['cat_contactName'], 
    title: hash['cat_title'],  
    issued: hash['cat_issued'], 
    modified: hash['cat_modified'],
    publisher: hash['cat_publisher'], 
    identifier: nil, 
    license:hash['cat_license'], 
)
a.build
a.serialize
