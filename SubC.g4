grammar SubC;

// Parser rules
compilationUnit
    : translationUnit? EOF
    ;

translationUnit
    : externalDeclaration+
    ;

externalDeclaration
    : functionDefinition
    // | declaration // TODO: implement for struct and enum and typedef
    | ';' // stray ;
    ;

// ==== function begin ====
functionDefinition
    : functionDeclarationSpecifier* returnType Identifier '(' (parameterDeclaration (',' parameterDeclaration)*)? ')' compoundStatement
    ;

functionDeclarationSpecifier
    : 'extern'
    | 'static'
    | 'inline'
    | '_Noreturn'
    | '__inline__' // GCC extension
    | '__stdcall'
    // | gccAttributeSpecifier
    | '__declspec' '(' Identifier ')'
    ;

returnType
    : typeName
    ;

parameterDeclaration
    : typeName Identifier
    ;

compoundStatement
    : '{' (blockItem+)? '}'
    ;
// ==== function end ====

// ==== variable declaration begin =====
variableDeclaration
    : 'static'? typeName Identifier ('=' (primaryExpression | functionCallExpression))? ';'
    ;

primaryExpression
    : Identifier
    | Constant
    | StringLiteral+
    ;

functionCallExpression
    : Identifier '(' (expression (',' expression)*)? ')'
    ;
// ==== variable declaraction end ====

blockItem
    : statement
    | variableDeclaration
    ;

statement
    : compoundStatement
    | assignmentStatement
    ;

assignmentStatement
    : Identifier '=' expression ';'
    ;

expression
    : conditionalExpression
    ;

conditionalExpression
    : logicalOrExpression ('?' expression ':' conditionalExpression)?
    ;

logicalOrExpression
    : logicalAndExpression ('||' logicalAndExpression)*
    ;

logicalAndExpression
    : inclusiveOrExpression ('&&' inclusiveOrExpression)*
    ;

inclusiveOrExpression
    : exclusiveOrExpression ('|' exclusiveOrExpression)*
    ;

exclusiveOrExpression
    : andExpression ('^' andExpression)*
    ;

andExpression
    : equalityExpression ('&' equalityExpression)*
    ;

equalityExpression
    : relationalExpression (('==' | '!=') relationalExpression)*
    ;

relationalExpression
    : shiftExpression (('<' | '>' | '<=' | '>=') shiftExpression)*
    ;

shiftExpression
    : additiveExpression (('<<' | '>>') additiveExpression)*
    ;

additiveExpression
    : multiplicativeExpression (('+' | '-') multiplicativeExpression)*
    ;

multiplicativeExpression
    : castExpression (('*' | '/' | '%') castExpression)*
    ;

castExpression
    : '__extension__'? '(' typeName ')' castExpression
    | unaryExpression
    ;

unaryExpression
    : ('++' | '--' | 'sizeof')* (
        postfixExpression
        | unaryOperator castExpression
        | ('sizeof' | '_Alignof') '(' typeName ')'
    )
    ;

unaryOperator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

postfixExpression
    : primaryExpression (
        '[' expression ']'
        | ('.' | '->') Identifier
        | '++'
        | '--'
    )*
    ;

typeQualifier
    : 'const'
    | 'restrict'
    | 'volatile'
    | '_Atomic'
    ;

typeSpecifier
    : 'void'
    | 'char'
    | 'short'
    | 'int'
    | 'long'
    | 'float'
    | 'double'
    | 'signed'
    | 'unsigned'
    | '_Bool'
    | '_Complex'
    | '__m128'
    | '__m128d'
    | '__m128i'
    | '__extension__' '(' ('__m128' | '__m128d' | '__m128i') ')'
    // | atomicTypeSpecifier
    // | structOrUnionSpecifier
    // | enumSpecifier
    // | typedefName
    // | '__typeof__' '(' constantExpression ')' // GCC extension
    ;

typeName
    : specifierQualifierList abstractDeclarator?
    ;

specifierQualifierList
    : (typeSpecifier | typeQualifier) specifierQualifierList?
    ;

abstractDeclarator
    : pointer
    // | pointer? directAbstractDeclarator gccDeclaratorExtension*
    ;

pointer
    : (('*' | '^') typeQualifierList?)+ // ^ - Blocks language extension
    ;

typeQualifierList
    : typeQualifier+
    ;

