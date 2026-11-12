/-! # Soundness of compilation -/

theorem exec_sound_aux (x : Exp) (env : Environment) (rest : List Instruction) :
    exec (x.compile ++ rest) env = [x.sem env] ++ exec rest env := by
  induction x generalizing rest env with grind [exec, compile, intpInstr, sem]

theorem exec_sound (x : Exp) (env : Environment) :
    exec x.compile env = [x.sem env] := by
  grind [exec_sound_aux x env [], exec]

