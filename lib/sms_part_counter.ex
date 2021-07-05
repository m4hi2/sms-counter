defmodule SmsPartCounter do
  @moduledoc """
  Module for detecting which encoding is being used and the character count of SMS text.
  """

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

    cond do
      sms_char_count < 161 ->
        1

      sms_char_count > 160 ->
        div(sms_char_count, 153) + if rem(sms_char_count, 153) == 0, do: 0, else: 1
    end
  end
end
