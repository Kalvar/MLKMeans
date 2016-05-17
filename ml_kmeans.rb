$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'ml_kernel'
require 'ml_distance'
require 'ml_pattern'

class MLKMeans

	# Singleton
    @@instance = nil
    def self.instance
        @@instance = new unless @@instance
        @@instance
    end

	attr_accessor :distance_function, :kernel_method, :patterns, :centers

	def initialize
		@distance_function = MLKmeansDistance.new
		@kernel_method	   = MLKmeansKernel::ECULIDEAN
		@patterns  		   = []
		@centers		   = []
	end

	def add_pattern(features)
		@patterns << MLKmeansPattern.new(features)
	end

	def add_patterns(samples)
		samples.each{}
	end

	def add_center(features, identifier)
		@centers << MLKmeansCenter.new(features, identifier)
	end

	def choose_center(how_many_centers = 2, is_random = true)


		#用切區塊的方式來從每一個區塊裡隨機挑選中心點

		# Random choose centers from patterns
		if is_random
			random_picker = Random.new
			count 		  = @patterns.count - 1
			for i in 0..how_many_centers
				# Picking [0 ~ count] that random number
				random_index = random_picker.rand(0..count)
				@centers << @patterns[random_index]
			end
		else

		end

	end

end

