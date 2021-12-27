require 'rdf/raptor'
require 'linkeddata'
require 'sparql'
require 'rest-client'
require 'json'

def get_token
  server = "http://fdp.duchennedatafoundation.org:8080"
  payload = '{ "email": "info@fairdata.systems", "password": "!The1stDPPPass!!!" }'
  $stderr.puts "#{server}/tokens", payload, headers={content_type: 'application/json'}
  resp = RestClient.post("#{server}/tokens", payload, headers={content_type: 'application/json'})
     
  token = JSON.parse(resp.body)["token"]
  #puts token
  headers = {content_type: 'text/turtle', authorization: "Bearer #{token}", accept: "text/turtle"}
  return headers
end



def update_distribution_date(headers)
  dist_recordid = "d959bbdd-7e20-453a-b8ad-0d1897bdb287"
  dist_recordURL = dist_recordid + "?format=rdf"
  domain = "fdp.duchennedatafoundation.org:8080"
  
  put_url = "http://#{domain}/distribution/#{dist_recordid}"
  get_url = "http://#{domain}/distribution/#{dist_recordURL}"
  
  distribution = RestClient.get(get_url)
  file="test"
  File.open(file, "w") {|f| f.write(distribution.body)}
  io = File.open(file)
  reader = RDF::Reader.for(:rdfxml).new(io)
  queryable = RDF::Repository.new
  reader.each_statement {|s| queryable << s}
  io.close

  time = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  
  sse = SPARQL.parse(%(
    PREFIX doap: <http://usefulinc.com/ns/doap#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    DELETE { ?res dcterms:modified ?date}
    INSERT { ?res dcterms:modified "#{time}"^^xsd:dateTime}
    WHERE { ?res dcterms:modified ?date}), update: true)
  sse.execute(queryable)

  data = RDF::Writer.for(:turtle).dump(queryable)
  $stderr.puts data
  #resp = RestClient.put(put_url, data, headers)
  #$stderr.puts resp
  
end


def update_dataset_date_theme(headers)
  dataset_recordid = ENV["DATASET_RECORDID"]
  dataset_recordURL = dataset_recordid + "?format=ttl"
  domain = ENV["DOMAIN"]
  
  put_url = "http://#{domain}/dataset/#{dataset_recordid}"
  get_url = "http://#{domain}/dataset/#{dataset_recordURL}"


  dataset = RestClient.get(get_url)
  io = StringIO.new(dataset.body)
  reader = RDF::Reader.for(:turtle).new(io)
  queryable = RDF::Repository.new
  reader.each_statement {|s| queryable << s}
  
  time = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  puts time
  
  sse = SPARQL.parse(%(
    PREFIX doap: <http://usefulinc.com/ns/doap#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    DELETE { ?res dcterms:modified ?date}
    INSERT { ?res dcterms:modified "#{time}"^^xsd:dateTime}
    WHERE { ?res dcterms:modified ?date}), update: true)
  sse.execute(queryable)
  

  types = get_types()
  newquery = %(
    PREFIX doap: <http://usefulinc.com/ns/doap#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    PREFIX dcat: <http://www.w3.org/ns/dcat#>
    
    DELETE { ?res dcat:theme ?term}
    INSERT { ?res dcat:theme ?newterm}
    WHERE { ?res dcat:theme ?term .
      VALUES ?newterm { #{types} }
    }
  )
  
  sse = SPARQL.parse(newquery, update: true)
  sse.execute(queryable)
  
  data = RDF::Writer.for(:turtle).dump(queryable)
  
  resp = RestClient.put(put_url, data, headers)
  $stderr.puts resp

end

def get_types
  data_sparql_endpoint = $ENV["DATA_SPARQL_ENDPOINT"]
    
  
  sparql = SPARQL::Client.new(data_sparql_endpoint)
  query = <<END
  PREFIX sio: <http://semanticscience.org/resource/>
  
  SELECT DISTINCT ?type WHERE {
  ?s sio:has-attribute ?a .
  ?a a ?type .
  FILTER(!CONTAINS(str(?type), "DDP_")) 
  }
END
  
  result = sparql.query(query)
  types = result.map{|r| "<#{r[:type]}>"}
  puts types
  
  types = types.join(" ")
  return types

end





  headers = get_token
  update_distribution_date(headers)
  #update_dataset_date_theme(headers)
