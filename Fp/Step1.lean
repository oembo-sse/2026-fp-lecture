import ProofWidgets.Component.HtmlDisplay

/-! # Lean lecture -/

section

/-! # Mini compiler project -/

/-! ## F# solution
```fsharp
type Exp = V of string
         | C of int
         | Add of Exp*Exp
         | Sub of Exp*Exp
         | Minus of Exp
         | Abs of Exp

type Environment = Map<string,int>

// sem : Environment -> Exp -> int
let rec sem env e =
  match e with
  | V x -> Map.find x env // will cause an error if variable not found
  | C i -> i
  | Add(n,m) -> sem env n + sem env m
  | Sub(n,m) -> sem env n - sem env m
  | Minus n -> - sem env n
  | Abs n -> abs (sem env n)

let env = Map.ofList [("x",3);("y",-3)]
let example = Add(Abs(Minus(C 7)), Sub(V "x", Minus(Add(C 2, V "y"))))
let test = sem env example
```
-/

inductive Exp where
  | V : String → Exp
  | C : Int → Exp
  | Add : Exp → Exp → Exp
  | Sub : Exp → Exp → Exp
  | Minus : Exp → Exp
  | Abs : Exp → Exp
deriving DecidableEq
open Exp

abbrev Environment := String → Int

def Exp.sem (env : Environment) (e : Exp) : Int :=
  match e with
  | V x => env x
  | C i => i
  | Add n m => sem env n + sem env m
  | Sub n m => sem env n - sem env m
  | Minus n => - sem env n
  | Abs n => (sem env n).natAbs

def ex : Exp := Add (Abs (Minus (C 7))) (Sub (V "x")  (Minus (Add (C 2) (V "y"))))
def ex.env : Environment
  | "x" => 3
  | "y" => -3
  | _ => 0
/-- info: 9 -/
#guard_msgs in #eval ex.sem ex.env

