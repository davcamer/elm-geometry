{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module OpenSolid.Point2d
    exposing
        ( origin
        , midpoint
        , interpolate
        , along
        , coordinates
        , xCoordinate
        , yCoordinate
        , equalWithin
        , vectorFrom
        , vectorTo
        , distanceFrom
        , squaredDistanceFrom
        , distanceAlong
        , signedDistanceFrom
        , scaleAbout
        , rotateAround
        , translateBy
        , mirrorAcross
        , projectOnto
        , relativeTo
        , placeIn
        )

{-| Various functions for creating and working with `Point2d` values. For the
examples below, assume that all OpenSolid core types have been imported using

    import OpenSolid.Core.Types exposing (..)

and all necessary modules have been imported using the following pattern:

    import OpenSolid.Point2d as Point2d

Examples use `==` to indicate that two expressions are equivalent, even if (due
to numerical roundoff) they might not be exactly equal.

# Constants

@docs origin

# Constructors

The simplest way to construct a `Point2d` value is by passing a tuple of X and Y
coordinates to the `Point2d` constructor, for example `Point2d ( 2, 3 )`. But
that is not the only way!

There are no specific functions to create points from polar components, but you
can use Elm's built-in `fromPolar` function:

    point =
        Point2d (fromPolar ( radius, angle ))

@docs midpoint, interpolate, along

# Coordinates

@docs coordinates, xCoordinate, yCoordinate

# Comparison

@docs equalWithin

# Displacement

@docs vectorFrom, vectorTo

# Distance

@docs distanceFrom, squaredDistanceFrom, distanceAlong, signedDistanceFrom

# Transformations

@docs scaleAbout, rotateAround, translateBy, mirrorAcross, projectOnto

# Coordinate frames

Functions for transforming points between local and global coordinates in
different coordinate frames.

@docs relativeTo, placeIn
-}

import OpenSolid.Core.Types exposing (..)
import OpenSolid.Vector2d as Vector2d
import OpenSolid.Direction2d as Direction2d


addTo : Point2d -> Vector2d -> Point2d
addTo =
    flip translateBy


{-| The point (0, 0).

    Point2d.origin == Point2d ( 0, 0 )
-}
origin : Point2d
origin =
    Point2d ( 0, 0 )


{-| Construct a point halfway between two other points.

    p1 =
        Point2d ( 1, 1 )

    p2 =
        Point2d ( 3, 7 )

    Point2d.midpoint p1 p2 ==
        Point2d ( 2, 4 )
-}
midpoint : Point2d -> Point2d -> Point2d
midpoint firstPoint secondPoint =
    interpolate firstPoint secondPoint 0.5


{-| Construct a point by interpolating between two other points based on a
parameter that ranges from zero to one.

    startPoint =
        Point2d.origin

    endPoint =
        Point2d ( 8, 12 )

    Point2d.interpolate startPoint endPoint 0.25 ==
        Point2d ( 2, 3 )

Partial application may be useful:

    interpolatedPoint : Float -> Point2d
    interpolatedPoint =
        Point2d.interpolate startPoint endPoint

    List.map interpolatedPoint [ 0, 0.5, 1 ] ==
        [ Point2d ( 0, 0 )
        , Point2d ( 4, 6 )
        , Point2d ( 8, 12 )
        ]

You can pass values less than zero or greater than one to extrapolate:

    interpolatedPoint -0.5 ==
        Point2d ( -4, -6 )

    interpolatedPoint 1.25 ==
        Point2d ( 10, 15 )
-}
interpolate : Point2d -> Point2d -> Float -> Point2d
interpolate startPoint endPoint =
    let
        displacement =
            vectorFrom startPoint endPoint
    in
        \t -> translateBy (Vector2d.times t displacement) startPoint


{-| Construct a point along an axis at a particular distance from the axis'
origin point.

    Point2d.along Axis2d.y 3 ==
        Point2d ( 0, 3 )

Positive and negative distances will be interpreted relative to the direction of
the axis:

    horizontalAxis =
        Axis2d
            { originPoint = Point2d ( 1, 1 )
            , direction = Direction2d ( -1, 0 )
            }

    Point2d.along horizontalAxis 3 ==
        Point2d ( -2, 1 )

    Point2d.along horizontalAxis -3 ==
        Point2d ( 4, 1 )
-}
along : Axis2d -> Float -> Point2d
along (Axis2d { originPoint, direction }) distance =
    translateBy (Direction2d.times distance direction) originPoint


{-| Get the coordinates of a point as a tuple.

    ( x, y ) =
        Point2d.coordinates point

To get the polar coordinates of a point, you can use Elm's built in `toPolar`
function:

    ( radius, angle ) =
        toPolar (Point2d.coordinates point)
-}
coordinates : Point2d -> ( Float, Float )
coordinates (Point2d coordinates') =
    coordinates'


{-| Get the X coordinate of a point.

    Point2d.xCoordinate (Point2d ( 2, 3 )) == 2
-}
xCoordinate : Point2d -> Float
xCoordinate =
    coordinates >> fst


{-| Get the Y coordinate of a point.

    Point2d.yCoordinate (Point2d ( 2, 3 )) == 3
-}
yCoordinate : Point2d -> Float
yCoordinate =
    coordinates >> snd


{-| Compare two points within a tolerance. Returns true if the distance
between the two given points is less than the given tolerance.

    firstPoint =
        Point2d ( 1, 2 )

    secondPoint =
        Point2d ( 0.9999, 2.0002 )

    Point2d.equalWithin 1e-3 firstPoint secondPoint ==
        True

    Point2d.equalWithin 1e-6 firstPoint secondPoint ==
        False
-}
equalWithin : Float -> Point2d -> Point2d -> Bool
equalWithin tolerance firstPoint secondPoint =
    squaredDistanceFrom firstPoint secondPoint <= tolerance * tolerance


{-| Find the vector from one point to another.

    startPoint =
        Point2d ( 1, 1 )

    endPoint =
        Point2d ( 4, 5 )

    Point2d.vectorFrom startPoint endPoint ==
        Vector2d ( 3, 4 )
-}
vectorFrom : Point2d -> Point2d -> Vector2d
vectorFrom other point =
    let
        ( x', y' ) =
            coordinates other

        ( x, y ) =
            coordinates point
    in
        Vector2d ( x - x', y - y' )


{-| Flipped version of `vectorFrom`, where the end point is given first.

    startPoint =
        Point2d ( 2, 3 )

    Point2d.vectorTo Point2d.origin startPoint ==
        Vector2d ( -2, -3 )
-}
vectorTo : Point2d -> Point2d -> Vector2d
vectorTo =
    flip vectorFrom


{-| Find the distance between two points.

    p1 =
        Point2d ( 2, 3 )

    p2 =
        Point2d ( 5, 7 )

    Point2d.distanceFrom p1 p2 == 5

Partial application can be useful:

    points =
        [ Point2d ( 3, 4 )
        , Point2d ( 10, 0 )
        , Point2d ( -1, 2 )
        ]

    distanceFromOrigin : Point2d -> Float
    distanceFromOrigin =
        Point2d.distanceFrom Point2d.origin

    List.sortBy distanceFromOrigin points ==
        [ Point2d ( -1, 2 )
        , Point2d ( 3, 4 )
        , Point2d ( 10, 0 )
        ]
-}
distanceFrom : Point2d -> Point2d -> Float
distanceFrom other =
    squaredDistanceFrom other >> sqrt


{-| Find the square of the distance from one point to another.
`squaredDistanceFrom` is slightly faster than `distanceFrom`, so for example

    Point2d.squaredDistanceFrom p1 p2 > tolerance * tolerance

is equivalent to but slightly more efficient than

    Point2d.distanceFrom p1 p2 > tolerance

since the latter requires a square root under the hood. In many cases, however,
the speed difference will be negligible and using `distanceFrom` is much more
readable!
-}
squaredDistanceFrom : Point2d -> Point2d -> Float
squaredDistanceFrom other =
    vectorFrom other >> Vector2d.squaredLength


{-| Determine how far along an axis a particular point lies. Conceptually, the
point is projected perpendicularly onto the axis, and then the distance of this
projected point from the axis' origin point is measured. The result will be
positive if the projected point is ahead the axis' origin point and negative if
it is behind, with 'ahead' and 'behind' defined by the direction of the axis.

    axis =
        Axis2d
            { originPoint = Point2d ( 1, 2 )
            , direction = Direction2d.x
            }

    point =
        Point2d ( 3, 3 )

    Point2d.distanceAlong axis point == 2
    Point2d.distanceAlong axis Point2d.origin == -1
-}
distanceAlong : Axis2d -> Point2d -> Float
distanceAlong axis =
    let
        (Axis2d { originPoint, direction }) =
            axis
    in
        vectorFrom originPoint >> Vector2d.componentIn direction


{-| Find the perpendicular distance of a point from an axis. The result
will be positive if the point is to the left of the axis and negative if it is
to the right, with the forwards direction defined by the direction of the axis.

    -- A horizontal axis through a point with a Y
    -- coordinate of 2 is effectively the line Y=2
    axis =
        Axis2d
            { originPoint = Point2d ( 1, 2 )
            , direction = Direction2d.x
            }

    point =
        Point2d ( 3, 3 )

    -- Since the axis is in the positive X direction,
    -- points above the axis are to the left (positive)
    Point2d.signedDistanceFrom axis point == 1
    -- and points below are to the right (negative)
    Point2d.signedDistanceFrom axis Point2d.origin == -2

This means that flipping an axis will also flip the sign of the result of this
function:

    -- Flipping an axis reverses its direction
    flippedAxis =
        Axis2d.flip axis

    Point2d.signedDistanceFrom flippedAxis point == -1
    Point2d.signedDistanceFrom flippedAxis Point2d.origin == 2
-}
signedDistanceFrom : Axis2d -> Point2d -> Float
signedDistanceFrom axis =
    let
        (Axis2d { originPoint, direction }) =
            axis

        directionVector =
            Direction2d.vector direction
    in
        vectorFrom originPoint >> Vector2d.crossProduct directionVector


{-| Perform a uniform scaling about the given center point. The center point is
given first and the point to transform is given last. Points will contract or
expand about the center point by the given scale. Scaling by a factor of 1 is a
no-op, and scaling by a factor of 0 collapses all points to the center point.

    centerPoint =
        Point2d ( 1, 1 )

    point =
        Point2d ( 2, 3 )

    Point2d.scaleAbout centerPoint 3 point ==
        Point2d ( 4, 7 )

    Point2d.scaleAbout centerPoint 0.5 point ==
        Point2d ( 1.5, 2 )

Do not scale by a negative scaling factor - while this may sometimes do what you
want it is confusing and error prone. Try a combination of mirror and/or
rotation operations instead.
-}
scaleAbout : Point2d -> Float -> Point2d -> Point2d
scaleAbout centerPoint scale =
    vectorFrom centerPoint >> Vector2d.times scale >> addTo centerPoint


{-| Rotate around a given center point counterclockwise by a given angle (in
radians). The point to rotate around is given first and the point to rotate is
given last.

    centerPoint =
        Point2d ( 2, 0 )

    angle =
        degrees 45

    point =
        Point2d ( 3, 0 )

    Point2d.rotateAround centerPoint angle point ==
        Point2d ( 2.7071, 0.7071 )
-}
rotateAround : Point2d -> Float -> Point2d -> Point2d
rotateAround centerPoint angle =
    vectorFrom centerPoint >> Vector2d.rotateBy angle >> addTo centerPoint


{-| Translate a point by a given displacement. You can think of this as 'plus'.

    point =
        Point2d ( 3, 4 )

    displacement =
        Vector2d ( 1, 2 )

    Point2d.translateBy displacement point ==
        Point2d ( 4, 6 )
-}
translateBy : Vector2d -> Point2d -> Point2d
translateBy vector point =
    let
        ( vx, vy ) =
            Vector2d.components vector

        ( px, py ) =
            coordinates point
    in
        Point2d ( px + vx, py + vy )


{-| Mirror a point across an axis. The result will be the same distance from the
axis but on the opposite side.

    point =
        Point2d ( 2, 3 )

    Point2d.mirrorAcross Axis2d.x point ==
        Point2d ( 2, -3 )

    Point2d.mirrorAcross Axis2d.y point ==
        Point2d ( -2, 3 )
-}
mirrorAcross : Axis2d -> Point2d -> Point2d
mirrorAcross axis =
    let
        (Axis2d { originPoint, direction }) =
            axis
    in
        vectorFrom originPoint
            >> Vector2d.mirrorAcross axis
            >> addTo originPoint


{-| Project a point perpendicularly onto an axis.

    point =
        Point2d ( 2, 3 )

    Point2d.projectOnto Axis2d.x point ==
        Point2d ( 2, 0 )

    Point2d.projectOnto Axis2d.y point ==
        Point2d ( 0, 3 )

The axis does not have to pass through the origin:

    offsetYAxis =
        Axis2d
            { originPoint = Point2d ( 1, 0 )
            , direction = Direction2d.y
            }

    Point2d.projectOnto offsetYAxis point ==
        Point2d ( 1, 3 )
-}
projectOnto : Axis2d -> Point2d -> Point2d
projectOnto axis =
    let
        (Axis2d { originPoint, direction }) =
            axis
    in
        vectorFrom originPoint
            >> Vector2d.projectOnto axis
            >> addTo originPoint


{-| Take a point currently defined in global coordinates and express it
relative to a given reference frame.

    localFrame =
        Frame2d.at (Point2d ( 1, 2 ))

    Point2d.relativeTo localFrame (Point2d ( 4, 5 )) ==
        Point2d ( 3, 3 )

    Point2d.relativeTo localFrame (Point2d ( 1, 1 )) ==
        Point2d ( 0, -1 )
-}
relativeTo : Frame2d -> Point2d -> Point2d
relativeTo frame =
    let
        (Frame2d { originPoint, xDirection, yDirection }) =
            frame
    in
        vectorFrom originPoint
            >> Vector2d.relativeTo frame
            >> Vector2d.components
            >> Point2d


{-| Take a point defined in local coordinates relative to a given reference
frame, and return that point expressed in global coordinates.

    localFrame =
        Frame2d.at (Point2d ( 1, 2 ))

    Point2d.placeIn localFrame (Point2d ( 3, 3 )) ==
        Point2d ( 4, 5 )

    Point2d.placeIn localFrame (Point2d ( 0, -2 )) ==
        Point2d ( 1, 0 )
-}
placeIn : Frame2d -> Point2d -> Point2d
placeIn frame =
    let
        (Frame2d { originPoint, xDirection, yDirection }) =
            frame
    in
        coordinates >> Vector2d >> Vector2d.placeIn frame >> addTo originPoint