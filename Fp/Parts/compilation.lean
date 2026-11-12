/-! # Compilation -/

def Exp.compile : Exp → List Instruction
  | V x => [.READ x]
  | C i => [.PUSH i]
  | Add n m => .ADD :: m.compile ++ n.compile
  | Sub n m => .SUB :: m.compile ++ n.compile
  | Minus n => .SIGN :: n.compile
  | Abs n => .ABS :: n.compile

#eval ex.compile
#eval exec ex.compile ex.env

