require 'ml_pattern'

# 已分類的群在這裡
class MLKmeansGroup

  # 群組的代表 ID
  attr_accessor :identifier
  # 在這群組裡的數據組
  attr_accessor :patterns
  # 這群組的當前中心點 (也為 New Center)
  attr_accessor :center
  # 這群組的上一次中心點
  attr_accessor :last_center
  # 距離運算方法
  attr_accessor :distance_function, :kernel_method

  def initialize
    @distance_function = MLKmeansDistance.new
    @kernel_method	   = MLKmeansKernel::ECULIDEAN
    @patterns          = []
    @identifier        = ''
  end

  def add_pattern(classified_pattern)
    @patterns << classified_pattern
  end

  def renew_center
    # To deeply copy current center to last center
    @last_center          = @center.clone
    @last_center.features = @center.features.dup
    if @patterns.empty?
      return
    end
    @center.remove_features
    # To average multi-dimensional sub-vectors be central vectors
    patterns_count        = @patterns.count
    # 取出 Pattern 裡的 Features 個數 (Dimension)
    first_pattern         = @patterns.first
    features_count        = first_pattern.features.count
    for i in 0...features_count
      dimension_sum = 0.0
      @patterns.each { |pattern|
        dimension_sum += pattern.features[i]
      }
      dimension_sum /= patterns_count
      @center.add_one_feature(dimension_sum)
    end
  end

  def reset_centers
    @center      = nil
    @last_center = nil
  end

  def remove_all_patterns
    @patterns.clear
  end

  # To calculate difference distance between last center and current new center.
  def calculate_center_difference
    calculate_distance(@last_center.features, @center.features)
  end

  def calculate_distance(x1, x2, sigma = 2.0)
    case @kernel_method
      when MLKmeansKernel::ECULIDEAN
        @distance_function.eculidean(x1, x2)
      when MLKmeansKernel::COSINE_SIMILARITY
        1.0 - @distance_function.cosine_similarity(x1, x2)
      when MLKmeansKernel::RBF
        @distance_function.rbf(x1, x2, sigma)
      else
        0.0
    end
  end

  # To calculate all patterns to current center that distance summation. The SSE will use this value to do judgement.
  def calculate_group_distance
    sum = 0.0
    @patterns.each { |pattern|
      sum += calculate_distance(pattern.features, @center.features)
    }
    sum
  end

end