// Lexer rules
Identifier
    : IdentifierNondigit (IdentifierNondigit | Digit)*
    ;

fragment IdentifierNondigit
    : Nondigit
    | UniversalCharacterName
    //|   // other implementation-defined characters...
    ;

fragment Nondigit
    : [a-zA-Z_]
    ;

fragment Digit
    : [0-9]
    ;

fragment UniversalCharacterName
    : '\\u' HexQuad
    | '\\U' HexQuad HexQuad
    ;

fragment HexQuad
    : HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit
    ;

fragment HexadecimalDigit
    : [0-9a-fA-F]
    ;

StringLiteral
    : EncodingPrefix? '"' SCharSequence? '"'
    ;

fragment EncodingPrefix
    : 'u8'
    | 'u'
    | 'U'
    | 'L'
    ;

fragment SCharSequence
    : SChar+
    ;

fragment SChar
    : ~["\\\r\n]
    | EscapeSequence
    | '\\\n'   // Added line
    | '\\\r\n' // Added line
    ;

fragment EscapeSequence
    : SimpleEscapeSequence
    | OctalEscapeSequence
    | HexadecimalEscapeSequence
    | UniversalCharacterName
    ;

fragment SimpleEscapeSequence
    : '\\' ['"?abfnrtv\\]
    ;

fragment OctalEscapeSequence
    : '\\' OctalDigit OctalDigit? OctalDigit?
    ;

fragment HexadecimalEscapeSequence
    : '\\x' HexadecimalDigit+
    ;

Constant
    : IntegerConstant
    | FloatingConstant
    //|   EnumerationConstant
    | CharacterConstant
    ;

fragment IntegerConstant
    : DecimalConstant IntegerSuffix?
    | OctalConstant IntegerSuffix?
    | HexadecimalConstant IntegerSuffix?
    | BinaryConstant
    ;

fragment BinaryConstant
    : '0' [bB] [0-1]+
    ;

fragment DecimalConstant
    : NonzeroDigit Digit*
    ;

fragment OctalConstant
    : '0' OctalDigit*
    ;

fragment HexadecimalConstant
    : HexadecimalPrefix HexadecimalDigit+
    ;

fragment HexadecimalPrefix
    : '0' [xX]
    ;

fragment NonzeroDigit
    : [1-9]
    ;

fragment OctalDigit
    : [0-7]
    ;

fragment IntegerSuffix
    : UnsignedSuffix LongSuffix?
    | UnsignedSuffix LongLongSuffix
    | LongSuffix UnsignedSuffix?
    | LongLongSuffix UnsignedSuffix?
    ;

fragment UnsignedSuffix
    : [uU]
    ;

fragment LongSuffix
    : [lL]
    ;

fragment LongLongSuffix
    : 'll'
    | 'LL'
    ;

fragment FloatingConstant
    : DecimalFloatingConstant
    | HexadecimalFloatingConstant
    ;

fragment DecimalFloatingConstant
    : FractionalConstant ExponentPart? FloatingSuffix?
    | DigitSequence ExponentPart FloatingSuffix?
    ;

fragment FloatingSuffix
    : [flFL]
    ;

fragment FractionalConstant
    : DigitSequence? '.' DigitSequence
    | DigitSequence '.'
    ;

fragment ExponentPart
    : [eE] Sign? DigitSequence
    ;

fragment Sign
    : [+-]
    ;

DigitSequence
    : Digit+
    ;

fragment HexadecimalFloatingConstant
    : HexadecimalPrefix (HexadecimalFractionalConstant | HexadecimalDigitSequence) BinaryExponentPart FloatingSuffix?
    ;

fragment HexadecimalFractionalConstant
    : HexadecimalDigitSequence? '.' HexadecimalDigitSequence
    | HexadecimalDigitSequence '.'
    ;

fragment HexadecimalDigitSequence
    : HexadecimalDigit+
    ;

fragment BinaryExponentPart
    : [pP] Sign? DigitSequence
    ;

fragment CharacterConstant
    : '\'' CCharSequence '\''
    | 'L\'' CCharSequence '\''
    | 'u\'' CCharSequence '\''
    | 'U\'' CCharSequence '\''
    ;

fragment CCharSequence
    : CChar+
    ;

fragment CChar
    : ~['\\\r\n]
    | EscapeSequence
    ;
