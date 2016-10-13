{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module OpenSolid.Frame2d
    exposing
        ( xy
        , at
        , originPoint
        , xDirection
        , yDirection
        , xAxis
        , yAxis
        , flipX
        , flipY
        , moveTo
        , rotateBy
        , rotateAround
        , translateBy
        , translateAlongOwn
        , mirrorAcross
        , relativeTo
        , placeIn
        )

{-| Various functions for creating and working with `Frame2d` values. For the
examples below, assume that all OpenSolid core types have been imported using

    import OpenSolid.Core.Types exposing (..)

and all necessary modules have been imported using the following pattern:

    import OpenSolid.Frame2d as Frame2d

Examples use `==` to indicate that two expressions are equivalent, even if (due
to numerical roundoff) they might not be exactly equal.

# Predefined frames

@docs xy

# Constructors

Frames can by constructed by passing a record with `originPoint`, `xDirection`
and 'yDirection' fields to the `Frame2d` constructor, for example:

    frame =
        Frame2d
            { originPoint = Point2d ( 2, 3 )
            , xDirection = Direction2d.fromAngle (degrees 45)
            , yDirection = Direction2d.fromAngle (degrees 135)
            }

In this case you must be careful to ensure that the X and Y directions are
perpendicular to each other.

@docs at

# Accessors

@docs originPoint, xDirection, yDirection, xAxis, yAxis

# Transformations

@docs flipX, flipY, moveTo, rotateBy, rotateAround, translateBy, translateAlongOwn, mirrorAcross

# Coordinate frames

@docs relativeTo, placeIn
-}

import OpenSolid.Core.Types exposing (..)
import OpenSolid.Point2d as Point2d
import OpenSolid.Direction2d as Direction2d
import OpenSolid.Axis2d as Axis2d


{-| The global XY frame.

    Frame2d.xy ==
        Frame2d
            { originPoint = Point2d.origin
            , xDirection = Direction2d.x
            , yDirection = Direction2d.y
            }
-}
xy : Frame2d
xy =
    at Point2d.origin


{-| Construct a frame aligned with the global XY frame but with the given point
as its origin point.

    Frame2d.at (Point2d ( 2, 3 )) ==
        Frame2d
            { originPoint = Point2d ( 2, 3 )
            , xDirection = Direction2d.x
            , yDirection = Direction2d.y
            }
-}
at : Point2d -> Frame2d
at point =
    Frame2d
        { originPoint = point
        , xDirection = Direction2d.x
        , yDirection = Direction2d.y
        }


{-| Get the origin point of a given frame.

    Frame2d.originPoint Frame2d.xy ==
        Point2d.origin
-}
originPoint : Frame2d -> Point2d
originPoint (Frame2d properties) =
    properties.originPoint


{-| Get the X direction of a given frame.

    Frame2d.xDirection Frame2d.xy ==
        Direction2d.x
-}
xDirection : Frame2d -> Direction2d
xDirection (Frame2d properties) =
    properties.xDirection


{-| Get the Y direction of a given frame.

    Frame2d.yDirection Frame2d.xy ==
        Direction2d.y
-}
yDirection : Frame2d -> Direction2d
yDirection (Frame2d properties) =
    properties.yDirection


{-| Get the X axis of a given frame (the axis formed from the frame's origin
point and X direction).

    Frame2d.xAxis Frame2d.xy ==
        Axis2d.x
-}
xAxis : Frame2d -> Axis2d
xAxis frame =
    Axis2d { originPoint = originPoint frame, direction = xDirection frame }


{-| Get the Y axis of a given frame (the axis formed from the frame's origin
point and Y direction).

    Frame2d.yAxis Frame2d.xy ==
        Axis2d.y
-}
yAxis : Frame2d -> Axis2d
yAxis frame =
    Axis2d { originPoint = originPoint frame, direction = yDirection frame }


{-| Reverse the X direction of a frame, leaving its Y direction and origin point
the same.

    Frame2d.flipX Frame2d.xy ==
        Frame2d
            { originPoint = Point2d.origin
            , xDirection = Direction2d.negate Direction2d.x
            , yDirection = Direction2d.y
            }
-}
flipX : Frame2d -> Frame2d
flipX frame =
    Frame2d
        { originPoint = originPoint frame
        , xDirection = Direction2d.negate (xDirection frame)
        , yDirection = yDirection frame
        }


{-| Reverse the Y direction of a frame, leaving its X direction and origin point
the same.

    Frame2d.flipY Frame2d.xy ==
        Frame2d
            { originPoint = Point2d.origin
            , xDirection = Direction2d.x
            , yDirection = Direction2d.negate Direction2d.y
            }
-}
flipY : Frame2d -> Frame2d
flipY frame =
    Frame2d
        { originPoint = originPoint frame
        , xDirection = xDirection frame
        , yDirection = Direction2d.negate (yDirection frame)
        }


{-| Move a frame so that it has the given origin point.

    frame =
        Frame2d
            { point = Point2d ( 2, 3 )
            , xDirection = Direction2d ( 0.8, 0.6 )
            , yDirection = Direction2d ( -0.6, 0.8 )
            }

    Frame2d.moveTo (Point2d ( 1, 1 )) frame ==
        Frame2d
            { point = Point2d ( 1, 1 )
            , xDirection = Direction2d ( 0.8, 0.6 )
            , yDirection = Direction2d ( -0.6, 0.8 )
            }
-}
moveTo : Point2d -> Frame2d -> Frame2d
moveTo newOrigin frame =
    Frame2d
        { originPoint = newOrigin
        , xDirection = xDirection frame
        , yDirection = yDirection frame
        }


{-| Rotate a frame counterclockwise by a given angle around the frame's own
origin point. The resulting frame will have the same origin point, and its X and
Y directions will be rotated by the given angle.

    frame =
        Frame2d.at (Point2d ( 1, 1 ))

    Frame2d.rotateBy (degrees 45) frame ==
        Frame2d
            { originPoint = Point2d ( 1, 1 )
            , xDirection = Direction2d ( 0.7071, 0.7071 )
            , yDirection = Direction2d ( -0.7071, 0.7071 )
            }
-}
rotateBy : Float -> Frame2d -> Frame2d
rotateBy angle frame =
    let
        rotateDirection =
            Direction2d.rotateBy angle
    in
        Frame2d
            { originPoint = originPoint frame
            , xDirection = rotateDirection (xDirection frame)
            , yDirection = rotateDirection (yDirection frame)
            }


{-| Rotate a frame counterclockwise around a given point by a given angle. The
frame's origin point will be rotated around the given point by the given angle,
and its X and Y basis directions will be rotated by the given angle.

    frame =
        Frame2d.at (Point2d ( 1, 1 ))

    Frame2d.rotateAround Point2d.origin (degrees 45) frame ==
        Frame2d
            { originPoint = Point2d ( 0, 1.4142 )
            , xDirection = Direction2d ( 0.7071, 0.7071 )
            , yDirection = Direction2d ( -0.7071, 0.7071 )
            }
-}
rotateAround : Point2d -> Float -> Frame2d -> Frame2d
rotateAround centerPoint angle =
    let
        rotatePoint =
            Point2d.rotateAround centerPoint angle

        rotateDirection =
            Direction2d.rotateBy angle
    in
        \frame ->
            Frame2d
                { originPoint = rotatePoint (originPoint frame)
                , xDirection = rotateDirection (xDirection frame)
                , yDirection = rotateDirection (yDirection frame)
                }


{-| Translate a frame by a given displacement.

    frame =
        Frame2d.at (Point2d ( 2, 3 ))

    displacement =
        Vector2d ( 1, 1 )

    Frame2d.translateBy displacement frame ==
        Frame2d.at (Point2d ( 3, 4 ))
-}
translateBy : Vector2d -> Frame2d -> Frame2d
translateBy vector frame =
    Frame2d
        { originPoint = Point2d.translateBy vector (originPoint frame)
        , xDirection = xDirection frame
        , yDirection = yDirection frame
        }


{-| Translate a frame along one of its own axes by a given distance.

The first argument is a function that will be called on the given frame to
determine the axis to translate along; the vast majority of the time this will
either by `Frame2d.xAxis` or `Frame2d.yAxis`. The second argument is the
distance to translate along the given axis.

This function is convenient when constructing frames via a series of
transformations. For example,

    Frame2d.at (Point2d ( 2, 0 ))
        |> Frame2d.rotateBy (degrees 45)
        |> Frame2d.translateAlongOwn Frame2d.xAxis 2

means 'construct a frame at the point (2, 0), rotate it about its own origin
point by 45 degrees, then translate it alongs its own (now inclined) X axis by
2 units', resulting in

    Frame2d
        { originPoint = Point2d ( 3.4142, 1.4142 )
        , xDirection = Direction2d ( 0.7071, 0.7071 )
        , yDirection = Direction2d ( -0.7071, 0.7071 )
        }
-}
translateAlongOwn : (Frame2d -> Axis2d) -> Float -> Frame2d -> Frame2d
translateAlongOwn axis distance frame =
    let
        displacement =
            Direction2d.times distance (Axis2d.direction (axis frame))
    in
        translateBy displacement frame


{-| Mirror a frame across an axis.

    frame =
        Frame2d.at (Point2d ( 2, 3 ))

    Frame2d.mirrorAcross Axis2d.x frame ==
        Frame2d
            { originPoint = Point2d ( 2, -3 )
            , xDirection = Direction2d.x
            , yDirection = Direction2d.negate Direction2d.y
            }
-}
mirrorAcross : Axis2d -> Frame2d -> Frame2d
mirrorAcross axis =
    let
        mirrorPoint =
            Point2d.mirrorAcross axis

        mirrorDirection =
            Direction2d.mirrorAcross axis
    in
        \frame ->
            Frame2d
                { originPoint = mirrorPoint (originPoint frame)
                , xDirection = mirrorDirection (xDirection frame)
                , yDirection = mirrorDirection (yDirection frame)
                }


{-| Take two frames expressed in global coordinates and return the second one
expressed in local coordinates relative to the first.
-}
relativeTo : Frame2d -> Frame2d -> Frame2d
relativeTo otherFrame =
    let
        relativePoint =
            Point2d.relativeTo otherFrame

        relativeDirection =
            Direction2d.relativeTo otherFrame
    in
        \frame ->
            Frame2d
                { originPoint = relativePoint (originPoint frame)
                , xDirection = relativeDirection (xDirection frame)
                , yDirection = relativeDirection (yDirection frame)
                }


{-| Take one frame expressed in global coordinates and a second frame expressed
in local coordinates relative to the first, and return the second frame
expressed in global coordinates.
-}
placeIn : Frame2d -> Frame2d -> Frame2d
placeIn otherFrame =
    let
        placePoint =
            Point2d.placeIn otherFrame

        placeDirection =
            Direction2d.placeIn otherFrame
    in
        \frame ->
            Frame2d
                { originPoint = placePoint (originPoint frame)
                , xDirection = placeDirection (xDirection frame)
                , yDirection = placeDirection (yDirection frame)
                }