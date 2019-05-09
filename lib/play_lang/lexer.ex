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
      "=" -> with_token(
          lex |> read_char(),
          new_token(t."ASSIGN", lex.ch)
        )
      ";" -> with_token(
          lex |> read_char(),
          new_token(t."SEMICOLON", lex.ch)
        )
      "(" -> with_token(
          lex |> read_char(),
          new_token(t."LPAREN", lex.ch)
        )
      ")" -> with_token(
          lex |> read_char(),
          new_token(t."RPAREN", lex.ch)
        )
      "," -> with_token(
          lex |> read_char(),
          new_token(t."COMMA", lex.ch)
        )
      "+" -> with_token(
          lex |> read_char(),
          new_token(t."PLUS", lex.ch)
        )
      "{" -> with_token(
          lex |> read_char(),
          new_token(t."LBRACE", lex.ch)
        )
      "}" -> with_token(
          lex |> read_char(),
          new_token(t."RBRACE", lex.ch)
        )
      0 -> with_token(
          lex |> read_char(),
          new_token(t."EOF", "")
        )
      ch ->
        cond do
          letter?(ch) ->
            %{
              lexer: next_lex,
              ident: ident
            } = read_identifier(lex)

            tok = new_token(Token.findIdent(ident), ident)
            with_token(next_lex, tok)
          digit?(ch) ->
            %{
              lexer: next_lex,
              number: number
            } = lex |> read_number()

            tok = new_token(t."INT", number)
            with_token(next_lex, tok)
          true ->
            token = new_token(t."ILLEGAL", ch)
            with_token(lex |> read_char(), token)
        end
    end
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
          ident: lex.input |> String.slice(start, lex.position - start),
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
          number: String.slice(lex.input, start, lex.position - start)
        }
    end
  end
end
