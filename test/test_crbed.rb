require 'minitest_helper'

class TestCRbed < Minitest::Test
  def setup
    @bed = Rbed::Bed.new(3, 6)
  end

  def test_c_ext
    assert_equal(true, @bed.c_ext?)
  end

  def test_getterinterface
    assert_equal(3, @bed.num_snps)
    assert_equal(6, @bed.num_individuals)
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
