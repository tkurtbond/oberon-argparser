MODULE Err;

(* Text output to standard error, with the interface of Out (String, Char
   and Ln), for programs that write diagnostics apart from their output.
   Nothing is buffered.

   This is the poc version, over one write(2) as poc's Console does it.
   voc builds use ../Err.Mod, over voc's Platform.Write, which poc does
   not have; pocGNUmakefile puts this directory on poc's import path, and
   make install copies this file to the poc subdirectory of the first
   directory in OBERON_MODULES, for other repos' poc builds. *)

IMPORT SYSTEM;

CONST
  standardError = 2;
  newline = 0AX;

PROCEDURE ["C", "write"] SysWrite(descriptor: SYSTEM.INT32; buffer, count: SYSTEM.ADDRESS);

PROCEDURE Char*(ch: CHAR);
  VAR one: ARRAY 1 OF CHAR;
BEGIN
  one[0] := ch;
  SysWrite(standardError, SYSTEM.ADR(one), 1)
END Char;

(* The characters of s up to its terminating 0X, or all of s if it has
   none. *)
PROCEDURE String*(s: ARRAY OF CHAR);
  VAR length: LONGINT;
BEGIN
  length := 0;
  WHILE (length < LEN(s)) & (s[length] # 0X) DO INC(length) END;
  IF length > 0 THEN SysWrite(standardError, SYSTEM.ADR(s), SYSTEM.VAL(SYSTEM.ADDRESS, length)) END
END String;

PROCEDURE Ln*;
BEGIN
  Char(newline)
END Ln;

END Err.
