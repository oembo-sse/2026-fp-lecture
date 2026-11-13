/-! # Repeated optimization -/

def Exp.size (e : Exp) : Nat := e.compile.length

theorem size_red_le (e : Exp) : e.red.size < e.size ∨ e.red = e := by
  fun_induction red e with grind [size, compile]

def Exp.redAll (e : Exp) : Exp :=
  let e' := e.red
  if _ : e ≠ e' then redAll e' else e
termination_by e.size
decreasing_by grind [size_red_le]

theorem redAll_sound (e : Exp) (env : Environment) : e.redAll.sem env = e.sem env := by
  fun_induction redAll e with grind [red_sound]

#graphviz do
  ex.ast
  ex.red.ast
  ex.red.red.ast
  ex.redAll.ast

#eval compile ex
#eval compile ex.redAll

