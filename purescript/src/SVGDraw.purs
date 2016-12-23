module SVGDraw where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import DOM.Event.Types (Event)
import Graphics.D3 (Selection)
import Graphics.D3 (D3, select, setAttr, setStyle, on, mouse, elem) as D3
import DOM.Node.Types (Element)
import Data.Array (head)
import Data.Maybe (Maybe (..))
import Data.Either (Either (..))

type SVGDrawParams = {
  el :: String,
  width :: Int,
  height :: Int
}

type Draw =
  { width :: Int
  , height :: Int
  , el :: String
  , line_color :: String
  , line_width :: Int
  , background_color :: String
  , zoom :: Number
  , event_listeners :: Array Event
  , lines :: Array Line
  -- , selection :: Selection
  , svg :: Element
  , status :: State
  -- , image_url :: String
  -- pen: d3.svg.Line<[number, number]>;
  -- , current_line :: Selection
  }

type Point = Array Number

type Color = String

data State = State

data Line = Line

create :: forall eff. SVGDrawParams -> Eff (console :: CONSOLE, d3 :: D3.D3 | eff) Draw
create params = do
  let svg = D3.elem $ D3.select params.el
  let d = { width: params.width
          , height: params.height
          , el: params.el
          , line_color: "#000000"
          , line_width: 1
          , background_color: "#ffffff"
          , zoom: 1.0
          , event_listeners: []
          , lines: []
          , svg: svg
          , status: State
          }
  initCanvas d
  pure d

initCanvas :: forall eff. Draw -> Eff (d3 :: D3.D3 | eff) Selection
initCanvas d = do
  let s = D3.select d.el
  a <- D3.setAttr "width" ((show d.width) <> "px") s
  b <- D3.setAttr "height" ((show d.height) <> "px") a
  c <- D3.setStyle "display" "inline-block" b
  e <- D3.setStyle "background-color" d.background_color c
  f <- D3.on "mousedown" onMouseDown e
  g <- D3.on "mousemove" onMouseMove f
  h <- D3.on "mouseup" onMouseUp g
  i <- D3.on "mouseleave" onMouseLeave h
  -- d3.attr "width" (show d.width) <> "px"
  pure i

getMousePosition :: Draw -> Point
getMousePosition draw = D3.mouse(draw.svg)

onMouseDown :: forall a. a -> Unit
onMouseDown evt = unit

onMouseUp :: forall a. a -> Unit
onMouseUp evt = unit

onMouseMove :: forall a. a -> Unit
onMouseMove evt = unit

onMouseLeave :: forall a. a -> Unit
onMouseLeave evt = unit

setLineColor :: Color -> Draw -> Unit
setLineColor color draw = unit
