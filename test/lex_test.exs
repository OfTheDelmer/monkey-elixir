defmodule PlayLang.LexerTest do
  use ExUnit.Case
  doctest PlayLang

  alias PlayLang.{Lexer, Token}


  test "simple lexer" do
    input = "=+(){},;"

    tests = [
      {Token.tokens."ASSIGN", "="},
      {Token.tokens."PLUS", "+"},
      {Token.tokens."LPAREN", "("},
      {Token.tokens."RPAREN", ")"},
      {Token.tokens."LBRACE", "{"},
      {Token.tokens."RBRACE", "}"},
      {Token.tokens."COMMA", ","},
      {Token.tokens."SEMICOLON", ";"},
      {Token.tokens."EOF", ""},
    ]

    lex_start = Lexer.new(input)

    test_tokens(lex_start, tests)
  end


  test "advanced lexer" do
    input = """
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
    """

    tokens = Token.tokens

    tests = [
      {tokens."LET", "let"},
      {tokens."IDENT", "five"},
      {tokens."ASSIGN", "="},
      {tokens."INT", "5"},
      {tokens."SEMICOLON", ";"},

      {tokens."LET", "let"},
      {tokens."IDENT", "ten"},
      {tokens."ASSIGN", "="},
      {tokens."INT", "10"},
      {tokens."SEMICOLON", ";"},

      {tokens."LET", "let"},
      {tokens."IDENT", "add"},
      {tokens."ASSIGN", "="},
      {tokens."FUNCTION", "fn"},
      {tokens."LPAREN", "("},
      {tokens."IDENT", "x"},
      {tokens."COMMA", ","},
      {tokens."IDENT", "y"},
      {tokens."RPAREN", ")"},
      {tokens."LBRACE", "{"},
        {tokens."IDENT", "x"},
        {tokens."PLUS", "+"},
        {tokens."IDENT", "y"},
        {tokens."SEMICOLON", ";"},
      {tokens."RBRACE", "}"},
      {tokens."SEMICOLON", ";"},


      {tokens."LET", "let"},
      {tokens."IDENT", "result"},
      {tokens."ASSIGN", "="},
      {tokens."IDENT", "add"},
      {tokens."LPAREN", "("},
      {tokens."IDENT", "five"},
      {tokens."COMMA", ","},
      {tokens."IDENT", "ten"},
      {tokens."RPAREN", ")"},
      {tokens."SEMICOLON", ";"},

      {tokens."EOF", ""},
    ]

    lex_start = Lexer.new(input)

    test_tokens(lex_start, tests)
  end


  test "extended operators" do
    input = """
      !-/*5;
      5 < 10 > 5;
    """

    tokens = Token.tokens

    tests = [
      {tokens."BANG", "!"},
      {tokens."MINUS", "-"},
      {tokens."SLASH", "/"},
      {tokens."ASTERISK", "*"},
      {tokens."INT", "5"},
      {tokens."SEMICOLON", ";"},

      {tokens."INT", "5"},
      {tokens."LT", "<"},
      {tokens."INT", "10"},
      {tokens."GT", ">"},
      {tokens."INT", "5"},
      {tokens."SEMICOLON", ";"},

      {tokens."EOF", ""},
    ]

    lex_start = Lexer.new(input)

    test_tokens(lex_start, tests)
  end

  test "equalities" do
    input = """
      10 == 10;
      10 != 9;
    """
    tokens = Token.tokens

    tests = [
      {tokens."INT", "10"},
      {tokens."EQ", "=="},
      {tokens."INT", "10"},
      {tokens."SEMICOLON", ";"},

      {tokens."INT", "10"},
      {tokens."NOT_EQ", "!="},
      {tokens."INT", "9"},
      {tokens."SEMICOLON", ";"},

      {tokens."EOF", ""},
    ]

    lex_start = Lexer.new(input)

    test_tokens(lex_start, tests)
  end

  def test_tokens(lex_start, tests) do
    Enum.reduce(tests, lex_start, fn({
      expectedType,
      expectedLiteral
    }, prev_lex) ->
      %{
        token: token,
        lexer: lexer
      } = prev_lex |> Lexer.next_token()

      assert token.type == expectedType
      assert token.literal == expectedLiteral

      lexer
    end)
  end
end
