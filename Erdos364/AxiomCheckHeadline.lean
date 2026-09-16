/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Erdos364.Main
import Erdos364.C14
import Erdos364.Assembly14

/-! The 10^12 headline theorem and the two 10^14 facts a 16 GB machine can
build: the composition of the 3,204 chunk certificates and the conditional
headline theorem. `Erdos364.Main14` joins those two with the rung-table
kernel check `bTable1e14_eq`, which needs tens of GB; it is built by
`scripts/pod_final14.sh` and its record is `data/chunk_runs/cert_1e14_axioms.txt`.
This file compiles only when the modules above and every certificate chunk
they import are built; the certificates workflow runs it and fails otherwise. -/

#print axioms Erdos364.no_powerful_triple_up_to_1e12
#print axioms Erdos364.C14.all_chunks_pass
#print axioms Erdos364.no_powerful_triple_up_to_1e14_of
