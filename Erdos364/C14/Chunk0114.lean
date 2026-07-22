/-
Copyright (c) 2026 Millennium Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Millennium Research (Ibby Mian), with Claude
-/
import Erdos364.BTableData1e14
import Erdos364.TableGen

namespace Erdos364.C14

set_option maxRecDepth 100000 in
theorem chunk_0114 :
    Erdos364.Spike.checkChunkT 127694019651 129947993290 2501
      Erdos364.Spike.bTable1e14 [] = true := by
  decide +kernel

end Erdos364.C14
