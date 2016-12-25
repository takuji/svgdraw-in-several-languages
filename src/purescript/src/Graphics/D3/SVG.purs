module Graphics.D3.SVG where

import Control.Monad.Eff (Eff)
import Graphics.D3 (Selection, D3)

newtype Line = Line Selection

foreign import newLine :: forall eff. Eff (d3 :: D3 | eff) Line
