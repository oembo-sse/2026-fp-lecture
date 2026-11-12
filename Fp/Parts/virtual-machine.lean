/-! # Virtual Machine -/

inductive Instruction where | ADD | SUB | SIGN | ABS | PUSH (value : Int) | READ (s : String)
deriving Repr
abbrev Stack := List Int

open Instruction in
def intpInstr (i : Instruction) (env : Environment) (st : Stack) : Stack :=
  match i, st with
  | ADD, n::m::rest => (m+n) ::rest
  | SUB, n::m::rest => (m-n) ::rest
  | SIGN, n::rest   => (-n)  ::rest
  | ABS, n::rest    => n.natAbs ::rest
  | PUSH n, _       => n::st
  | READ s, _       => env s::st
  | _, _ => []

def exec (insts : List Instruction) (env : Environment) : Stack :=
  insts.foldr (fun inst stack ↦ intpInstr inst env stack) []

