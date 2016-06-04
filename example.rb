require './ml_kmeans'

kmeans = MLKMeans.new
# Adding pattern one on one
kmeans.add_pattern([0, 1])
kmeans.add_pattern([0, 0])
kmeans.add_pattern([2, 0])
kmeans.add_pattern([2, 2])
kmeans.add_pattern([3, 0])
kmeans.add_pattern([4, 0])
# Adding patterns for batch
samples_1 = [[1, 1], [1, 2], [2, 2], [3, 2], [3, 1], [5, 4], [3, 4], [2, 5]]
samples_2 = [[9, 8], [3, 20], [6, 4], [7, 6], [5, 6], [6, 5], [7, 8], [3, 12], [5, 20]]
kmeans.add_patterns(samples_1)
kmeans.add_patterns(samples_2)
# Choose kernel method before setup centers
kmeans.kernel_method		 = MLKmeansKernel::ECULIDEAN
# Random choose the centers of groups
kmeans.random_choose_centers(3)
# That max iteration of limitation
kmeans.max_iteration 		 = 100
# That convergence value before max_iteration happening
kmeans.convergence_error = 0.001

# Start in training with 2 blocks of callback
iteration_block = Proc.new do |current_iteration, classified_groups|
	puts "iteration : #{current_iteration}\n"
	#puts "classified_groups : #{classified_groups}"
end

completion_block = Proc.new do |success, self_kmeans, total_iteration|
	puts "\n============ Done ============="
	puts "success : #{success}"
	puts "total_iteration : #{total_iteration}"
	puts "SSE : #{self_kmeans.SSE}"
	# Printing the classified results
	puts "results : "
	self_kmeans.print_results

	# Doing predication
	puts "============ Doing predication ============="
	samples 						= [[9, 6], [10, 13], [6, 1], [2, 3]]
	predication_samples = []
	samples.each_with_index { |features, index|
		predication_samples << self_kmeans.create_pattern(features, 'predication_' + index.to_s)
	}
	self_kmeans.predicate(predication_samples){ |success|
		self_kmeans.print_results
	}
end

kmeans.training(iteration_block, completion_block)