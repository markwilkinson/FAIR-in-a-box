class DCATDistribution < DCATResource
    attr_accessor :was_generated_by,
    
    def initialize(was_generated_by: nil )
        super 

        @was_generated_by = was_generated_by
        self.types = [DCAT.Distribution, DCAT.Resource]

    end
    

end

