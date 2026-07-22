/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.BTableData1e14
import Erdos364.TableGen

namespace Erdos364.C14

set_option maxRecDepth 100000 in
theorem chunk_1482 :
    Erdos364.Spike.checkChunkT 21421558925651 21450486572090 2500
      Erdos364.Spike.bTable1e14 [] = true := by
  decide +kernel

end Erdos364.C14
