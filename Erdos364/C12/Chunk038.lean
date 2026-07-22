/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.Spike

namespace Erdos364.C12

set_option maxRecDepth 100000 in
theorem chunk_038 :
    Erdos364.Spike.checkChunk 14235591971 14992778026 1233 2497 [] = true := by
  decide +kernel

end Erdos364.C12
