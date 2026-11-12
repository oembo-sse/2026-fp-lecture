/-! # Fast semantics -/

theorem final (e : Exp) (env : Environment) : exec e.optAll.compile env = [e.sem env] := by
  grind [exec_sound, optAll_sound]

def Exp.semFast (env : Environment) (e : Exp) : Int := (exec e.optAll.compile env).head?.getD 0

@[csimp]
theorem Exp.sem_eq_semFast : sem = semFast := by grind [semFast, final]
