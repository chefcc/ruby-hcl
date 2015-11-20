
class HCLLexer
option
  independent
  
macro
  NEWLINE               \n|\r
  BLANK                 \s+
  COMMENT               \#.*|\/\/.*$
  MCOMMENTIN            \/\*
  BOOL                  true|false
  NUMBER                -?\d+
  FLOAT                 \-?\d+\.\d+
  COMMA                 \,
  COMMAEND              \]
  IDENTIFIER            [a-zA-Z_][a-zA-Z0-9_]*
  EQUAL                 \=
  QUOTE                 \"
  MINUS                 \-
  LEFTBRACE             \{
  RIGHTBRACE            \}
  LEFTBRACKET           \[
  RIGHTBRACKET          \]

rule
# [:state]      pattern                   [actions]
#-------------------------------------------------------------------------------
                {BLANK}                   # ignore pattern
                {COMMENT}                 # ignore pattern
                {NEWLINE}                 # ignore pattern
#-------------------------------------------------------------------------------
                {MCOMMENTIN}              { consume_comment(text) }
                {BOOL}                    { [:BOOL,         to_boolean(text)]}
                {NUMBER}                  { [:NUMBER,       text.to_i] }
                {FLOAT}                   { [:FLOAT,        text.to_f] }
                {QUOTE}                   { [:STRING,       consume_string(text)] }
#-------------------------------------------------------------------------------
                {LEFTBRACE}               { [:LEFTBRACE,    text]}
                {RIGHTBRACE}              { [:RIGHTBRACE,   text]}
                {LEFTBRACKET}             { [:LEFTBRACKET,  text]}
                {RIGHTBRACKET}            { [:RIGHTBRACKET, text]}
#-------------------------------------------------------------------------------
                {COMMA}                   { [:COMMA,        text]}
                {IDENTIFIER}              { [:IDENTIFIER,   text]}
                {EQUAL}                   { [:EQUAL,        text]}
                {MINUS}                   { [:MINUS,        text]}


inner

  def lex(input)
    scan_setup(input)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end


  def to_boolean(input)
    input =
      if input =~ /true/
        true
      elsif input =~ /false/
        false
      end
    return input
  end


  def consume_comment(input)
    nested = 1

    until nested.zero?
      case(text = @ss.scan_until(%r{/\*|\*/|\z}) )
      when %r{/\*\z}
        nested =+ 1
      when %r{\*/\z}
        nested -= 1
      else
        break
      end
    end
  end


  def consume_string(input)
    result = ''
    nested = 0

    begin
      case(text = @ss.scan_until(%r{\"|\$\{|\}|\\}))
      when %r{\$\{\z}
        nested += 1
      when %r{\}\z}
        nested -= 1
      when %r{\\\z}
        result += text.chop + @ss.getch
        next
      end

      result += text
    end until nested == 0 && text =~ %r{\"\z}

    result.chop
  end


end
