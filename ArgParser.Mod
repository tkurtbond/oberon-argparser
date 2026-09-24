MODULE ArgParser;

IMPORT Args, Err, Out, Platform, Strings;

CONST
  NoArgOption* = 0;
  StringOption* = 1;
  IntOption* = 2;

  (* The most characters a String holds.  A command line argument longer
     than this is cut short when it is read, without any error, so a program
     that cannot allow that should check the length of its arguments. *)
  MaxStringLength* = 4095;

  (* The exit status for a mistake on the command line, such as an unknown
     option or a missing argument, as getopt and OCaml's Arg use; a
     program's other errors can then use 1. *)
  UsageErrorStatus* = 2;

TYPE
  String* = ARRAY MaxStringLength + 1 OF CHAR;

  OptionHandler* = PROCEDURE (): BOOLEAN;
  StringOptionHandler* = PROCEDURE (VAR arg: ARRAY OF CHAR): BOOLEAN;
  IntOptionHandler* = PROCEDURE (val: LONGINT): BOOLEAN;
  ArgumentHandler* = PROCEDURE (startIdx: INTEGER; VAR arg: ARRAY OF CHAR): BOOLEAN;

  Option* = POINTER TO OptionDesc;
  OptionDesc* = RECORD
    shortName*: CHAR;
    longName*: String;
    description*: String;
    argRequired*: BOOLEAN;
    kind*: INTEGER;

    (* Callbacks *)
    handler*: OptionHandler;
    stringHandler*: StringOptionHandler;
    intHandler*: IntOptionHandler;

    minInt*, maxInt*: LONGINT;
    next*: Option;
  END;

  Parser* = POINTER TO ParserDesc;
  Command* = POINTER TO CommandDesc;

  (* A command is a name and a sub-parser.  When a non-option argument
     matches the name, the rest of the command line is parsed by the
     sub-parser.  The description is in the sub-parser. *)
  CommandDesc* = RECORD
    name*: String;
    parser*: Parser;
    next*: Command;
  END;

  ParserDesc* = RECORD
    description*: String;
    argHandler*: ArgumentHandler;
    options*: Option;
    commands*: Command;  (* NIL if no commands were defined. *)
    parent: Parser;      (* The parser this is a command of, or NIL. *)
  END;

VAR
  (* Where the usage and error messages go: standard output for the usage
     a program asks for, as with --help, and standard error for an error
     and the usage after it.  UseOut and UseErr set them. *)
  WriteString: PROCEDURE (s: ARRAY OF CHAR);
  WriteChar: PROCEDURE (ch: CHAR);
  WriteLn: PROCEDURE;

(* --- Output --- *)

PROCEDURE UseOut;
BEGIN
  WriteString := Out.String; WriteChar := Out.Char; WriteLn := Out.Ln
END UseOut;

(* Out is flushed first, so that what the program has already written to
   standard output comes before the error when both go to one place. *)
PROCEDURE UseErr;
BEGIN
  Out.Flush;
  WriteString := Err.String; WriteChar := Err.Char; WriteLn := Err.Ln
END UseErr;

(* --- Helper Constructors --- *)

PROCEDURE NewOption*(short: CHAR; long, desc: ARRAY OF CHAR): Option;
VAR opt: Option;
BEGIN
  NEW(opt);
  opt.shortName := short;
  COPY(long, opt.longName);
  COPY(desc, opt.description);
  opt.argRequired := FALSE;
  opt.kind := NoArgOption;
  opt.next := NIL;
  RETURN opt
END NewOption;

PROCEDURE MakeOption*(short: CHAR; long, desc: ARRAY OF CHAR; handler: OptionHandler): Option;
VAR opt: Option;
BEGIN
  opt := NewOption(short, long, desc);
  opt.kind := NoArgOption;
  opt.handler := handler;
  RETURN opt
END MakeOption;

PROCEDURE MakeStringOption*(short: CHAR; long, desc: ARRAY OF CHAR; handler: StringOptionHandler): Option;
VAR opt: Option;
BEGIN
  opt := NewOption(short, long, desc);
  opt.kind := StringOption;
  opt.argRequired := TRUE;
  opt.stringHandler := handler;
  RETURN opt
END MakeStringOption;

PROCEDURE MakeIntOption*(short: CHAR; long, desc: ARRAY OF CHAR; handler: IntOptionHandler; min, max: LONGINT): Option;
VAR opt: Option;
BEGIN
  opt := NewOption(short, long, desc);
  opt.kind := IntOption;
  opt.argRequired := TRUE;
  opt.intHandler := handler;
  opt.minInt := min;
  opt.maxInt := max;
  RETURN opt
END MakeIntOption;

PROCEDURE NewParser*(desc: ARRAY OF CHAR; handler: ArgumentHandler): Parser;
VAR p: Parser;
BEGIN
  NEW(p);
  COPY(desc, p.description);
  p.argHandler := handler;
  p.options := NIL;
  p.commands := NIL;
  p.parent := NIL;
  RETURN p
END NewParser;

PROCEDURE MakeCommand*(name: ARRAY OF CHAR; parser: Parser): Command;
VAR cmd: Command;
BEGIN
  NEW(cmd);
  COPY(name, cmd.name);
  cmd.parser := parser;
  cmd.next := NIL;
  RETURN cmd
END MakeCommand;

PROCEDURE (p: Parser) AddOption*(opt: Option);
VAR cur: Option;
BEGIN
  IF p.options = NIL THEN
    p.options := opt
  ELSE
    cur := p.options;
    WHILE cur.next # NIL DO cur := cur.next END;
    cur.next := opt
  END
END AddOption;

(* Add a command, for programs that implement multiple commands. *)
PROCEDURE (p: Parser) AddCommand*(cmd: Command);
VAR cur: Command;
BEGIN
  cmd.parser.parent := p;
  IF p.commands = NIL THEN
    p.commands := cmd
  ELSE
    cur := p.commands;
    WHILE cur.next # NIL DO cur := cur.next END;
    cur.next := cmd
  END
END AddCommand;

(* --- Usage / Help Display --- *)

(* Show the description and options of one parser, without its commands. *)
PROCEDURE UsageOptions(p: Parser);
VAR opt: Option;
BEGIN
  IF p.description # "" THEN
    WriteString(p.description); WriteLn
  END;
  WriteLn;
  opt := p.options;
  WHILE opt # NIL DO
    WriteString("  ");
    IF opt.shortName # 0X THEN
      WriteChar("-"); WriteChar(opt.shortName);
      IF opt.argRequired THEN WriteString(" <arg>") END
    END;
    IF (opt.shortName # 0X) & (opt.longName # "") THEN WriteString(", ") END;
    IF opt.longName # "" THEN
      WriteString("--"); WriteString(opt.longName)
    END;
    IF opt.argRequired & (opt.longName # "") THEN WriteString(" <arg>") END;
    WriteLn;
    IF opt.description # "" THEN
      WriteString("      "); WriteString(opt.description); WriteLn
    END;
    opt := opt.next
  END
END UsageOptions;

(* Show the usage of p and its commands with the Write procedures. *)
PROCEDURE WriteUsage(p: Parser);
VAR cmd: Command;
BEGIN
  UsageOptions(p);
  cmd := p.commands;
  WHILE cmd # NIL DO
    WriteLn;
    WriteUsage(cmd.parser);
    cmd := cmd.next
  END
END WriteUsage;

(* Show the usage on standard output, as for --help. *)
PROCEDURE (p: Parser) Usage*;
BEGIN
  UseOut;
  WriteUsage(p)
END Usage;

(* Start an error message on standard error.  ErrorUsage and
   UsageErrorExit finish it. *)
PROCEDURE ErrorStart;
BEGIN
  UseErr;
  WriteString("Error: ")
END ErrorStart;

(* After an error, show on standard error the usage of the parser that
   found it and, if it is a command, the full usage of the main parser
   above it. *)
PROCEDURE ErrorUsage(p: Parser);
VAR main: Parser;
BEGIN
  WriteUsage(p);
  main := p;
  WHILE main.parent # NIL DO main := main.parent END;
  IF main # p THEN
    WriteLn;
    WriteUsage(main)
  END
END ErrorUsage;

(* End the program with UsageErrorStatus.  Platform.Exit is used rather
   than HALT, which in voc writes "Terminated by Halt(N)." to standard
   output.  Err is not buffered, but Out is flushed, because voc's
   Platform.Exit does not flush it, in case something wrote to it after
   UseErr. *)
PROCEDURE UsageErrorExit;
BEGIN
  Out.Flush;
  Platform.Exit(UsageErrorStatus)
END UsageErrorExit;

(* Convert s, an optionally signed decimal integer with optional leading
   blanks, to val.  Returns FALSE, with val set to 0, if s is not exactly
   such a number or if the number is too large for a LONGINT. *)
PROCEDURE StrToInt*(s: ARRAY OF CHAR; VAR val: LONGINT): BOOLEAN;
  VAR i, digit: LONGINT; neg: BOOLEAN;
BEGIN
  i := 0; val := 0; neg := FALSE;
  WHILE s[i] = " " DO INC(i) END;               (* skip leading blanks *)
  IF s[i] = "-" THEN neg := TRUE; INC(i)
  ELSIF s[i] = "+" THEN INC(i) END;
  IF (s[i] < "0") OR (s[i] > "9") THEN RETURN FALSE END;  (* no digits *)
  WHILE (s[i] >= "0") & (s[i] <= "9") DO
    digit := ORD(s[i]) - ORD("0");
    IF val > (MAX(LONGINT) - digit) DIV 10 THEN   (* would overflow *)
      val := 0;
      RETURN FALSE
    END;
    val := val * 10 + digit;
    INC(i)
  END;
  IF s[i] # 0X THEN val := 0; RETURN FALSE END;  (* trailing junk *)
  IF neg THEN val := -val END;
  RETURN TRUE
END StrToInt;

(* --- Dispatch Handling --- *)

(* Show the names of an option, as in the usage: -i, --integer. *)
PROCEDURE WriteOptionNames(opt: Option);
BEGIN
  IF opt.shortName # 0X THEN WriteChar("-"); WriteChar(opt.shortName) END;
  IF (opt.shortName # 0X) & (opt.longName # "") THEN WriteString(", ") END;
  IF opt.longName # "" THEN WriteString("--"); WriteString(opt.longName) END
END WriteOptionNames;

PROCEDURE DispatchOption(p: Parser; opt: Option; VAR arg: ARRAY OF CHAR): BOOLEAN;
VAR
  val: LONGINT;
BEGIN
  IF opt.kind = NoArgOption THEN
    IF opt.handler # NIL THEN RETURN opt.handler() END;
    RETURN TRUE
  ELSIF opt.kind = StringOption THEN
    IF opt.stringHandler # NIL THEN RETURN opt.stringHandler(arg) END;
  ELSIF opt.kind = IntOption THEN
    IF ~StrToInt(arg, val) THEN
      ErrorStart; WriteString("Invalid integer value for option ");
      WriteOptionNames(opt); WriteString(": "); WriteString(arg); WriteLn;
      ErrorUsage(p);
      UsageErrorExit
    END;
    IF (val < opt.minInt) OR (val > opt.maxInt) THEN
      ErrorStart; WriteString("Value out of range for option ");
      WriteOptionNames(opt); WriteChar("."); WriteLn;
      ErrorUsage(p);
      UsageErrorExit
    END;
    IF opt.intHandler # NIL THEN RETURN opt.intHandler(val) END;
  END;
  RETURN TRUE
END DispatchOption;

(* --- Option Search Helpers --- *)

PROCEDURE FindShortOption(p: Parser; ch: CHAR): Option;
VAR opt: Option;
BEGIN
  opt := p.options;
  WHILE opt # NIL DO
    IF opt.shortName = ch THEN RETURN opt END;
    opt := opt.next
  END;
  RETURN NIL
END FindShortOption;

PROCEDURE FindLongOption(p: Parser; name: ARRAY OF CHAR): Option;
VAR opt: Option;
BEGIN
  opt := p.options;
  WHILE opt # NIL DO
    IF opt.longName = name THEN RETURN opt END;
    opt := opt.next
  END;
  RETURN NIL
END FindLongOption;

PROCEDURE FindCommand(p: Parser; name: ARRAY OF CHAR): Command;
VAR cmd: Command;
BEGIN
  cmd := p.commands;
  WHILE cmd # NIL DO
    IF cmd.name = name THEN RETURN cmd END;
    cmd := cmd.next
  END;
  RETURN NIL
END FindCommand;

(* --- Parsing Execution --- *)

PROCEDURE (p: Parser) ParseArguments*(startIdx: INTEGER);
VAR
  i, numArgs: INTEGER;
  arg, optName, optArg, emptyArg: String;
  opt: Option;
  cmd: Command;
  cont, skipNext, dashDashSeen: BOOLEAN;
  eqIdx, ci, k: INTEGER;

  PROCEDURE ExtractEq(VAR src, name, val: ARRAY OF CHAR; VAR eqPos: INTEGER);
  VAR j, k: INTEGER;
  BEGIN
    j := 0; WHILE (src[j] # 0X) & (src[j] # "=") DO name[j] := src[j]; INC(j) END;
    name[j] := 0X;
    eqPos := j;
    IF src[j] = "=" THEN
      INC(j); k := 0;
      WHILE src[j] # 0X DO val[k] := src[j]; INC(j); INC(k) END;
      val[k] := 0X
    ELSE
      val[0] := 0X
    END
  END ExtractEq;

BEGIN
  numArgs := Args.argc;
  i := startIdx;
  cont := TRUE;
  skipNext := FALSE;
  dashDashSeen := FALSE;
  emptyArg := "";

  WHILE (i < numArgs) & cont DO
    IF skipNext THEN
      skipNext := FALSE
    ELSE
      Args.Get(i, arg);
      IF (arg = "--") & ~dashDashSeen THEN
        dashDashSeen := TRUE
      ELSIF dashDashSeen OR (arg[0] # "-") OR (arg[1] = 0X) THEN
        (* An ordinary argument.  A bare "-" is one too, not an option. *)
        cmd := FindCommand(p, arg);
        IF cmd # NIL THEN
          (* It IS a command: the sub-parser handles the rest of the
             command line, and we never continue once it returns. *)
          cmd.parser.ParseArguments(i + 1);
          cont := FALSE
        ELSIF p.argHandler # NIL THEN
          cont := p.argHandler(i, arg)
        END
      ELSIF (arg[0] = "-") & (arg[1] = "-") THEN
        (* Handle Long Option *)
        Strings.Delete(arg, 0, 2);
        ExtractEq(arg, optName, optArg, eqIdx);
        opt := FindLongOption(p, optName);
        IF opt # NIL THEN
          IF opt.argRequired THEN
            IF eqIdx < Strings.Length(arg) THEN
              cont := DispatchOption(p, opt, optArg)
            ELSIF i + 1 < numArgs THEN
              INC(i);
              Args.Get(i, optArg);
              cont := DispatchOption(p, opt, optArg)
            ELSE
              ErrorStart; WriteString("Argument required for option ");
              WriteOptionNames(opt); WriteLn;
              ErrorUsage(p);
              UsageErrorExit
            END
          ELSE
            cont := DispatchOption(p, opt, emptyArg)
          END
        ELSE
          ErrorStart; WriteString("Unknown option --"); WriteString(optName); WriteLn;
          ErrorUsage(p);
          UsageErrorExit
        END
      ELSE
        (* Handle Short Options, possibly clustered, as in -abc.  An option
           that takes an argument uses the rest of the cluster as its
           argument if there is any (-ifoo), or else the next command line
           argument (-i foo). *)
        ci := 1;
        WHILE (arg[ci] # 0X) & cont DO
          opt := FindShortOption(p, arg[ci]);
          IF opt = NIL THEN
            ErrorStart; WriteString("Unknown option -"); WriteChar(arg[ci]); WriteLn;
            ErrorUsage(p);
            UsageErrorExit
          ELSIF opt.argRequired THEN
            IF arg[ci + 1] # 0X THEN
              k := 0; INC(ci);
              WHILE arg[ci] # 0X DO optArg[k] := arg[ci]; INC(ci); INC(k) END;
              optArg[k] := 0X;
              cont := DispatchOption(p, opt, optArg)
            ELSIF i + 1 < numArgs THEN
              INC(i);
              Args.Get(i, optArg);
              INC(ci);
              cont := DispatchOption(p, opt, optArg)
            ELSE
              ErrorStart; WriteString("Argument required for option ");
              WriteOptionNames(opt); WriteLn;
              ErrorUsage(p);
              UsageErrorExit
            END
          ELSE
            cont := DispatchOption(p, opt, emptyArg);
            INC(ci)
          END
        END
      END
    END;
    INC(i)
  END
END ParseArguments;

BEGIN
  UseOut
END ArgParser.
