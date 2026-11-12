/-! # Visualization -/

open Graph in
def Exp.graph : Exp → GraphBuilder NodeId
  | .C c => node {label := toString c}
  | .V v => node {label := v}
  | .Add l r => do
    let id ← node {label := "_ + _"}
    edge id (← l.graph) ""; edge id (← r.graph) ""
    return id
  | .Sub l r => do
    let id ← node {label := "_ - _"}
    edge id (← l.graph) ""; edge id (← r.graph) ""
    return id
  | .Minus x => do
    let id ← node {label := "- _"}; edge id (← x.graph) ""; return id
  | .Abs x => do
    let id ← node {label := "abs _"}; edge id (← x.graph) ""; return id

def Exp.ast (e : Exp) : Graph.GraphBuilder Unit := do let _ ← e.graph

#graphviz ex.ast

