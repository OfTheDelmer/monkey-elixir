defmodule PlayLang.CLI.Commands do
  @fopts ["--file"]
  def execute(["lex" | args]) do
    fopts = args
        |> Enum.filter(fn (arg) ->
          String.starts_with?(arg, @fopts)
        end)

    try do
      fopt = Enum.fetch!(fopts, 0)
      fname = String.split(fopt, "=") |> Enum.fetch!(1)
      IO.puts("lexing...#{fname}")
      script = File.read!(fname)
      execute(["lex-script", script])
    rescue
      _e in Enum.OutOfBoundsError ->
        formatted_args = Enum.join(args, " ")
        IO.puts("Lex args did not include -f or --file: #{formatted_args}")
    end
  end

  def execute(["lex-script", script]) do

    tokens =
      PlayLang.Lexer.new(script) |> PlayLang.Lexer.read_tokens()


    Enum.each(tokens, fn (token) -> IO.inspect(token) end)
  end

  def execute([unknown | _args]) do
    IO.puts("Command not recognized: #{unknown}")
  end
end
