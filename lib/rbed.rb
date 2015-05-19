# -*- coding: utf-8 -*-   

require "rbed/version"
require "rbed/rbed"
require "rbed/fam"
require "rbed/bim"
begin
  require "rbed/bed.so"
rescue LoadError
  require "rbed/bed"
end

# monkypatching for ruby1.8
class String
  unless method_defined?(:getbyte)
    alias getbyte []
  end
end

module Rbed
  Homo1   = 0b00
  Hetero  = 0b10 # hetero and missing swap bit order
  Homo2   = 0b11
  Missing = 0b01

  def load(base_name)
    fam = Fam.new
    fam.load("#{base_name}.fam")

    bim = Bim.new
    bim.load("#{base_name}.bim")

    bed = Bed.new(bim.num_snps, fam.num_individuals)
    bed.load("#{base_name}.bed")

    return Rbed.new(bed, bim, fam)
  end
  module_function :load
end
