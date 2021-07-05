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

  def gsm_part_count(sms) when is_binary(sms) do
    cond do
      count(sms) < 161 ->
        1

      count(sms) > 160 ->
        div(count(sms), 153) + if rem(count(sms), 153) == 0, do: 0, else: 1
    end
  end
end
