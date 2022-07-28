# SmsPartCounter ![Testing](https://github.com/m4hi2/sms-counter/workflows/Elixir%20CI/badge.svg?branch=master)

Counts the number of SMS parts based on GSM7Bit or UCS-2 Encoding used.
The lib can automatically detect the encoding used in the text and count how many chars are
used. Based on the number of the char and encoding used, it can easily figure out how many SMS
will a particular string might be.

## Installation

The package can be installed
by adding `sms_part_counter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sms_part_counter, "~> 0.1.2"}
  ]
end
```

## Usage

```elixir
iex> SmsPartCounter.analyze("blah blah blah")
%{
  "encoding" => "gsm_7bit",
  "parts" => 1
}
```
