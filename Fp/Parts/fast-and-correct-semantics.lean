/-! # Fast and correct semantics -/

theorem sound_opt_compile (e : Exp) (env : Environment) :
    exec e.optAll.compile env = [e.sem env] := by
  grind [exec_sound, optAll_sound]

def Exp.semFast (env : Environment) (e : Exp) : Int := (exec e.optAll.compile env).head?.getD 0

/-- A `@[csimp]` theorem replaces one definition by another during compilation time -/
@[csimp] theorem Exp.sem_eq_semFast : sem = semFast := by grind [semFast, sound_opt_compile]
