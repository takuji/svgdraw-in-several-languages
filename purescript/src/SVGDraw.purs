module SVGDraw where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF, Ref, newRef, modifyRef, readRef)
import Control.Monad.Eff.Console (CONSOLE)
import DOM.Event.Types (Event)
import Graphics.D3 (Selection)
import Graphics.D3 (D3, select, setAttr, setStyle, on, mouse, elem) as D3
import DOM.Event.Types (Event)
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
  , state :: State
  -- , image_url :: String
  -- pen: d3.svg.Line<[number, number]>;
  -- , current_line :: Selection
  }

type Point = Array Number

type Color = String

data Line = Line

data State = WaitingState | DrawingState

create :: forall eff. SVGDrawParams ->
                      Eff (console :: CONSOLE, d3 :: D3.D3, ref :: REF | eff) Draw
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
          , state: WaitingState
          }
  initCanvas d
  pure d

initCanvas :: forall eff. Draw -> Eff (d3 :: D3.D3, ref :: REF | eff) Selection
initCanvas d = do
  let s = D3.select d.el
  draw <- newRef d
  a <- D3.setAttr "width" ((show d.width) <> "px") s
  b <- D3.setAttr "height" ((show d.height) <> "px") a
  c <- D3.setStyle "display" "inline-block" b
  e <- D3.setStyle "background-color" d.background_color c
  f <- D3.on "mousedown" (\evt -> onMouseDown draw evt) e
  g <- D3.on "mousemove" (\e -> onMouseMove draw e) f
  h <- D3.on "mouseup" (\e -> onMouseUp draw e) g
  i <- D3.on "mouseleave" (\e -> onMouseLeave draw e) h
  -- d3.attr "width" (show d.width) <> "px"
  pure i

getMousePosition :: Draw -> Point
getMousePosition draw = D3.mouse(draw.svg)

onMouseDown :: forall a eff. Ref Draw -> Event -> Eff (ref :: REF | eff) Unit
onMouseDown draw evt = do
  d <- readRef draw
  case d.state of
    WaitingState -> modifyRef draw \d -> d {state = DrawingState}
    DrawingState -> pure unit

onMouseUp :: forall a eff. Ref Draw -> Event -> Eff (ref :: REF | eff) Unit
onMouseUp draw evt = pure unit

onMouseMove :: forall a eff. Ref Draw -> Event -> Eff (ref :: REF | eff) Unit
onMouseMove draw evt = pure unit

onMouseLeave :: forall a eff. Ref Draw -> Event -> Eff (ref :: REF | eff) Unit
onMouseLeave draw evt = pure unit

setLineColor :: Color -> Draw -> Unit
setLineColor color draw = unit


-- State

-- class State where
--   mouseDownHandler :: State -> Event -> Unit
--   mouseUpHandler :: State -> Event -> Unit
--   mouseMoveHandler :: State -> Event -> Unit
--   mouseLeaveHandler :: State -> Event -> Unit

-- data WaitingState = WaitingState Draw
-- data DrawingState = DrawingState Draw

-- instance waitingState :: 