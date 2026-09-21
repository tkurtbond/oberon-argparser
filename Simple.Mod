MODULE Simple;

IMPORT ArgParser, Out;

VAR
  parser: ArgParser.Parser;

(* --- Callback Handlers --- *)

PROCEDURE DoHelp*(): BOOLEAN;
BEGIN
  parser.Usage;
  RETURN FALSE (* Exit parser after displaying help *)
END DoHelp;

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

BEGIN
  (* Initialize Parser *)
  parser := ArgParser.NewParser("simple [options] arguments...", ArgHandler);

  (* Register Callback Options *)
  parser.AddOption(ArgParser.MakeOption("h", "help", "Display help message and exit.", DoHelp));
  parser.AddOption(ArgParser.MakeStringOption("s", "string", "Call callback on string argument.", DoString));
  parser.AddOption(ArgParser.MakeIntOption("i", "integer", "Call callback on integer argument.", DoInteger, -100, 100));
  parser.AddOption(ArgParser.MakeOption("a", "", "Option with short name only.", DoShortNameOnly));
  parser.AddOption(ArgParser.MakeOption(0X, "long-name", "Option with long name only.", DoLongNameOnly));

  Out.String("This is output from parsing the command line in SIMPLE."); Out.Ln;
  Out.Ln;

  (* Parse arguments starting from index 1 *)
  parser.ParseArguments(1);

END Simple.
