# -*- coding: utf-8 -*-   

module Rbed
  class Fam
    def initialize
      @data = []
    end

    def load(filename)
      open(filename) do |input|
        struct = Struct.new("FamData", :family_id, :id, :paternal_id, :maternal_id, :sex, :phenotype)
        input.each_line do |line|
          line.chomp!
          f = struct.new(*line.split(/\s+/))
          f.sex = f.sex.to_i
          f.phenotype = f.phenotype.to_i
          @data.push(f)
        end
      end
    end

    def num_individuals
      return @data.size
    end

    def indivisuals
      return @data
    end

    def [](index)
      return @data[index]
    end
  end
end
