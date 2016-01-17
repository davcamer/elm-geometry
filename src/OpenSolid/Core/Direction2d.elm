module OpenSolid.Core.Direction2d
  ( none
  , x
  , y
  , polar
  , components
  , normalDirection
  , transformedBy
  , placedOntoPlane
  , negated
  , times
  ) where


import OpenSolid.Core exposing (Direction2d, Transformation2d)


none: Direction2d
none =
  Direction2d 0 0


x: Direction2d
x =
  Direction2d 1 0


y: Direction2d
y =
  Direction2d 0 1


polar: Float -> Direction2d
polar angle =
  Direction2d (cos angle) (sin angle)


components: Direction2d -> (Float, Float)
components direction =
  (direction.x, direction.y)


normalDirection: Direction2d -> Direction2d
normalDirection direction =
  Direction2d (-direction.y) direction.x


transformedBy: Transformation2d -> Direction2d -> Direction2d
transformedBy =
  fst


placedOntoPlane: Plane3d -> Direction3d
placedOntoPlane =
  Vector2d.placedOntoPlane


negated: Direction2d -> Direction2d
negated =
  Vector2d.negated


times: Float -> Direction2d -> Vector2d
times =
  Vector2d.times