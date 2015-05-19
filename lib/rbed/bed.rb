# -*- coding: utf-8 -*-

module Rbed
  class Bed
    include Enumerable

    attr_reader :num_snps, :num_individuals

    def initialize(num_snps, num_individuals)
      @num_snps = num_snps
      @num_individuals = num_individuals

      q, r = (@num_individuals * NUM_BIT_PER_INDIV).divmod(BYTE_LEN)
      if r == 0
        @bytes_per_snp = q
      else
        @bytes_per_snp = q + 1
      end
    end

    def load(filename)
      open(filename) do |input|
        magic = input.read(2).unpack("CC")
        raise "Not BED file" unless bed_magic_bytes?(magic)
        mode = input.read(1)
        raise "Unsupport major mode" unless mode.unpack("C") == [1]
        @bytes = input.read
      end
    end

    def genotype(snp_index, indiv_index)
      index = get_byte_index(snp_index, indiv_index)
      byte = @bytes[index].ord

      if indiv_index < INDIV_PER_BYTE
        return get_genotype_from_byte(byte, indiv_index)
      end
      return get_genotype_from_byte(byte, indiv_index - INDIV_PER_BYTE)
    end

    def each(&block)
      @bytes.to_enum(:each_byte).each_slice(@bytes_per_snp) do |bs|
        a = []
        bs.each do |b|
          a.push(
            (b      & 0x03),
            (b >> 2 & 0x03),
            (b >> 4 & 0x03),
            (b >> 6 & 0x03)
          )
        end
        tail = a.size - @num_individuals 
        if tail
          a.slice!(@num_individuals, tail)
        end
        yield a
      end
    end

    def c_ext?
      return false
    end

    private

    NUM_BIT_PER_INDIV = 2
    BYTE_LEN = 8
    INDIV_PER_BYTE = 4

    def bed_magic_bytes?(magic)
      return magic == [0b01101100, 0b00011011]
    end

    def get_genotype_from_byte(byte, index)
      raise IndexError if index > 3 || index < 0
      return (byte >> (index << 1) & 0x03)
    end

    def get_byte_index(snp_index, indiv_index)
      raise IndexError if snp_index < 0 || snp_index >= @num_snps
      raise IndexError if indiv_index < 0 || indiv_index >= @num_individuals

      i = snp_index * @bytes_per_snp
      i += 1 if indiv_index >= INDIV_PER_BYTE
      return i
    end
  end
end
