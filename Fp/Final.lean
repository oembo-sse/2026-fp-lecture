import ProofWidgets.Component.HtmlDisplay

/-! # Lean lecture -/

section

/-! # Graphviz widgets

This section adds commands to render graphs in the infoview (on the right) using Graphviz
-/

open ProofWidgets Jsx

structure Graphviz.Widget.Props where dot : String deriving Lean.Server.RpcEncodable
@[widget_module] meta def Graphviz.Widget : Component Graphviz.Widget.Props where
  javascript := "
import * as React from 'react';
const e = React.createElement;
import { useRpcSession, RpcContext, InteractiveCode, useAsync, mapRpcError } from '@leanprover/infoview';
import * as Viz from 'https://esm.run/@viz-js/viz';

const MarkingContext = React.createContext({});

export default function(props) {
  const [globalState, setGlobalState] = React.useState(props.kind?.Context?.state);
  const rs = React.useContext(RpcContext);
  const ref = React.useRef(null)
  React.useEffect(() => {
    Viz.instance().then(viz => {
      const svg = viz.renderSVGElement(props.dot)
      ref.current.innerHTML = ''
      ref.current.title = props.dot
      ref.current.appendChild(svg)
    }).catch(e => setDebug(JSON.stringify(e.toString())))
  }, [props.dot])
  return e('div', { ref })
}"

class Graphviz.ToDot (α : Type) (β : outParam Type) [Inhabited β] where dot : α → β → String
instance : Graphviz.ToDot String Unit := ⟨fun s _ ↦ s⟩
def Lean.SourceInfo.mkCanonical : SourceInfo → SourceInfo | .synthetic s e _ => .synthetic s e true | si => si
def Lean.Syntax.mkInfoCanonical : Syntax → Syntax | .missing => .missing | .node i k a => .node i.mkCanonical k a | .atom i v => .atom i.mkCanonical v | .ident i r v p => .ident i.mkCanonical r v p
def Lean.TSyntax.mkInfoCanonical {k} : TSyntax k → TSyntax k := (.mk ·.raw.mkInfoCanonical)

macro "#graphviz " dot:term : command => Lean.TSyntax.mkInfoCanonical <$> `(#html jsx%{<Graphviz.Widget dot={Graphviz.ToDot.dot $dot default} />})
#graphviz "digraph { a -> b }"

abbrev Graph.NodeId := Nat
structure Graph.Node where label : String deriving Inhabited, Repr

structure Graph where
  nodes : Array (Graph.NodeId × Graph.Node)
  edges : Array (Graph.NodeId × Graph.NodeId × String)
deriving Inhabited, Repr

namespace Graph

abbrev GraphBuilder x := StateM Graph x

def GraphBuilder.build (f : GraphBuilder Unit) : Graph := (f.run default).snd

def node (n : Node) : GraphBuilder NodeId := do
  let s ← get
  let id : NodeId := s.nodes.size
  set {s with nodes := s.nodes.push (id, n)}
  return id

def edge (a b : NodeId) (label : String) : GraphBuilder Unit := do
  let s ← get
  set {s with edges := s.edges.push (a, b, label)}

def dot (g : Graph) :=
  let nodes := g.nodes.map (fun (idx, n) ↦ s!"{idx} [label={n.label.quote}]")
  let edges := g.edges.map (fun (s, t, label) ↦ s!"  {s} -> {t} [label={label.quote}]")
  let font := "Fira Code"
  f!"digraph G \{
    bgcolor=\"transparent\"
    fontsize=\"10\"
    graph [fontname = {font.quote}, fontsize=\"10\", color=white, fontcolor=white]
    node [fontname = {font.quote}, fontsize=\"10\", shape=box, color=white, fontcolor=white, ordering=in]
    edge [fontname = {font.quote}, fontsize=\"10\", color=white, fontcolor=white]
{nodes.toList |> "\n".intercalate}
{edges.toList |> "\n".intercalate}
}"

instance : Graphviz.ToDot Graph Unit where dot g _ := g.dot.pretty
instance : Graphviz.ToDot (Graph.GraphBuilder Unit) Unit where dot g a := Graphviz.ToDot.dot g.build a

end Graph

end






/-! # F# solution

```fsharp
type Exp = V of string
         | C of int
         | Add of Exp*Exp
         | Sub of Exp*Exp
         | Minus of Exp
         | Abs of Exp

type Environment = Map<string,int>

