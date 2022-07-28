defmodule SmsPartCounter.MixProject do
  use Mix.Project

  def project do
    [
      app: :sms_part_counter,
      version: "0.1.2",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/m4hi2/sms-counter",
      homepage_url: "https://github.com/m4hi2/sms-counter"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Counts the character usage of a SMS using GSM7Bit/UCS-2 encoding charset."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/m4hi2/sms-counter"}
    ]
  end
end
