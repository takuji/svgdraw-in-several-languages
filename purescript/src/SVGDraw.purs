module SVGDraw where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF, Ref, newRef, modifyRef, readRef)
import Control.Monad.Eff.Console (CONSOLE)
import DOM.Event.Types (Event)
import Graphics.D3 (Selection)
import Graphics.D3 (D3, select, append, setAttr, setStyle, on, mouse, elem) as D3
import Graphics.D3.SVG (Line, newLine) as D3.SVG
import Graphics.D3.SVG.Line (interpolate, setData) as D3.SVG.Line
-- import DOM.Event.Types (Event)
import DOM.Node.Types (Element)
import Data.Array (snoc)
-- import Data.Maybe (Maybe (..))
-- import Data.Either (Either (..))

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
  , selection :: Selection
  , svg :: Element
  , state :: State
  -- , image_url :: String
  }

type Point = Array Number

type Color = String

type Line = { points :: Array Point
            , color :: String
            , width :: Int
            , drawing :: Selection
            , pen :: D3.SVG.Line
            }

data State = WaitingState | DrawingState Line

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
          , selection: D3.select(params.el)
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
  s4 <- D3.setStyle "background-color" d.background_color c
  f <- D3.on "mousedown" (\evt -> onMouseDown draw evt) s4
  g <- D3.on "mousemove" (\e -> onMouseMove draw e) f
  h <- D3.on "mouseup" (\e -> onMouseUp draw e) g
  i <- D3.on "mouseleave" (\e -> onMouseLeave draw e) h
  -- d3.attr "width" (show d.width) <> "px"
  pure i

getMousePosition :: forall r. {svg :: Element | r} -> Point
getMousePosition draw = D3.mouse(draw.svg)

onMouseDown :: forall eff. Ref Draw -> Event -> Eff (ref :: REF, d3 :: D3.D3 | eff) Unit
onMouseDown draw evt = do
  d <- readRef draw
  case d.state of
    WaitingState -> do
      line <- addLine d
      modifyRef draw \d1 -> d1 { state = DrawingState line
                               , lines = snoc d1.lines line }
    DrawingState _ -> pure unit

onMouseUp :: forall eff. Ref Draw -> Event -> Eff (ref :: REF, d3 :: D3.D3 | eff) Unit
onMouseUp draw evt = do
  d <- readRef draw
  case d.state of
    WaitingState -> pure unit
    DrawingState line -> do
      updateLine line
      modifyRef draw \v -> v { state = WaitingState }

onMouseMove :: forall eff. Ref Draw -> Event -> Eff (ref :: REF, d3 :: D3.D3 | eff) Unit
onMouseMove draw evt = do
  d <- readRef draw
  case d.state of
    WaitingState -> pure unit
    DrawingState line -> do
      let pos = getMousePosition d
      let line' = line {points = snoc line.points pos}
      updateLine line'
      modifyRef draw \v -> v { state = DrawingState line' }

onMouseLeave :: forall eff. Ref Draw -> Event -> Eff (ref :: REF, d3 :: D3.D3 | eff) Unit
onMouseLeave draw evt = do
  d <- readRef draw
  case d.state of
    WaitingState -> pure unit
    DrawingState line -> do
      updateLine line
      modifyRef draw \v -> v { state = WaitingState }

setLineColor :: Color -> Draw -> Unit
setLineColor color draw = unit

addLine :: forall eff r. { line_color :: String, line_width :: Int, selection :: Selection | r } ->
                         Eff (ref :: REF, d3 :: D3.D3 | eff) Line
addLine draw = do
  let pen = D3.SVG.Line.interpolate "cardinal" D3.SVG.newLine
  let points = []
  d3line <- D3.append "path" draw.selection
  s1 <- D3.setAttr "data-line-id" "1" d3line
  s2 <- D3.setAttr "d" (D3.SVG.Line.setData points pen) s1
  s3 <- D3.setAttr "fill" "transparent" s2
  s4 <- D3.setAttr "stroke" draw.line_color s3
  pure { points: points, color: draw.line_color, width: 1, pen: pen, drawing: d3line }

updateLine :: forall eff. Line -> Eff (d3 :: D3.D3 | eff) Selection
updateLine line = do
  let _data = D3.SVG.Line.setData line.points line.pen
  D3.setAttr "d" _data line.drawing


-- State

-- class State where
--   mouseDownHandler :: State -> Event -> Unit
--   mouseUpHandler :: State -> Event -> Unit
--   mouseMoveHandler :: State -> Event -> Unit
--   mouseLeaveHandler :: State -> Event -> Unit

-- data WaitingState = WaitingState Draw
-- data DrawingState = DrawingState Draw

-- instance waitingState :: 