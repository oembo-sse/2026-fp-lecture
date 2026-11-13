/-! # Optimization -/

def Exp.red : Exp → Exp
  | .Add (.C i) (.C j) => .C (i + j)
  | .Add x (.C 0) => x
  | .Add (.C 0) x => x
  | .Sub x (.C 0) => x
  | .Sub (.C 0) x => .Minus x
  | .Sub (.C i) (.C j) => .C (i - j)
  | .Minus (.C i) => .C (- i)
  | .Minus (.Minus x) => x
  | .Abs (.C i) => .C i.natAbs
  --
  | .Add a b => .Add a.red b.red
  | .Sub a b => .Sub a.red b.red
  | .Minus x => .Minus x.red
  | .Abs x => .Abs x.red
  | .V s => .V s
  | .C c => .C c

theorem red_sound (e : Exp) (env : Environment) : e.red.sem env = e.sem env := by
  fun_induction red e with grind [sem]

