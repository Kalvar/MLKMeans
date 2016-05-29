$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'ml_kernel'
require 'ml_distance'
require 'ml_group'

class MLKMeans

	# Singleton
	@@instance = nil
	def self.instance
			@@instance = new unless @@instance
			@@instance
	end

	attr_accessor :distance_function, :kernel_choice, :patterns, :classified_groups

	def initialize
		@distance_function = MLKmeansDistance.new
		@kernel_choice	   = MLKmeansKernel::ECULIDEAN
		@patterns  		   	 = []
		@classified_groups = []
	end

	# Quickly adding method of pattern
	def add_pattern(features, identifier = "")
		@patterns << MLKmeansPattern.new(features, identifier)
	end

	def add_patterns(samples)
		# Adding objects from another array with +=
		@patterns += samples
	end

	def add_center(features, identifier = "")
		# Creating a new center then adding to new group
		center = MLKmeansCenter.new(features, identifier)
		group  = MLKmeansGroup.new
		group.set_center(center)
		@classified_groups << group
	end

	def random_choose_centers(pick_number = 2)
		patterns_count  = @patterns.count
		if pick_number <= 0 || patterns_count < pick_number
			random_picker = Random.new
			pick_number   = random_picker.rand(0...patterns_count) # 等同 rand( 0 ~ (patterns_count-1) )
		end
		randomized_patterns = @patterns.sample(pick_number)
		randomized_patterns.each { |each_pattern| add_center(each_pattern.features) }
	end

	#def training(&block)
	def training
		remove_all_classified_patterns
		# Weak Reference with @classified_groups
		#temp_groups = @classified_groups

		# 先算每一個 Pattern 對每一個 Center 的距離，以及要分到哪一個最小距離的 Center 去
		@patterns.each { |pattern|
			# 計算要被分到哪一個中心點去
			to_index	   = -1
			min_distance = 0.0
			@classified_groups.each_with_index { |group, group_index|
				distance = @distance_function.eculidean(pattern.features, group.center.features)
				if to_index < 0 || distance < min_distance
					min_distance = distance
					to_index	   = group_index
				end
			}

			if to_index >= 0
				to_group = @classified_groups[to_index]
				to_group.add_pattern(pattern)
			end
		}
		
		#block.call(success, classified_groups, group_centers) if block_given?
	end

	private
	def remove_all_classified_patterns
		temp_groups = @classified_groups
		temp_groups.each { |group|
			group.remove_all_patterns
		}
	end

end

kmeans = MLKMeans.new
kmeans.add_pattern([0, 1])
kmeans.add_pattern([0, 0])
kmeans.add_pattern([2, 0])
kmeans.add_pattern([2, 2])
kmeans.add_pattern([3, 0])
kmeans.add_pattern([4, 0])
kmeans.random_choose_centers(3)
kmeans.training



# samples_1 = [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5]]
# samples_2 = [[1, 1], [1, 2], [1, 3]]
# kmeans.add_patterns(samples_1)
# kmeans.add_patterns(samples_2)

# samples_1.clear
# samples_2.clear

# puts "#{kmeans.patterns}"


# center = MLKmeansCenter.new([1, 2, 3], "hello")
# puts "#{center.features}"
# puts "#{center.identifier}"

