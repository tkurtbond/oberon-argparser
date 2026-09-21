MODULE OneName;

(* Options that take an argument and have only a short name or only a long
   name, to test that errors about them show the one name they have. *)

IMPORT ArgParser, Out;

VAR
  parser: ArgParser.Parser;

PROCEDURE DoString*(VAR arg: ARRAY OF CHAR): BOOLEAN;
BEGIN
  Out.String('DoString called with "'); Out.String(arg); Out.String('"'); Out.Ln;
  RETURN TRUE
END DoString;

PROCEDURE DoInteger*(val: LONGINT): BOOLEAN;
BEGIN
  Out.String('DoInteger called with integer: '); Out.Int(val, 0); Out.Ln;
  RETURN TRUE
END DoInteger;

BEGIN
  parser := ArgParser.NewParser("onename [options]", NIL);

  parser.AddOption(ArgParser.MakeStringOption("t", "", "String option with short name only.", DoString));
  parser.AddOption(ArgParser.MakeStringOption(0X, "text", "String option with long name only.", DoString));
  parser.AddOption(ArgParser.MakeIntOption("n", "", "Integer option with short name only.", DoInteger, 0, 10));
  parser.AddOption(ArgParser.MakeIntOption(0X, "number", "Integer option with long name only.", DoInteger, 0, 10));

  parser.ParseArguments(1);
END OneName.
