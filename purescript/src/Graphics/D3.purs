module Graphics.D3 where

import Prelude
import Control.Monad.Eff (Eff)
import DOM.Event.Types (Event)
import DOM.Node.Types (Element)

-- import DOM.Node.Types
foreign import data D3 :: !

foreign import data Selection :: *

foreign import select :: String -> Selection

foreign import setAttr :: forall eff. String -> String -> Selection -> Eff (d3 :: D3 | eff) Selection

foreign import setStyle :: forall eff. String -> String -> Selection -> Eff (d3 :: D3 | eff) Selection

foreign import on :: forall eff. String -> (Event -> Unit) -> Selection -> Eff (d3 :: D3 | eff) Selection

foreign import mouse :: Element -> Array Number