// sem : Environment -> Exp -> int
let rec sem env e =
  match e with
  | V x -> Map.find x env // will cause an error if variable not found
  | C i -> i
  | Add(n,m) -> sem env n + sem env m
  | Sub(n,m) -> sem env n - sem env m
  | Minus n -> - sem env n
  | Abs n -> abs (sem env n)

let env = Map.ofList [("x",3);("y",-3)]
let example = Add(Abs(Minus(C 7)), Sub(V "x", Minus(Add(C 2, V "y"))))
let test = sem env example

// Virtual Machine
type Instruction = | ADD | SUB | SIGN | ABS | PUSH of int
type Stack = int list

// intpInstr: Instruction -> Stack -> Stack
let intpInstr i st =
  match (i,st) with
  | (ADD,(n::m::rest)) -> m+n ::rest
  | (SUB,(n::m::rest)) -> m-n ::rest
  | (SIGN,(n::rest))   -> -n :: rest
  | (ABS,(n::rest))    -> (abs n)::rest
  | (PUSH n,_)         -> n::st
```

-/

/-! # Mini compiler project -/

inductive Exp where
  | V : String → Exp
  | C : Int → Exp
  | Add : Exp → Exp → Exp
  | Sub : Exp → Exp → Exp
  | Minus : Exp → Exp
  | Abs : Exp → Exp
deriving DecidableEq
open Exp

abbrev Environment := String → Int

def Exp.sem (env : Environment) (e : Exp) : Int :=
  match e with
  | V x => env x
  | C i => i
  | Add n m => sem env n + sem env m
  | Sub n m => sem env n - sem env m
  | Minus n => - sem env n
  | Abs n => (sem env n).natAbs

def ex : Exp := Add (Abs (Minus (C 7))) (Sub (V "x")  (Minus (Add (C 2) (V "y"))))
def ex.env : Environment
  | "x" => 3
  | "y" => -3
  | _ => 0
/-- info: 9 -/
#guard_msgs in #eval ex.sem ex.env

/-! # Visualization -/

open Graph in
def Exp.graph (e : Exp) : GraphBuilder NodeId :=
  match e with
  | .C c => node {label := toString c}
  | .V v => node {label := v}
  | .Add l r => do
    let id ← node {label := "_ + _"}
    edge id (← l.graph) ""
    edge id (← r.graph) ""
    return id
  | .Sub l r => do
    let id ← node {label := "_ - _"}
    edge id (← l.graph) ""
    edge id (← r.graph) ""
    return id
  | .Minus x => do
    let id ← node {label := "- _"}
    edge id (← x.graph) ""
    return id
  | .Abs x => do
    let id ← node {label := "abs _"}
    edge id (← x.graph) ""
    return id
def Exp.ast (e : Exp) : Graph.GraphBuilder Unit := do let _ ← e.graph

#graphviz ex.ast

/-! # Virtual Machine -/

inductive Instruction where | ADD | SUB | SIGN | ABS | PUSH (value : Int) | READ (s : String)
deriving Repr
abbrev Stack := List Int

open Instruction in
def intpInstr (i : Instruction) (env : Environment) (st : Stack) : Stack :=
  match i, st with
  | ADD, n::m::rest => (m+n) ::rest
  | SUB, n::m::rest => (m-n) ::rest
  | SIGN, n::rest   => (-n)  ::rest
  | ABS, n::rest    => n.natAbs ::rest
  | PUSH n, _       => n::st
  | READ s, _       => env s::st
  | _, _ => []

def exec (insts : List Instruction) (env : Environment) : Stack :=
  insts.foldr (fun inst stack ↦ intpInstr inst env stack) []

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

/-! # Soundness of compilation -/

theorem exec_sound_aux (x : Exp) (env : Environment) (rest : List Instruction) :
    exec (x.compile ++ rest) env = [x.sem env] ++ exec rest env := by
  induction x generalizing rest env with grind [exec, compile, intpInstr, sem]

theorem exec_sound (x : Exp) (env : Environment) :
    exec x.compile env = [x.sem env] := by
  grind [exec_sound_aux x env [], exec]

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
  fun_induction opt e with grind [compile, sem]

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

/-! # Fast semantics -/

theorem final (e : Exp) (env : Environment) : exec e.optAll.compile env = [e.sem env] := by
  grind [exec_sound, optAll_sound]

def Exp.semFast (env : Environment) (e : Exp) : Int := (exec e.optAll.compile env).head?.getD 0

@[csimp]
theorem Exp.sem_eq_semFast : sem = semFast := by grind [semFast, final]
