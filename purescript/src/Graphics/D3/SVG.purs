module Graphics.D3.SVG where

import Graphics.D3 (Selection)

newtype Line = Line Selection

foreign import newLine :: Line
