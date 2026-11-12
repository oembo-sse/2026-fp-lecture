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






