$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

class MLKMeans

	#Singleton
    @@instance = nil
    def self.instance
        @@instance = new unless @@instance
        @@instance
    end

	attr_accessor :distance_function, :kernel_method, :training_sets, :completion_block

	def initialize
		
	end

end