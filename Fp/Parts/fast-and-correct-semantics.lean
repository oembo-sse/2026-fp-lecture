/-! # Fast and correct semantics -/

theorem sound_red_compile (e : Exp) (env : Environment) :
    exec e.redAll.compile env = [e.sem env] := by
  grind [exec_sound, redAll_sound]

def Exp.semFast (env : Environment) (e : Exp) : Int := (exec e.redAll.compile env).head?.getD 0

/-- A `@[csimp]` theorem replaces one definition by another during compilation time -/
@[csimp] theorem Exp.sem_eq_semFast : sem = semFast := by grind [semFast, sound_red_compile]
