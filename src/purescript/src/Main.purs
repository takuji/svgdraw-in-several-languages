module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Ref (REF)

import SVGDraw as SVGDraw
import Graphics.D3 (D3)

main :: forall e. Eff (console :: CONSOLE, d3 :: D3, ref :: REF | e) Unit
main = void do
  SVGDraw.create {el: "#draw", width: 800, height: 600}
