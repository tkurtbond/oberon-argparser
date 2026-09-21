MODULE Args;

(* voc's Args interface (argc and Get), for programs built with poc.

   poc has no Args module.  Its Modules module has the same information,
   numbered the same way: argument 0 is the program's own name, and argc
   counts it.  Only used by pocGNUmakefile, which puts this directory on
   the import path; voc builds use voc's own Args. *)

IMPORT Modules;

VAR
  argc-: INTEGER;

PROCEDURE Get*(n: INTEGER; VAR val: ARRAY OF CHAR);
BEGIN
  Modules.GetArg(n, val)
END Get;

BEGIN
  argc := Modules.ArgCount
END Args.
