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
  pure s 
    >>= D3.setAttr "width" ((show d.width) <> "px")
    >>= D3.setAttr "width" ((show d.width) <> "px")
    >>= D3.setAttr "height" ((show d.height) <> "px")
    >>= D3.setStyle "display" "inline-block"
    >>= D3.setStyle "background-color" d.background_color
    >>= D3.on "mousedown" (\e -> onMouseDown draw e)
    >>= D3.on "mousemove" (\e -> onMouseMove draw e)
    >>= D3.on "mouseup" (\e -> onMouseUp draw e)
    >>= D3.on "mouseleave" (\e -> onMouseLeave draw e)
  -- d3.attr "width" (show d.width) <> "px"
  -- pure i

getMousePosition :: forall r. {svg :: Element | r} -> Point
getMousePosition draw = D3.mouse(draw.svg)

onMouseDown :: Ref Draw -> Event -> Unit
onMouseDown draw evt = runEff do
  d <- readRef draw
  case d.state of
    WaitingState -> do
      line <- addLine d
      let p = getMousePosition d
      modifyRef draw \d1 -> d1 { state = DrawingState (addPoint p line)
                               , lines = snoc d1.lines line }
    DrawingState _ -> pure unit

onMouseUp :: Ref Draw -> Event -> Unit
onMouseUp draw evt = runEff do
  d <- readRef draw
  case d.state of
    WaitingState -> pure unit
    DrawingState line -> do
      updateLine line
      modifyRef draw \v -> v { state = WaitingState }

onMouseMove :: Ref Draw -> Event -> Unit
onMouseMove draw evt = runEff do
  d <- readRef draw
  case d.state of
    WaitingState -> pure unit
    DrawingState line -> do
      let pos = getMousePosition d
      let line' = line {points = snoc line.points pos}
      updateLine line'
      modifyRef draw \v -> v { state = DrawingState line' }

onMouseLeave :: Ref Draw -> Event -> Unit
onMouseLeave draw evt = runEff do
  d <- readRef draw
  case d.state of
    WaitingState -> pure unit
    DrawingState line -> do
      updateLine line
      modifyRef draw \v -> v { state = WaitingState }

setLineColor :: Color -> Draw -> Unit
setLineColor color draw = unit

addPoint :: Point -> Line -> Line
addPoint point line = line {points = snoc line.points point}

addLine :: forall eff r. { line_color :: String, line_width :: Int, selection :: Selection | r } ->
                         Eff (ref :: REF, d3 :: D3.D3 | eff) Line
addLine draw = do
  line <- D3.SVG.newLine
  let pen = D3.SVG.Line.interpolate "cardinal" line
  let points = []
  selLine <- D3.append "path" draw.selection
  pure selLine
    >>= D3.setAttr "data-line-id" "1"
    >>= D3.setAttr "d" (D3.SVG.Line.setData points pen)
    >>= D3.setAttr "fill" "transparent"
    >>= D3.setAttr "stroke" draw.line_color
  pure { points: points, color: draw.line_color, width: 1, pen: pen, drawing: selLine }

updateLine :: forall eff. Line -> Eff (d3 :: D3.D3 | eff) Selection
updateLine line = do
  let _data = D3.SVG.Line.setData line.points line.pen
  D3.setAttr "d" _data line.drawing

foreign import runEff :: forall a eff. Eff (eff) a -> Unit
