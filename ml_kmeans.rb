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

	attr_accessor :kernel_method, :patterns, :classified_groups
	attr_accessor :last_difference_distance
	attr_accessor :convergence_error
	attr_accessor :current_iteration, :max_iteration

	def initialize
		@kernel_method		 				= MLKmeansKernel::ECULIDEAN
		@patterns  		   	 				= []
		@classified_groups 				= []
		@last_difference_distance = 0.0
		@convergence_error				= 0.001
		@current_iteration				= 0
		@max_iteration						= 1 # The max limitation iterations
	end

	# Quickly adding method of pattern
	def add_pattern(features, identifier = "")
		@patterns << MLKmeansPattern.new(features, identifier)
	end

	def add_patterns(samples)
		# Adding objects from another array with +=
		samples.each { |features|
			add_pattern(features)
		}
	end

	def add_center(features, identifier = "")
		# Creating a new center then adding to a new group
		center 			 = MLKmeansCenter.new(features, identifier)
		group  			 = MLKmeansGroup.new
		group.center = center
		@classified_groups << group
	end

	def random_choose_centers(pick_number = 2)
		patterns_count  = @patterns.count
		if pick_number <= 0 || patterns_count < pick_number
			random_picker = Random.new
			pick_number   = random_picker.rand(0...patterns_count) # 等同 rand( 0 ~ (patterns_count-1) )
		end
		randomized_patterns = @patterns.sample(pick_number)
		randomized_patterns.each { |each_pattern| add_center(each_pattern.features.dup) }
	end

	#def training(&block)
	def training

		if @patterns.count < 1
			return
		end

		remove_all_classified_patterns

		# Steps
		#	1. 全部分類
		# 2. 開始重新計算每一個群聚的中心點
		# 3. 計算該次迭代的所有群聚中心點與上一次舊的群聚中心點相減，取出最大距離誤差
		# 4. 比較是否 <= 收斂誤差，如是，即停止運算，如否，則進行第 4 步驟的遞迴迭代運算
		# 5. 依照這群聚中心點，進行迭代運算，重新計算與分類所有的已分類好的群聚，並重複第 1 到第 4 步驟

		# Weak Reference with @classified_groups
		#temp_groups = @classified_groups

		# 計算要分到哪一個最小距離的 Center 去要分到哪一個最小距離的 Center 去 (算每一個 Pattern 對每一個 Center 的距離)
		@patterns.each { |pattern|
			# 計算要被分到哪一個中心點去
			to_index	   = -1
			min_distance = 0.0
			@classified_groups.each_with_index { |group, group_index|
				distance = group.calculate_distance(pattern.features, group.center.features)
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

		# Renew all centers
		@classified_groups.each { |group| group.renew_center }

		puts "\n"

		# 取出上一次 Centers 跟當前 Centers 最大的距離差值是多少
		difference_distance = -1.0
		# 比較新舊群聚中心點的差值
		@classified_groups.each { |group|
			# To calculate the difference of distance between last center and current new center
			distance = group.calculate_center_difference
			if difference_distance < 0.0 || distance > difference_distance
				difference_distance = distance
			end
		}

		# 新舊中心點的距離已不改變 || abs(當前中心點最大距離上次距離的誤差) <= 收斂值 || 迭代運算到了限定次數 ( 避免 Memory Leak )
		if difference_distance == 0.0 || (difference_distance - @last_difference_distance).abs <= @convergence_error || @current_iteration >= @max_iteration
			# 已達收斂條件

			# directly print the classified_groups to instead of results.
			# 不然就是寫一個 results 的 getter，當外部呼叫 kmeans.results 時，就去 classified_groups 裡 loop 出每一個 patterns 和 center 這樣

			puts "done #{classified_groups}"

			# Done block triggers
			#completion_block.call(success, classified_groups, group_centers) if block_given?
		else
			@last_difference_distance  = difference_distance
			@current_iteration				+= 1
			#per_iteration_block(@current_iteration, @classified_groups) if block_given?

			# 使用 group.center (是 new center) 來繼續跑遞迴分群
			training

		end

	end

	private
	def remove_all_classified_patterns
		@classified_groups.each { |group|
			group.remove_all_patterns
		}
	end

end

kmeans = MLKMeans.new
# kmeans.add_pattern([0, 1])
# kmeans.add_pattern([0, 0])
# kmeans.add_pattern([2, 0])
# kmeans.add_pattern([2, 2])
# kmeans.add_pattern([3, 0])
# kmeans.add_pattern([4, 0])

samples_1 = [[1, 1], [1, 2], [2, 2], [3, 2], [3, 1], [5, 4], [3, 4], [2, 5]]
samples_2 = [[9, 8], [3, 20], [6, 4], [7, 6], [5, 6], [6, 5], [7, 8], [3, 12], [5, 20]]
kmeans.add_patterns(samples_1)
kmeans.add_patterns(samples_2)

kmeans.random_choose_centers(3)

kmeans.max_iteration = 100

kmeans.training





# samples_1.clear
# samples_2.clear

# puts "#{kmeans.patterns}"


# center = MLKmeansCenter.new([1, 2, 3], "hello")
# puts "#{center.features}"
# puts "#{center.identifier}"

