require 'ml_pattern'

# 已分類的群在這裡
class MLKmeansGroup

  # 群組的代表 ID
  attr_accessor :identifier
  # 在這群組裡的數據組
  attr_accessor :patterns
  # 這群組的中心點
  attr_accessor :center

  def initialize
    @patterns   = []
    @identifier = ""
  end

  def add_pattern(classified_pattern)
    @patterns << classified_pattern
  end

  def set_center(center)
    @center = center
  end

  def renew_center
    # TODO: to renew the center after classified groups

  end

  def remove_all_patterns
    @patterns.clear
  end

  def remove_center
    @center = nil
  end

end