class DCATDataService < DCATDistribution
    attr_accessor :endpointDescription, :endpointURL
    
    def initialize(endpointDescription: nil, endpointURL: nil )
        super 

        self.types = [DCAT.Resource, DCAT.DataService]

    end
    

end

