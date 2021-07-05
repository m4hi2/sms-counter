defmodule SmsPartCounterTest do
  use ExUnit.Case
  doctest SmsPartCounter

  describe "can count how many characters are in a message" do
    test "can count english alphabet" do
      assert SmsPartCounter.count("abc") == 3
      assert SmsPartCounter.count("asdf") == 4
      assert SmsPartCounter.count("") == 0
    end

    test "can count unicode characters" do
      assert SmsPartCounter.count("কখগ") == 3
      assert SmsPartCounter.count("আমি") == 3
      assert SmsPartCounter.count("") == 0
    end

    test "can count string with space in it" do
      assert SmsPartCounter.count("abc acb") == 7
      assert SmsPartCounter.count("asdf asdf") == 9
      assert SmsPartCounter.count(" ") == 1
      assert SmsPartCounter.count("আমি তুমি") == 8
    end
  end
end
