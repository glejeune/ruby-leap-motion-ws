require 'helper'

class TestGesture < Test::Unit::TestCase
  context "gesture" do
    should "create a new Circle" do
      data = {"type" => "circle"}
      circle = LEAP::Motion::WS::Gesture.make_gesture data
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture)
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture::Circle)
    end

    should "create a new Swipe" do
      data = {"type" => "swipe"}
      circle = LEAP::Motion::WS::Gesture.make_gesture data
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture)
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture::Swipe)
    end

    should "create a new KeyTap" do
      data = {"type" => "keyTap"}
      circle = LEAP::Motion::WS::Gesture.make_gesture data
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture)
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture::KeyTap)
    end

    should "create a new screenTap" do
      data = {"type" => "screenTap"}
      circle = LEAP::Motion::WS::Gesture.make_gesture data
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture)
      assert_equal true, circle.is_a?(LEAP::Motion::WS::Gesture::ScreenTap)
    end

    should "raise an error" do
      assert_raise LEAP::Motion::WS::Gesture::Error do
        LEAP::Motion::WS::Gesture.make_gesture({})
      end
      assert_raise LEAP::Motion::WS::Gesture::Error do
        LEAP::Motion::WS::Gesture.make_gesture({"type" => "unknown"})
      end
    end
  end
end
