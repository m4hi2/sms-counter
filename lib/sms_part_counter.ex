defmodule SmsPartCounter do
  @moduledoc """
  Module for detecting which encoding is being used and the character count of SMS text.
  """
  gsm_7bit_ext_chars =
    "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà" <>
      "^{}\\[~]|€"

  @gsm_7bit_char_set MapSet.new(String.codepoints(gsm_7bit_ext_chars))

  @gsm_single_length 160
  @gsm_multi_length 153
  @unicode_single_length 70
  @unicode_multi_length 67

  @doc """
  Counts the characters in a string.

  ## Examples

    iex> SmsPartCounter.count("Hello")
    5
    iex> SmsPartCounter.count("আম")
    2
  """
  @spec count(binary) :: integer()
  def count(str) when is_binary(str) do
    String.codepoints(str)
    |> Enum.count()
  end

  @doc """
  Counts the part of a message that's encoded with GSM 7 Bit encoding.
  The GSM 7 Bit Encoded messages have following length requirement:
  Signle SMS Part Length: 160 Chars
  Multi SMS Part Length: 153 Chars

  ## Examples

    iex> SmsPartCounter.gsm_part_count("asdf")
    1
  """
  @spec gsm_part_count(binary) :: integer()
  def gsm_part_count(sms) when is_binary(sms) do
    sms_char_count = count(sms)
    part_count(sms_char_count, @gsm_single_length, @gsm_multi_length)
  end

  @doc """
  Counts the part of a message that's encoded with Unicode encoding.
  The Unicode Encoded messages have following length requirement:
  Signle SMS Part Length: 70 Chars
  Multi SMS Part Length: 67 Chars

  ## Examples

    iex> SmsPartCounter.unicode_part_count("আমি")
    1
  """
  @spec unicode_part_count(binary) :: integer()
  def unicode_part_count(sms) when is_binary(sms) do
    sms_char_count = count(sms)
    part_count(sms_char_count, @unicode_single_length, @unicode_multi_length)
  end

  defp part_count(sms_char_count, single_count, multi_count) do
    cond do
      sms_char_count < single_count + 1 ->
        1

      sms_char_count > single_count ->
        div(sms_char_count, multi_count) +
          if rem(sms_char_count, multi_count) == 0, do: 0, else: 1
    end
  end

  @doc """
  Detects the encoding of the SMS message based on the charset of GSM 7 bit Encoding.
  It does a set difference between the characters in the sms and the gsm 7 bit encoding char set.

  ## Examples

    iex> SmsPartCounter.detect_encoding("adb abc")
    {:ok, "gsm_7bit"}
    iex> SmsPartCounter.detect_encoding("আমি")
    {:ok, "unicode"}

  """
  @spec detect_encoding(binary) :: {:ok | :error, Sting.t()}
  def detect_encoding(sms) when is_binary(sms) do
    sms_char_set = MapSet.new(String.codepoints(sms))

    diff = MapSet.difference(sms_char_set, @gsm_7bit_char_set)

    empty_map_set?(diff)
    |> case do
      true ->
        {:ok, "gsm_7bit"}

      false ->
        {:ok, "unicode"}

    end
  end

  defp empty_map_set?(map_set = %MapSet{}) do
    empty_map_set = MapSet.new

    map_set
    |> case do
    ^empty_map_set ->true
    _ -> false
    end
  end

  @doc """
  Detects the encoding of the SMS then counts the part, returns all information
  as a map of the following format:
  %{
    "encoding" => encoding,
    "parts" => part count
  }

  ## Examples

    iex> SmsPartCounter.count_parts("abc")
    %{
      "encoding" => "gsm_7bit",
      "parts" => 1
    }
  """
  @spec count_parts(binary) :: %{String.t() => String.t(), String.t() => integer()}
  def count_parts(sms) when is_binary(sms) do
    {:ok, encoding} = detect_encoding(sms)

    case encoding do
      "gsm_7bit" ->
        parts = gsm_part_count(sms)

        %{
          "encoding" => encoding,
          "parts" => parts
        }

      "unicode" ->
        parts = unicode_part_count(sms)

        %{
          "encoding" => encoding,
          "parts" => parts
        }
    end
  end
end
