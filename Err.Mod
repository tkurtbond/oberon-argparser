MODULE Err;

(* Text output to standard error, with the interface of Out (String, Char
   and Ln), for programs that write diagnostics apart from their output.
   Nothing is buffered.

   This is for voc builds, over voc's Platform; make install copies it to
   OBERON_MODULES, with ArgParser.Mod.  poc builds use the Err of poc's
   runtime library, which has the same procedures. *)

IMPORT SYSTEM, Platform;

PROCEDURE Char*(ch: CHAR);
  VAR one: ARRAY 1 OF CHAR; res: Platform.ErrorCode;
BEGIN
  one[0] := ch;
  res := Platform.Write(Platform.StdErr, SYSTEM.ADR(one), 1)
END Char;

(* The characters of s up to its terminating 0X, or all of s if it has
   none. *)
PROCEDURE String*(s: ARRAY OF CHAR);
  VAR length: LONGINT; res: Platform.ErrorCode;
BEGIN
  length := 0;
  WHILE (length < LEN(s)) & (s[length] # 0X) DO INC(length) END;
  IF length > 0 THEN res := Platform.Write(Platform.StdErr, SYSTEM.ADR(s), length) END
END String;

PROCEDURE Ln*;
BEGIN
  Char(0AX)
END Ln;

END Err.
