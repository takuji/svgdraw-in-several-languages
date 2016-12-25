module Graphics.D3.SVG.Line where

import Graphics.D3.SVG (Line)

foreign import interpolate :: String -> Line -> Line

foreign import setData :: forall a. Array a -> Line -> String

