# -*- coding: utf-8 -*-   

module Rbed
  class Rbed
    attr_reader :bed, :bim, :fam

    def initialize(bed, bim, fam)
      @bed = bed
      @bim = bim
      @fam = fam
      @snp_index = nil
    end

    def snp
      return @bed.snp
    end

    def snp_id(id)
      @snp_index = make_snp_index if @snp_index.nil?
      i = @snp_index[id] or raise KeyError.new("snp not found: #{id}")
      return @bim[i]
    end

    private

    def make_snp_index
      h = {}
      @bim.snps.each_with_index do |snp, index|
        h[snp.id] = index
      end
      return h
    end
  end
end

