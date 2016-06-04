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
	attr_accessor :convergence_error
	attr_accessor :current_iteration, :max_iteration
	attr_accessor :is_pause
	attr_accessor :iteration_block, :completion_block

	def initialize
		@kernel_method		 	= MLKmeansKernel::ECULIDEAN
		@patterns  		   	 	= []
		@classified_groups 	= []
		@convergence_error	= 0.001
		@current_iteration	= 0
		@max_iteration			= 1 # The max limitation iterations
		@is_pause						= false
	end

	def create_pattern(features, identifier = '')
		MLKmeansPattern.new(features, identifier)
	end

	# Quickly adding method of pattern
	def add_pattern(features, identifier = '')
		@patterns << create_pattern(features, identifier)
	end

	def add_patterns(samples)
		# Adding objects from another array with +=
		samples.each { |features|
			add_pattern(features)
		}
	end

	def add_center(features, identifier = '')
		# Creating a new center then adding to a new group
		center 			 				= MLKmeansCenter.new(features, identifier)
		group  			 				= MLKmeansGroup.new
		group.center 				= center
		group.kernel_method = @kernel_method
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

	def training(iteration_block, completion_block)
		if !iteration_block.nil?
			@iteration_block = iteration_block
		end

		if !completion_block.nil?
			@completion_block = completion_block
		end

		if @patterns.count < 1 || true == @is_pause
			return
		end

		remove_all_classified_patterns

		# Steps
		#	1. 全部分類
		# 2. 開始重新計算每一個群聚的中心點
		# 3. 計算該次迭代的所有群聚中心點與上一次舊的群聚中心點相減，取出最大距離誤差
		# 4. 再比較新舊最大距離誤是否 <= 收斂誤差，如是，即停止運算，如否，則進行第 4 步驟的遞迴迭代運算
		# 5. 依照這群聚中心點，進行迭代運算，重新計算與分類所有的已分類好的群聚，並重複第 1 到第 4 步驟

		# Weak Reference with @classified_groups
		#temp_groups = @classified_groups

		# 計算要分到哪一個最小距離的 Center 去要分到哪一個最小距離的 Center 去 (算每一個 Pattern 對每一個 Center 的距離)
		clustering_to_group(@patterns)

		# Renew all centers
		@classified_groups.each { |group| group.renew_center }

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

		# abs(當前中心點最大距離上次距離的誤差) <= 收斂值 || 迭代運算到了限定次數 ( 避免 Memory Leak )
		if difference_distance.abs <= @convergence_error || @current_iteration >= @max_iteration
			# 已達收斂條件
			@completion_block.call(true, self, @current_iteration) unless @completion_block.nil?
		else
			@current_iteration += 1
			@iteration_block.call(@current_iteration, @classified_groups) unless @iteration_block.nil?
			# 使用 group.center (new center) 來繼續跑遞迴分群
			training(@iteration_block, @completion_block)
		end

	end

	# To calculate the SSE value.
	def SSE
		# 計算加總所有的分群裡頭每個資料點與中心點距離，目的是對每次 K-Means 的聚類結果做評量，以找出具有最小SSE的那組聚類結果作為最佳解
		sum_distance = 0.0
		@classified_groups.each { |group|
			sum_distance += group.calculate_group_distance
		}
		sum_distance
	end

	def print_results
		@classified_groups.each { |group|
			puts "center #{group.center.features}"
			group.patterns.each_with_index { |pattern, index|
				puts "pattern ##{index}, the ID is #{pattern.identifier}, the features #{pattern.features}"
			}
			puts "\n"
		}
	end

	def reset
		@classified_groups.each { |group|
			group.remove_all_patterns
			group.remove_centers
		}
		@classified_groups.clear
		@patterns.clear
		@current_iteration	= 0
		@is_pause						= false
	end

	def recall
		# TODO: Recalling the trained centers from storage or database.
	end

	def save
		# TODO: Saving the trained centers to anywhere, we have to try how to save the trained data to storage files or database.
	end

	def pause
		@is_pause = true
	end

	def restart
		@is_pause = false
		training(@iteration_block, @completion_block)
		#training(nil, nil)
	end

	def predicate(samples, &block)
		if samples.count > 0
			remove_all_classified_patterns
			clustering_to_group(samples)
			block.call(true) if block_given?
		end
	end

	private
	def remove_all_classified_patterns
		@classified_groups.each { |group|
			group.remove_all_patterns
		}
	end

	def clustering_to_group(patterns)
		# 計算要分到哪一個最小距離的 Center 去要分到哪一個最小距離的 Center 去 (算每一個 Pattern 對每一個 Center 的距離)
		patterns.each { |pattern|
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
	end

end


