# -*- coding: utf-8 -*-   
#
module Rbed
  class Reader

    def initialize(base_name)
      @base_name = base_name
    end

    def load
      fam = Fam.new
      fam.load("#{@base_name}.fam")

      bim = Bim.new
      bim.load("#{@base_name}.bim")

      bed = Bed.new(bim.num_snps, fam.num_individuals)
      bed.load("#{@base_name}.bed")

      return [fam, bim, bed]
    end
  end
end
