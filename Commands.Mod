MODULE Commands;

(* Example of a program with multiple commands, each with its own
   sub-parser, options, and argument handler. *)

IMPORT ArgParser, Out;

VAR
  parser, addParser, listParser: ArgParser.Parser;

(* --- Top level handlers --- *)

PROCEDURE DoHelp*(): BOOLEAN;
BEGIN
  parser.Usage;
  RETURN FALSE
END DoHelp;

PROCEDURE DoVerbose*(): BOOLEAN;
BEGIN
  Out.String('DoVerbose called.'); Out.Ln;
  RETURN TRUE
END DoVerbose;

PROCEDURE ArgHandler*(startIdx: INTEGER; VAR arg: ARRAY OF CHAR): BOOLEAN;
BEGIN
  Out.String('Top level ArgHandler called at index '); Out.Int(startIdx, 0);
  Out.String(' with argument: "'); Out.String(arg); Out.String('"'); Out.Ln;
  RETURN TRUE
END ArgHandler;

(* --- "add" command handlers --- *)

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

(* --- "list" command handlers --- *)

PROCEDURE DoListCount*(val: LONGINT): BOOLEAN;
BEGIN
  Out.String('list: DoListCount called with integer: '); Out.Int(val, 0); Out.Ln;
  RETURN TRUE
END DoListCount;

PROCEDURE ListArgHandler*(startIdx: INTEGER; VAR arg: ARRAY OF CHAR): BOOLEAN;
BEGIN
  Out.String('list: ArgHandler called at index '); Out.Int(startIdx, 0);
  Out.String(' with argument: "'); Out.String(arg); Out.String('"'); Out.Ln;
  RETURN TRUE
END ListArgHandler;

BEGIN
  addParser := ArgParser.NewParser("add [options] items...  Add items.", AddArgHandler);
  addParser.AddOption(ArgParser.MakeStringOption("n", "name", "Call callback on name argument.", DoAddName));

  listParser := ArgParser.NewParser("list [options] patterns...  List items.", ListArgHandler);
  listParser.AddOption(ArgParser.MakeIntOption("c", "count", "Call callback on count argument.", DoListCount, 0, 100));

  parser := ArgParser.NewParser("commands [options] [command [options]] arguments...", ArgHandler);
  parser.AddOption(ArgParser.MakeOption("h", "help", "Display help message and exit.", DoHelp));
  parser.AddOption(ArgParser.MakeOption("v", "verbose", "Call callback for verbose.", DoVerbose));
  parser.AddCommand(ArgParser.MakeCommand("add", addParser));
  parser.AddCommand(ArgParser.MakeCommand("list", listParser));

  parser.ParseArguments(1);

END Commands.
