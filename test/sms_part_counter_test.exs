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

  describe "GSM 7bit encoding SMS part counter" do
    test "a 160 length message is considered 1 part" do
      assert SmsPartCounter.gsm_part_count("Lorem ipsum dolor sit amet, \
consectetuer adipiscing elit. Aenean commodo ligula eget dolor. \
Aenean massa. Cum sociis natoque penatibus et magnis dis parturient.") == 1
    end

    test "a 170 length message is considered 2 part" do
      assert SmsPartCounter.gsm_part_count("Lorem ipsum dolor sit amet, \
consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean\
massa. Cum sociis natoque penatibus et magnis dis parturient montes, na") == 2
    end

    test "a 20 length message is considered 1 part" do
      assert SmsPartCounter.gsm_part_count("Lorem ipsum dolor si") == 1
    end

    test "a 306 length message is considered 2 part" do
      assert SmsPartCounter.gsm_part_count("Lorem ipsum dolor sit amet, \
consectetuer adipiscing elit. Aenean commodo ligula eget dolor. \
Aenean massa. Cum sociis natoque penatibus et magnis dis \
parturient montes, nascetur ridiculus mus. Donec quam felis, \
ultricies nec, pellentesque eu, pretium quis, sem. \
Nulla consequat massa quis enim. Donec pede j") == 2
    end
  end

  describe "Unicode 16bit encoding SMS part counter" do
    test "a 70 length message is considered 1 part" do
      assert SmsPartCounter.unicode_part_count("জীবের মধ্যে সবচেয়ে সম্পূর্ণতা মানুষের। কিন্তু সবচেয়ে অসম্পূর্ণ হয়েয়") ==
               1
    end

    test "a 20 length message is considered 1 part" do
      assert SmsPartCounter.unicode_part_count("জীবের মধ্যে সবচেয়ে সমা") == 1
    end

    test "a 80 length message is considered 2 part" do
      assert SmsPartCounter.unicode_part_count(
               "জীবের মধ্যে সবচেয়ে সম্পূর্ণতা মানুষের। কিন্তু সবচেয়ে অসম্পূর্ণ হয়ে সে জন্মগ্রহণ করে। বাঘ ভ"
             ) == 2
    end

    test "a 134 length message is considered 2 part" do
      assert SmsPartCounter.unicode_part_count("মধ্যে সবচেয়ে সম্পূর্ণতা মানুষের। \
কিন্তু সবচেয়ে অসম্পূর্ণ হয়ে সে জন্মগ্রহণ করে। বাঘ ভালুক তার জীবনযাত্রার পনেরো- আনা মূলধন নিয়ে আসে") == 2
    end

    test "a 138 length message is considered 3 part" do
      assert SmsPartCounter.unicode_part_count("জীবের মধ্যে সবচেয়ে সম্পূর্ণতা মানুষের। \
কিন্তু সবচেয়ে অসম্পূর্ণ হয়ে সে জন্মগ্রহণ করে। বাঘ ভালুক তার \
জীবনযাত্রার পনেরো- আনা মূলধন নিয়ে আসে প্রকৃতির মালখানা থেকে") == 3
    end
  end

  describe "automagically detect encoding of the message body" do
    test "can detect GSM 7bit" do
      assert SmsPartCounter.detect_encoding("abc dsc") == {:ok, "gsm_7bit"}
      refute SmsPartCounter.detect_encoding("abc") == {:ok, "unicode"}
    end

    test "can detect Unicode" do
      assert SmsPartCounter.detect_encoding("আমার") == {:ok, "unicode"}
    end

    test "can detect Unicode when mixed with GSM 7bit char" do
      assert SmsPartCounter.detect_encoding("abc আমার") == {:ok, "unicode"}
      assert SmsPartCounter.detect_encoding("আমার abc") == {:ok, "unicode"}
    end

    test "can detect backslash as GSM 7bit" do
      assert SmsPartCounter.detect_encoding("\\") == {:ok, "gsm_7bit"}
    end
  end

  describe "analyze/1" do
    test "can detect GSM 7bit encoding and count parts" do
      assert SmsPartCounter.analyze("Lorem ipsum dolor sit amet, \
consectetuer adipiscing elit. Aenean commodo ligula eget dolor. \
Aenean massa. Cum sociis natoque penatibus et magnis dis \
parturient montes, nascetur ridiculus mus. Donec quam felis, \
ultricies nec, pellentesque eu, pretium quis, sem. \
Nulla consequat massa quis enim. Donec pede j") == %{
               "encoding" => "gsm_7bit",
               "parts" => 2
             }
    end

    test "can detect Unicode 16 bit encoding and count parts" do
      assert SmsPartCounter.analyze("জীবের মধ্যে সবচেয়ে সম্পূর্ণতা মানুষের। \
কিন্তু সবচেয়ে অসম্পূর্ণ হয়ে সে জন্মগ্রহণ করে। বাঘ ভালুক তার \
জীবনযাত্রার পনেরো- আনা মূলধন নিয়ে আসে প্রকৃতির মালখানা থেকে") == %{
               "encoding" => "unicode",
               "parts" => 3
             }
    end
  end
end
