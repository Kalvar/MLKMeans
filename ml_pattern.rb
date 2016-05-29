class MLKmeansPattern

	attr_accessor :features
	attr_accessor :identifier

	def initialize(features, identifier)
		@features	  = features
		@identifier = identifier
	end
	
end

# 繼承寫法
class MLKmeansCenter < MLKmeansPattern

	def initialize(features, identifier)
		super(features, identifier)
	end

end