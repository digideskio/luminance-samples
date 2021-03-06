import Common
import GHC.Generics ( Generic )
import Graphics.Luminance
import Linear

main :: IO ()
main = startup $ \window loop -> do
  triangle <- createGeometry vertices Nothing Triangle
  vs <- createStage VertexShader vsSource
  fs <- createStage FragmentShader fsSource
  colorBuffer :: Buffer RW (UB Color) <- createBuffer (newRegion 3)
  writeWhole colorBuffer (map UB colors)
  program <- createProgram [vs,fs] $ \uni -> uni (UniformBlockName "Colors")
  updateUniforms program (.= colorBuffer)
  loop $ do
    _ <- draw $ defaultFrameCmd [ShadingCmd program mempty [pureDraw (stdRenderCmd triangle)]]
    endFrame window

data Color = Color {
    colorsK   :: Float
  , colorsRGB :: V3 Float
  } deriving (Eq,Generic,Show)

instance UniformBlock Color where

colors :: [Color]
colors =
  [
    Color {
      colorsRGB = V3 1 0 0
    , colorsK = 1
    }
  , Color {
      colorsRGB = V3 0 1 0
    , colorsK = 1
    }
  , Color {
      colorsRGB = V3 0 0 1
    , colorsK = 1
    }
  ]


vertices :: [V 2 Float]
vertices =
  [
    vec2 (-0.5) (-0.5)
  , vec2 0 0.5
  , vec2 0.5 (-0.5)
  ]

vsSource :: String
vsSource = unlines
  [
    "in vec2 co;"
  , "out vec4 vertexColor;"

  , "struct Color {"
  , "  float colorsK;"
  , "  vec3 colorsRGB;"
  , "};"

  , "layout (std140) uniform Colors {"
  , "  Color colors[3];"
  , "};"

  , "void main() {"
  , "  gl_Position = vec4(co, 0., 1.);"
  , "  vertexColor = vec4(colors[gl_VertexID].colorsRGB * colors[gl_VertexID].colorsK, 1.);"
  , "}"
  ]

fsSource :: String
fsSource = unlines
  [
    "in vec4 vertexColor;"
  , "out vec4 frag;"

  , "void main() {"
  , "  frag = vertexColor;"
  , "}"
  ]
