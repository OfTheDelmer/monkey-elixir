defmodule PlayLang.Token do
  defstruct [:type, :literal]

  @tokens %{
    ILLEGAL: "ILLEGAL",
    EOF: "EOF",

    IDENT: "IDENT",
    INT: "INT",

    ASSIGN: "ASSIGN",
    PLUS: "PLUS",

    COMMA: ",",
    SEMICOLON: ";",

    LPAREN: "(",
    RPAREN: ")",
    LBRACE: "{",
    RBRACE: "}",

    FUNCTION: "FUNCTION",
    LET: "LET"
  }

  @keywords %{
    "fn" => @tokens."FUNCTION",
    "let" => @tokens."LET"
  }

  def tokens do
     @tokens
  end

  def findIdent(ident) do
    case Map.fetch(@keywords, ident) do
      {:ok, token_type} -> token_type
      _ -> @tokens."IDENT"
    end
  end
end
