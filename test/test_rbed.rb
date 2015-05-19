# -*- coding: utf-8 -*-

require 'minitest_helper'
Rbed.send(:remove_const, :Bed) if Rbed.const_defined?(:Bed)
require 'rbed/bed.rb'

class TestRbed < Minitest::Test
  def setup
    @bed = Rbed::Bed.new(3, 6)
  end

  def test_that_it_has_a_version_number
    refute_nil ::Rbed::VERSION
  end

  def test_c_ext
    assert_equal(false, @bed.c_ext?)
  end

  def test_getterinterface
    assert_equal(3, @bed.num_snps)
    assert_equal(6, @bed.num_individuals)
  end

  def test_match_bed_magic
    assert(@bed.send(:bed_magic_bytes?, [0b01101100, 0b00011011]))
    assert_equal(false, @bed.send(:bed_magic_bytes?, [0b01101100, 0b00011010]))
  end

  def test_unmatch_bed_magic
    assert_equal(false, @bed.send(:bed_magic_bytes?, [0b01101100, 0b00011010]))
  end

  def test_get_genotype
    assert_equal(Rbed::Homo1,   @bed.send(:get_genotype_from_byte, 0b11011100, 0))
    assert_equal(Rbed::Homo2,   @bed.send(:get_genotype_from_byte, 0b01101100, 1))
    assert_equal(Rbed::Hetero,  @bed.send(:get_genotype_from_byte, 0b01101100, 2))
    assert_equal(Rbed::Missing, @bed.send(:get_genotype_from_byte, 0b01101100, 3))
  end

  def test_get_byte_index
    assert_equal(0, @bed.send(:get_byte_index, 0, 0))
    assert_equal(2, @bed.send(:get_byte_index, 1, 0))
    assert_equal(5, @bed.send(:get_byte_index, 2, 4))
  end

  def test_each
    @bed.load("test/data/test.bed")
    assert_respond_to(@bed, :each)
    a = @bed.to_a
    b = [[0, 3, 1, 3, 3, 3],
         [3, 1, 2, 3, 3, 3],
         [3, 2, 2, 1, 1, 0]]
    assert_equal(b, a)
  end
end
