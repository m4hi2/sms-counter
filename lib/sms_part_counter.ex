defmodule SmsPartCounter do
  @moduledoc """
  Module for detecting which encoding is being used and the character count of SMS text.
  """
  gsm_7bit_ext_chars =
    "@£$¥èéùìòÇ\\nØø\\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\\\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà" <>
      "\\^{}\\\\\\[~\\]|€"

  @gsm_7bit_char_set MapSet.new(String.codepoints(gsm_7bit_ext_chars))

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
    String.Unicode.codepoints(str)
    |> Enum.count()
  end

  @spec gsm_part_count(binary) :: integer()
  def gsm_part_count(sms) when is_binary(sms) do
    sms_char_count = count(sms)
    part_count(sms_char_count, 160, 153)
  end

  @spec unicode_part_count(binary) :: integer()
  def unicode_part_count(sms) when is_binary(sms) do
    sms_char_count = count(sms)
    part_count(sms_char_count, 70, 67)
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

  @spec detect_encoding(binary) :: {:ok | :error, Sting.t()}
  def detect_encoding(sms) when is_binary(sms) do
    sms_char_set = MapSet.new(String.codepoints(sms))

    diff_count = MapSet.difference(sms_char_set, @gsm_7bit_char_set) |> Enum.count()

    cond do
      diff_count == 0 ->
        {:ok, "gsm_7bit"}

      diff_count > 0 ->
        {:ok, "unicode"}

      true ->
        {:error, "Can't detect encoding"}
    end
  end

  @spec analyze(binary) :: %{String.t() => String.t(), String.t() => integer()}
  def analyze(sms) when is_binary(sms) do
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
