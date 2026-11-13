/-! # Warmup -/

def append (a b : List Nat) : List Nat :=
  match a, b with
  | [], b => b
  | x::a, b => x :: append a b

theorem append_length : (append a b).length = a.length + b.length := by
  fun_induction append a b with grind

def reverse (a : List Nat) : List Nat :=
  match a with
  | [] => []
  | x::a => reverse a ++ [x]

theorem reverse_append : reverse (a ++ b) = reverse b ++ reverse a := by
  fun_induction reverse a with grind [reverse]

theorem reverse_reverse : reverse (reverse a) = a := by
  induction a with grind [reverse, reverse_append]

section

