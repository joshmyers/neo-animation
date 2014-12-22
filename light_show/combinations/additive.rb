module LightShow
  class Additive < Combination
    def combine_values(values)
      sum = values.inject(:+)
      sum = 1 if sum > 1
      sum
    end
  end
end
