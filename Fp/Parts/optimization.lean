/-! # Optimization -/

def Exp.opt : Exp → Exp
  | .Add (.C i) (.C j) => .C (i + j)
  | .Add x (.C 0) => x
  | .Add (.C 0) x => x
  | .Sub x (.C 0) => x
  | .Sub (.C 0) x => .Minus x
  | .Sub (.C i) (.C j) => .C (i - j)
  | .Minus (.C i) => .C (- i)
  | .Minus (.Minus x) => x
  | .Minus x => .Minus x.opt
  | .Abs (.C i) => .C i.natAbs
  --
  | .Add a b => .Add a.opt b.opt
  | .Sub a b => .Sub a.opt b.opt
  | .Abs x => .Abs x.opt
  | .V s => .V s
  | .C c => .C c

theorem opt_sound (e : Exp) (env : Environment) : e.opt.sem env = e.sem env := by
  fun_induction opt e with grind [sem]

