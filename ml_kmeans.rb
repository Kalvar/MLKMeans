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

	def random_choose_centers(pick_number = 2)
		patterns_count  = @patterns.count
		if pick_number <= 0
			random_picker = Random.new
			pick_number   = random_picker.rand(0...patterns_count) # 等同 rand( 0 ~ (patterns_count-1) )
		elsif patterns_count < pick_number
			pick_number   = patterns_count
		end

		# Random choose centers from patterns
		@centers << @patterns.sample(pick_number)
	end


end

