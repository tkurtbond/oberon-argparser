MODULE Folded;

(* A parser with a filter, which lowercases every argument before it is
   parsed, as a program on VAX/VMS must lowercase the options that DCL has
   made capitals; and a command whose parser has no filter, so it uses the
   main parser's. *)

IMPORT ArgParser, Out;

VAR
  parser, addParser: ArgParser.Parser;

PROCEDURE Lower*(VAR arg: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
  i := 0;
  WHILE (i < LEN(arg)) & (arg[i] # 0X) DO
    IF (arg[i] >= "A") & (arg[i] <= "Z") THEN
      arg[i] := CHR(ORD(arg[i]) - ORD("A") + ORD("a"))
    END;
    INC(i)
  END
END Lower;

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

PROCEDURE DoShortNameOnly*(): BOOLEAN;
BEGIN
  Out.String('DoShortNameOnly called.'); Out.Ln;
  RETURN TRUE
END DoShortNameOnly;

PROCEDURE DoLongNameOnly*(): BOOLEAN;
BEGIN
  Out.String('DoLongNameOnly called.'); Out.Ln;
  RETURN TRUE
END DoLongNameOnly;

PROCEDURE ArgHandler*(startIdx: INTEGER; VAR arg: ARRAY OF CHAR): BOOLEAN;
BEGIN
  Out.String('ArgHandler called at index '); Out.Int(startIdx, 0);
  Out.String(' with argument: "'); Out.String(arg); Out.String('"'); Out.Ln;
  RETURN TRUE
END ArgHandler;

PROCEDURE DoAddName*(VAR arg: ARRAY OF CHAR): BOOLEAN;
BEGIN
  Out.String('add: DoAddName called with "'); Out.String(arg); Out.String('"'); Out.Ln;
  RETURN TRUE
END DoAddName;

PROCEDURE AddArgHandler*(startIdx: INTEGER; VAR arg: ARRAY OF CHAR): BOOLEAN;
BEGIN
  Out.String('add: ArgHandler called at index '); Out.Int(startIdx, 0);
  Out.String(' with argument: "'); Out.String(arg); Out.String('"'); Out.Ln;
  RETURN TRUE
END AddArgHandler;

BEGIN
  addParser := ArgParser.NewParser("add [options] items...  Add items.", AddArgHandler);
  addParser.AddOption(ArgParser.MakeStringOption("n", "name", "Call callback on name argument.", DoAddName));

  parser := ArgParser.NewParser("folded [options] [add [options]] arguments...", ArgHandler);
  parser.filter := Lower;
  parser.AddOption(ArgParser.MakeStringOption("s", "string", "Call callback on string argument.", DoString));
  parser.AddOption(ArgParser.MakeIntOption("i", "integer", "Call callback on integer argument.", DoInteger, -100, 100));
  parser.AddOption(ArgParser.MakeOption("a", "", "Option with short name only.", DoShortNameOnly));
  parser.AddOption(ArgParser.MakeOption(0X, "long-name", "Option with long name only.", DoLongNameOnly));
  parser.AddCommand(ArgParser.MakeCommand("add", addParser));

  parser.ParseArguments(1)
END Folded.
