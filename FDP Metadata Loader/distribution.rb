class DCATDistribution < DCATResource
    attr_accessor :was_generated_by, :mediaType, :format
    
    def initialize(was_generated_by: nil, mediaType:  nil, format: nil,  **args )
        super 

        @was_generated_by = was_generated_by
        @mediaType = mediaType
        @format = format
        self.types = [DCAT.Distribution, DCAT.Distribution]

    end
    

end

