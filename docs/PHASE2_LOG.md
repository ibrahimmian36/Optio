# Phase 2 running log

2026-07-23 morning block (overnight trigger never fired; run stopped by Ibby at 141/320).

- step 1 Mod4.lean: not_powerful_of_two_mod_four, odd_of_powerful_triple — PROVED, gate-clean
- step 6 Witness.lean: generic witness lemma + five 10^12 middle kills — PROVED, gate-clean
- step 5 Tiling.lean: tilesFrom Bool fold + mem_of_tiles covering lemma — PROVED, gate-clean
- step 2 Representation.lean: odd_of_dvd_odd + exists_odd_sq_mul_cube (via Nat.sq_mul_squarefree_of_pos, sf | sq by factorization) — PROVED, gate-clean, hours not days
- step 3 Generator.lean COMPLETE: isqrt invariant, exact sqfree test, stream membership, acc monotonicity, stream-in-outer, mem_of_odd_powerful capstone — all PROVED, gate-clean (21 manifest entries)
- step 4 Sorted.lean COMPLETE: stream sorted/all-odd, merge mem+sorted (fueled invariant), round/all lemmas, scan mono+catches, checkChunk_sound capstone — all PROVED
- ALL SIX PROOF STEPS DONE, manifest 35 theorems, gate-clean, zero sorry
- 10^12 chunk set COMPLETE on pod 2026-07-22 13:47 UTC: 320/320 PASS, 0 fail (141 Mac + 179 pod), 57,652 kernel-s, peak 7.9GB; log = data/chunk_runs/1e12_pod.log
- step 7 code COMPLETE: Cert.lean spec, gen_certs.py -> 320 C12 modules + Table + all_chunks_pass, Assembly.lean (tiles/side/exp decides + headline-of, compiles locally 10s), Main.lean awaits pod build (-j6)
- 10^12 RUNG CERTIFIED 2026-07-22: Erdos364.no_powerful_triple_up_to_1e12 built on pod, axioms exactly {propext, Classical.choice, Quot.sound}, no sorry/native. 320 chunks + 35 lemmas. Evidence: data/chunk_runs/cert_1e12_axioms.txt. (all_chunks_pass needed forall_mem_cons chain + line-comment header, both fixed after the pod surfaced them.)
- phase 5 BTable.lean + TableGen.lean COMPLETE: mkBTable completeness + all-odd, outerFromTable stack through checkChunkT_sound — all PROVED first-day, manifest at 45, gate-clean
- phase 5 MEASURED: bTable1e12 eq 80.4s once; chunkT319 12.2s vs 305s certified (25x); merge attribution corrected (~4s); 10^8 smoke rung fully green vs mirrors
- phase 6 DONE: 320/320 chunkT PASS vs certified specs (diff empty), 2422 kernel-s vs 57652 (23.8x), wall 13.5min local; log data/chunk_runs/T12.log
- 10^14 STAGED while batch runs: 2 new witness kills, C14 modules (3204+Table+composition) via gen_lib14.py, Assembly14 headline-of PROVED locally (conditional on table eq + chunk certs), Main14 pod-only
