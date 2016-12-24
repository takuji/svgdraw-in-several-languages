module Graphics.D3 where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF)
import DOM.Event.Types (Event)
import DOM.Node.Types (Element)

-- import DOM.Node.Types
foreign import data D3 :: !

foreign import data Selection :: *

foreign import select :: String -> Selection

elem :: Selection -> Element
elem sel = elemImpl sel

foreign import elemImpl :: Selection -> Element

foreign import setAttr :: forall eff. String -> String -> Selection -> Eff (d3 :: D3 | eff) Selection

foreign import setStyle :: forall eff. String -> String -> Selection -> Eff (d3 :: D3 | eff) Selection

foreign import on :: forall eff eff2. String ->
                                      (Event -> Eff (ref :: REF | eff2) Unit) ->
                                      Selection ->
                                      Eff (d3 :: D3, ref :: REF | eff) Selection

foreign import mouse :: Element -> Array Number

foreign import append :: forall eff. String -> Selection -> Eff (d3 :: D3 | eff) Selection
