module SVGDraw where

-- import Prelude

type SVGDrawParams = {
    el :: String,
    width :: Int,
    height :: Int
}

create :: SVGDrawParams -> String
create params = "hello"
 