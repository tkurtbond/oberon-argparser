MODULE Err;

(* Text output to standard error, with the interface of Out (String, Char
   and Ln), for programs that write diagnostics apart from their output.
   Nothing is buffered.

   This is the voc version, over voc's Platform.  poc has no Platform.Write,
   so there is a poc version, with the same interface, in poc-rtl/Err.Mod.
   make install copies this one to OBERON_MODULES, with ArgParser.Mod, and
   the poc one to its poc subdirectory, for other repos' poc builds. *)

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
