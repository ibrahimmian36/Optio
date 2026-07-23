/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364
import Erdos364.Bridge

/-! # Automated whole-library axiom audit

`AxiomCheck.lean` is the curated manifest: every published theorem, listed
by name and `#print axioms`-ed for the record. A hand-maintained list has
one failure mode: a theorem added later can be forgotten and never
checked. This file removes that failure mode mechanically. At elaboration
time it walks every locally buildable module under `Erdos364.*`, finds
every theorem (and any `axiom` declaration, which would be worse),
recomputes each axiom closure from the compiled environment, and refuses
to compile unless everything depends on at most `propext`,
`Classical.choice`, and `Quot.sound`.

`sorry` (`sorryAx`) and `native_decide` (`Lean.ofReduceBool`,
`Lean.ofReduceNat`) lie outside that set, so either one fails this file by
construction. Scope: the certificate modules (`C12`, `C14`, `Main`,
`Main14`) build only on a large-memory machine; their axiom records are
the committed pod outputs in `data/chunk_runs/` and lie outside this
audit's import closure by design.
-/

open Lean in
run_cmd do
  let env ← getEnv
  let allowed : List Name := [``propext, ``Classical.choice, ``Quot.sound]
  let mut checked : Nat := 0
  let mut offenders : Array (Name × Array Name) := #[]
  let mut axiomDecls : Array Name := #[]
  for (modName, modData) in env.header.moduleNames.zip env.header.moduleData do
    unless Name.isPrefixOf `Erdos364 modName do continue
    for declName in modData.constNames do
      match env.find? declName with
      | some (.thmInfo _) =>
        let axs ← collectAxioms declName
        let bad := axs.filter (fun ax => !allowed.contains ax)
        checked := checked + 1
        unless bad.isEmpty do offenders := offenders.push (declName, bad)
      | some (.axiomInfo _) =>
        unless allowed.contains declName do axiomDecls := axiomDecls.push declName
      | _ => pure ()
  unless axiomDecls.isEmpty do
    throwError "AXIOM AUDIT: FAIL: axiom declarations in Erdos364 modules: {axiomDecls}"
  unless offenders.isEmpty do
    throwError
      "AXIOM AUDIT: FAIL: {offenders.size} theorem(s) beyond the allowed axioms: {offenders}"
  if checked == 0 then
    throwError "AXIOM AUDIT: FAIL: scanned zero theorems, the module filter is broken"
  logInfo
    m!"AXIOM AUDIT: PASS: {checked} theorems across all Erdos364 modules, axioms within {allowed}"
