require 'helper'

class TestHistory < Test::Unit::TestCase
  context "a new history" do
    setup do
      @h = LEAP::Motion::Utils::History.new(3)
    end

    should "be empty with a max_size of 3" do
      assert_equal 0, @h.size
      assert_equal 3, @h.max_size
    end

    should "have 3 elements" do
      @h << "one"
      @h << "two"
      @h << "three"
      assert_equal 3, @h.size
      assert_equal 3, @h.max_size
      assert_equal true, @h.include?("one")

      @h << "four"
      assert_equal 3, @h.size
      assert_equal 3, @h.max_size
      assert_equal false, @h.include?("one")
    end
  end
end
