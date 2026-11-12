/-! # Virtual Machine -/

/-! ## F# solution
```fsharp
// Virtual Machine
type Instruction = | ADD | SUB | SIGN | ABS | PUSH of int
type Stack = int list

// intpInstr: Instruction -> Stack -> Stack
let intpInstr i st =
  match (i,st) with
  | (ADD,(n::m::rest)) -> m+n ::rest
  | (SUB,(n::m::rest)) -> m-n ::rest
  | (SIGN,(n::rest))   -> -n :: rest
  | (ABS,(n::rest))    -> (abs n)::rest
  | (PUSH n,_)         -> n::st
```
-/

inductive Instruction where
  | ADD | SUB | SIGN | ABS | PUSH (value : Int) | READ (s : String)
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

