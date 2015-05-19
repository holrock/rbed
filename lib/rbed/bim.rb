# -*- coding: utf-8 -*-   

module Rbed
  class Bim
    def initialize
      @data = []
    end

    def load(filename)
      open(filename) do |input|
        struct = Struct.new("BimData", :chromosome, :id, :distance, :posision, :allel1, :allel2)
        input.each_line do |line|
          line.chomp!
          a =  line.split(/\s+/)
          a[2] = a[2].to_i
          a[3] = a[3].to_i
          @data.push(struct.new(*a))
        end
      end
      @data.freeze
    end

    def num_snps
      return @data.size
    end

    def snps
      return @data
    end

    def [](index)
      return @data[index]
    end
  end
end
