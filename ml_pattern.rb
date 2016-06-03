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

	# 一次加入一個 feature value
	def add_one_feature(one_feature)
		@features << one_feature
	end

	def remove_features
		@features.clear
	end

end