defmodule PlayLang.CLI do
  alias __MODULE__

  def main(args) do
    CLI.Commands.execute(args)
    IO.puts("WOoot!")
  end
end
