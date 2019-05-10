defmodule PlayLang.Lexer do
  import PlayLang.Token

  alias PlayLang.Token

  defstruct [:input, :position, :read_position, :ch]

  alias __MODULE__

  def new(input) do
    %__MODULE__{
      input: input,
      position: 0,
      read_position: 0,
      ch: ""
    } |> read_char()
  end

  def read_char(lex) do
    ch =
      cond do
        lex.read_position >= String.length(lex.input) ->
          0
        true -> String.at(lex.input, lex.read_position)
      end

    %Lexer{
      ch: ch,
      position: lex.read_position,
      read_position: lex.read_position + 1,
      input: lex.input
    }
  end

  def next_token(lexer) do
    t = tokens()
    lex = skip_whitespace(lexer)

    case lex.ch do
      "=" -> lex_char(lex, t."ASSIGN")
      ";" -> lex_char(lex, t."SEMICOLON")
      "(" -> lex_char(lex, t."LPAREN")
      ")" -> lex_char(lex, t."RPAREN")
      "," -> lex_char(lex, t."COMMA")
      "+" -> lex_char(lex, t."PLUS")
      "-" -> lex_char(lex, t."MINUS")
      "!" -> lex_char(lex, t."BANG")
      "/" -> lex_char(lex, t."SLASH")
      "*" -> lex_char(lex, t."ASTERISK")
      "<" -> lex_char(lex, t."LT")
      ">" -> lex_char(lex, t."GT")
      "{" -> lex_char(lex, t."LBRACE")
      "}" -> lex_char(lex, t."RBRACE")
      0 -> lex_char(lex, t."EOF", "")
      ch ->
        cond do
          letter?(ch) ->
            lex_pattern(lex, &Lexer.read_identifier/1, &Token.findIdent/1)
          digit?(ch) ->
            lex_pattern(lex, &Lexer.read_number/1, fn (_n) -> t."INT" end)
          true ->
            lex_char(lex, t."ILLEGAL")
        end
    end
  end

  def lex_pattern(lex, reader, token_lookup) do
    %{
      lexer: next_lex,
      literal: literal
    } = reader.(lex)

    token = new_token(token_lookup.(literal), literal)
    with_token(next_lex, token)
  end

  def lex_char(lex, type) do
    lex_char(lex, type, lex.ch)
  end

  def lex_char(lex, type, ch) do
    with_token(
      lex |> read_char(),
      new_token(type, ch)
    )
  end

  def with_token(lexer, token) do
    %{
      lexer: lexer,
      token: token
    }
  end

  def new_token(type, ch) do
    %Token{
      type: type,
      literal: ch
    }
  end

  def read_tokens(lex) do
    read_tokens(lex, [])
  end

  def read_tokens(lex, tokens) do
    %{
      token: token,
      lexer: lexer
    } = lex |> Lexer.next_token()

    next_tokens = Enum.concat(tokens, [token])
    case token do
      %Token{type: "EOF"} -> next_tokens
      _ ->
        read_tokens(
          lexer,
          next_tokens
        )
    end
  end

  def letter?(ch) do
    "a" <= ch && ch <= "z" || "A" <= ch && ch <= "Z" || ch == "_"
  end

  def read_identifier(lex) do
    read_identifier(lex, lex.position)
  end

  def read_identifier(lex, start) do
    cond do
      letter?(lex.ch) ->
        lexer = lex |> read_char()
        read_identifier(lexer, start)
      true ->
        %{
          literal: lex.input |> String.slice(start, lex.position - start),
          lexer: lex
        }
    end
  end

  def skip_whitespace(lex) do
    cond do
      whitespace?(lex.ch) -> lex |> read_char() |> skip_whitespace()
      true -> lex
    end
  end

  def whitespace?(ch) do
    ch == " " || ch == "\t" || ch == "\n" || ch == "\f"
  end

  def digit?(ch) do
    "0" <= ch && ch <= "9"
  end

  def read_number(lex) do
    read_number(lex, lex.position)
  end

  def read_number(lex, start) do
    cond do
      digit?(lex.ch) ->
        lexer = lex |> read_char()
        read_number(lexer, start)
      true ->
        %{
          lexer: lex,
          literal: String.slice(lex.input, start, lex.position - start)
        }
    end
  end
end
