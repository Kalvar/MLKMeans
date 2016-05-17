class MLKmeansPattern

	attr_accessor :features

	def initialize(features)
		@features   = features
	end
	
end

class MLKmeansCenter < MLKmeansPattern

	attr_accessor :identifier

	def initialize(features, identifier)
		@features   = features
		@identifier = identifier
	end
	
end