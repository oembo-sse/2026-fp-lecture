/-! # Repeated optimization -/

def Exp.size (e : Exp) : Nat := e.compile.length

theorem size_opt_le (e : Exp) : e.opt.size < e.size ∨ e.opt = e := by
  fun_induction opt e with grind [size, compile]

def Exp.optAll (e : Exp) : Exp :=
  let e' := e.opt
  if _ : e ≠ e' then optAll e' else e
termination_by e.size
decreasing_by grind [size_opt_le]

theorem optAll_sound (e : Exp) (env : Environment) : e.optAll.sem env = e.sem env := by
  fun_induction optAll e with grind [opt_sound]

#graphviz do
  ex.ast
  ex.opt.ast
  ex.opt.opt.ast
  ex.optAll.ast

#eval compile ex
#eval compile ex.optAll

