require 'linkeddata'
require 'sinatra'

get '/update' do
  update_distribution_date
  update_dataset_date_theme
end


def update_distribution_date
  dist_recordid = $ENV["DIST_RECORDID"]
  dist_recordURL = dist_recordid + "?format=ttl"
  domain = $ENV["DOMAIN"]
  username = $ENV["FDP_USERNAME"]
  password = $ENV["FDP_PASSWORD"]
  
  put_url = "http://#{username}:#{password}@#{domain}/distribution/#{dist_recordid}"
  get_url = "http://#{username}:#{password}@#{domain}/distribution/#{dist_recordURL}"
  
  distribution = RestClient.get(get_url)
  queryable = RDF::Repository.load(distribution)
  
  time = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  
  sse = SPARQL.parse(%(
    PREFIX doap: <http://usefulinc.com/ns/doap#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    DELETE { ?res dcterms:modified ?date}
    INSERT { ?res dcterms:modified "#{time}"^^xsd:dateTime}
    WHERE { ?res dcterms:modified ?date}), update: true)
  sse.execute(queryable)

  RDF::Writer.for(:turtle).buffer do |writer|
    graph.each_statement do |statement|
      writer << statement
    end
  end
  
  data = writer.to_s

  #RDF::Writer.open("distribution.ttl") do |writer|
  #  queryable.each_statement do |statement|
  #    writer << statement
  #  end
  #end

  resp = RestClient.put(put_url, data, content_type: "text/turtle")
  $stderr.puts resp
  
end


def update_dataset_date_theme
  dataset_recordid = $ENV["DATASET_RECORDID"]
  dataset_recordURL = dataset_recordid + "?format=ttl"
  domain = $ENV["DOMAIN"]
  username = $ENV["FDP_USERNAME"]
  password = $ENV["FDP_PASSWORD"]
  
  put_url = "http://#{domain}/dataset/#{dataset_recordid}"
  get_url = "http://#{domain}/dataset/#{dataset_recordURL}"

  dataset = RestClient.get(get_url, username: username, password: password)
  queryable = RDF::Repository.load(dataset)
  
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
  
  RDF::Writer.for(:turtle).buffer do |writer|
    graph.each_statement do |statement|
      writer << statement
    end
  end
  
  data = writer.to_s

  resp = RestClient.put(put_url, data, content_type: "text/turtle", username: username, password: password)
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