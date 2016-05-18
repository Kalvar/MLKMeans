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

	def choose_center(pick_number = 2, is_random = true)

		patterns_count  = @patterns.count
		if patterns_count < pick_number
			pick_number = patterns_count
		end

		# Random choose centers from patterns
		if is_random
			random_picker   = Random.new
			patterns_count -= 1
			chunk_length  	= patterns_count / pick_number
			remain_length	= patterns_count % pick_number # 剩餘的 Chunk 長度
			max_value	  	= 0
			min_value	  	= 0
			# 下面寫法等同 (i=0; i<pick_number; i++)
			for i in 0...pick_number
				# 如果是最後一個區段，就多加上剩餘的 Chunk 長度以讓全部的 Patterns 都能夠有機會被選擇到
				max_value  += (i == pick_number - 1) ? chunk_length + remain_length : chunk_length
				# Picking [min, max-1] that random number
				random_index = random_picker.rand(min_value..max_value)
				@centers << @patterns[random_index]
				min_value	 = max_value + 1
			end
		else
			# Waiting for implementation an algorithm of choice.
			# TODO:
		end

	end

end

