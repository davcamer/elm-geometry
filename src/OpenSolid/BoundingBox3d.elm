{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module OpenSolid.BoundingBox3d
    exposing
        ( singleton
        , containing2
        , containing3
        , containing
        , extrema
        , minX
        , maxX
        , minY
        , maxY
        , minZ
        , maxZ
        , midX
        , midY
        , midZ
        , centroid
        , contains
        , overlaps
        , isContainedIn
        , hull
        , intersection
        )

{-| Various functions for creating and working with `BoundingBox3d` values. For
the examples below, assume that all OpenSolid core types have been imported
using

    import OpenSolid.Core.Types exposing (..)

and all necessary modules have been imported using the following pattern:

    import OpenSolid.BoundingBox3d as BoundingBox3d

Examples use `==` to indicate that two expressions are equivalent, even if (due
to numerical roundoff) they might not be exactly equal.

# Constructors

Bounding boxes can be constructed by passing a record with `minX`, `maxX`,
`minY`, `maxY`, `minZ` and `maxZ` fields to the `BoundingBox3d` constructor, for
example

    boundingBox =
        BoundingBox3d
            { minX = 1
            , maxX = 3
            , minY = -2
            , maxY = 4
            , minZ = -6
            , maxZ = -5
            }

@docs singleton, containing2, containing3, containing

# Accessors

For all examples in this section, assume the following example bounding box:

    exampleBox =
        BoundingBox3d
            { minX = 1
            , maxX = 3
            , minY = -2
            , maxY = 4
            , minZ = -6
            , maxZ = -5
            }

@docs extrema, minX, maxX, minY, maxY, minZ, maxZ, midX, midY, midZ, centroid

# Checks

@docs contains, overlaps, isContainedIn

# Boolean operations

@docs hull, intersection
-}

import OpenSolid.Core.Types exposing (..)
import OpenSolid.Point3d as Point3d


{-| Construct a zero-width bounding box containing a single point.

    point =
        Point3d ( 2, 1, 3 )

    BoundingBox3d.singleton point ==
        BoundingBox3d
            { minX = 2
            , maxX = 2
            , minY = 1
            , maxY = 1
            , minZ = 3
            , maxZ = 3
            }
-}
singleton : Point3d -> BoundingBox3d
singleton point =
    let
        ( x, y, z ) =
            Point3d.coordinates point
    in
        BoundingBox3d
            { minX = x
            , maxX = x
            , minY = y
            , maxY = y
            , minZ = z
            , maxZ = z
            }


{-| Construct a bounding box containing both of the given points.

    point1 =
        Point3d ( 2, 1, 3 )

    point2 =
        Point3d ( -1, 5, -2 )

    BoundingBox3d.containing2 ( point1, point2 ) ==
        BoundingBox3d
            { minX = -1
            , maxX = 2
            , minY = 1
            , maxY = 5
            , minZ = -2
            , maxZ = 3
            }
-}
containing2 : ( Point3d, Point3d ) -> BoundingBox3d
containing2 points =
    let
        ( firstPoint, secondPoint ) =
            points

        ( x1, y1, z1 ) =
            Point3d.coordinates firstPoint

        ( x2, y2, z2 ) =
            Point3d.coordinates secondPoint
    in
        BoundingBox3d
            { minX = min x1 x2
            , maxX = max x1 x2
            , minY = min y1 y2
            , maxY = max y1 y2
            , minZ = min z1 z2
            , maxZ = max z1 z2
            }


{-| Construct a bounding box containing all three of the given points.

    point1 =
        Point3d ( 2, 1, 3 )

    point2 =
        Point3d ( -1, 5, -2 )

    point3 =
        Point3d ( 6, 4, 2 )

    BoundingBox3d.containing3 ( point1, point2, point3 ) ==
        BoundingBox3d
            { minX = -1
            , maxX = 6
            , minY = 1
            , maxY = 5
            , minZ = -2
            , maxZ = 3
            }
-}
containing3 : ( Point3d, Point3d, Point3d ) -> BoundingBox3d
containing3 points =
    let
        ( firstPoint, secondPoint, thirdPoint ) =
            points

        ( x1, y1, z1 ) =
            Point3d.coordinates firstPoint

        ( x2, y2, z2 ) =
            Point3d.coordinates secondPoint

        ( x3, y3, z3 ) =
            Point3d.coordinates thirdPoint
    in
        BoundingBox3d
            { minX = min x1 (min x2 x3)
            , maxX = max x1 (max x2 x3)
            , minY = min y1 (min y2 y3)
            , maxY = max y1 (max y2 y3)
            , minZ = min z1 (min z2 z3)
            , maxZ = max z1 (max z2 z3)
            }


{-| Construct a bounding box containing all points in the given list. If the
list is empty, returns `Nothing`.

    points =
        [ Point3d ( 2, 1, 3 )
        , Point3d ( -1, 5, -2 )
        , Point3d ( 6, 4, 2 )
        ]

    BoundingBox3d.containing points ==
        Just
            (BoundingBox3d
                { minX = -1
                , maxX = 6
                , minY = 1
                , maxY = 5
                , minZ = -2
                , maxZ = 3
                }
            )

    BoundingBox3d.containing [] ==
        Nothing
-}
containing : List Point3d -> Maybe BoundingBox3d
containing points =
    case points of
        [] ->
            Nothing

        first :: rest ->
            Just (List.foldl hull (singleton first) (List.map singleton rest))


{-| Get the minimum and maximum X, Y and Z values of a bounding box in a single
record.

    BoundingBox3d.extrema exampleBox ==
        { minX = 1
        , maxX = 3
        , minY = -2
        , maxY = 4
        , minZ = -6
        , maxZ = -5
        }

Can be useful when combined with record destructuring, for example

    { minX, maxX, minY, maxY, minZ, maxZ } =
        BoundingBox3d.extrema exampleBox
-}
extrema :
    BoundingBox3d
    -> { minX : Float
       , maxX : Float
       , minY : Float
       , maxY : Float
       , minZ : Float
       , maxZ : Float
       }
extrema (BoundingBox3d extrema') =
    extrema'


{-| Get the minimum X value of a bounding box.

    BoundingBox3d.minX exampleBox ==
        1
-}
minX : BoundingBox3d -> Float
minX =
    extrema >> .minX


{-| Get the maximum X value of a bounding box.

    BoundingBox3d.maxX exampleBox ==
        3
-}
maxX : BoundingBox3d -> Float
maxX =
    extrema >> .maxX


{-| Get the minimum Y value of a bounding box.

    BoundingBox3d.minY exampleBox ==
        -2
-}
minY : BoundingBox3d -> Float
minY =
    extrema >> .minY


{-| Get the maximum Y value of a bounding box.

    BoundingBox3d.maxY exampleBox ==
        4
-}
maxY : BoundingBox3d -> Float
maxY =
    extrema >> .maxY


{-| Get the minimum Z value of a bounding box.

    BoundingBox3d.minZ exampleBox ==
        -6
-}
minZ : BoundingBox3d -> Float
minZ =
    extrema >> .minZ


{-| Get the maximum Z value of a bounding box.

    BoundingBox3d.maxZ exampleBox ==
        -5
-}
maxZ : BoundingBox3d -> Float
maxZ =
    extrema >> .maxZ


{-| Get the median X value of a bounding box.

    BoundingBox3d.midX exampleBox ==
        2
-}
midX : BoundingBox3d -> Float
midX boundingBox =
    let
        { minX, maxX } =
            extrema boundingBox
    in
        minX + 0.5 * (maxX - minX)


{-| Get the median Y value of a bounding box.

    BoundingBox3d.midY exampleBox ==
        1
-}
midY : BoundingBox3d -> Float
midY boundingBox =
    let
        { minY, maxY } =
            extrema boundingBox
    in
        minY + 0.5 * (maxY - minY)


{-| Get the median Z value of a bounding box.

    BoundingBox3d.midZ exampleBox ==
        -5.5
-}
midZ : BoundingBox3d -> Float
midZ boundingBox =
    let
        { minZ, maxZ } =
            extrema boundingBox
    in
        minZ + 0.5 * (maxZ - minZ)


{-| Get the point at the center of a bounding box.

    BoundingBox3d.centroid exampleBox ==
        Point3d ( 2, 1, -5.5 )
-}
centroid : BoundingBox3d -> Point3d
centroid boundingBox =
    Point3d ( midX boundingBox, midY boundingBox, midZ boundingBox )


{-| Check if a bounding box contains a particular point.

    boundingBox =
        BoundingBox3d
            { minX = 0
            , maxX = 2
            , minY = 0
            , maxY = 3
            , minZ = 0
            , maxZ = 4
            }

    firstPoint =
        Point3d ( 1, 2, 3 )

    secondPoint =
        Point3d ( 3, 1, 2 )

    BoundingBox3d.contains firstPoint boundingBox ==
        True

    BoundingBox3d.contains secondPoint boundingBox ==
        False
-}
contains : Point3d -> BoundingBox3d -> Bool
contains point boundingBox =
    let
        ( x, y, z ) =
            Point3d.coordinates point
    in
        (minX boundingBox <= x && x <= maxX boundingBox)
            && (minY boundingBox <= y && y <= maxY boundingBox)
            && (minZ boundingBox <= z && z <= maxZ boundingBox)


{-| Test if one bounding box overlaps (touches) another.

    firstBox =
        BoundingBox3d
            { minX = 0
            , maxX = 3
            , minY = 0
            , maxY = 2
            , minZ = 0
            , maxZ = 1
            }

    secondBox =
        BoundingBox3d
            { minX = 0
            , maxX = 3
            , minY = 1
            , maxY = 4
            , minZ = -1
            , maxZ = 2
            }

    thirdBox =
        BoundingBox3d
            { minX = 0
            , maxX = 3
            , minY = 4
            , maxY = 5
            , minZ = -1
            , maxZ = 2
            }

    BoundingBox3d.overlaps firstBox secondBox ==
        True

    BoundingBox3d.overlaps firstBox thirdBox ==
        False
-}
overlaps : BoundingBox3d -> BoundingBox3d -> Bool
overlaps other boundingBox =
    (minX boundingBox <= maxX other)
        && (maxX boundingBox >= minX other)
        && (minY boundingBox <= maxY other)
        && (maxY boundingBox >= minY other)
        && (minZ boundingBox <= maxZ other)
        && (maxZ boundingBox >= minZ other)


{-| Test if the second given bounding box is fully contained within the first
(is a strict subset of it).

    outerBox =
        BoundingBox3d
            { minX = 0
            , maxX = 10
            , minY = 0
            , maxY = 10
            , minZ = 0
            , maxZ = 10
            }

    innerBox =
        BoundingBox3d
            { minX = 1
            , maxX = 5
            , minY = 3
            , maxY = 9
            , minZ = 7
            , maxZ = 8
            }

    overlappingBox =
        BoundingBox3d
            { minX = 1
            , maxX = 5
            , minY = 3
            , maxY = 12
            , minZ = 7
            , maxZ = 8
            }

    BoundingBox3d.isContainedIn outerBox innerBox ==
        True

    BoundingBox3d.isContainedIn outerBox overlappingBox ==
        False
-}
isContainedIn : BoundingBox3d -> BoundingBox3d -> Bool
isContainedIn other boundingBox =
    (minX other <= minX boundingBox && maxX boundingBox <= maxX other)
        && (minY other <= minY boundingBox && maxY boundingBox <= maxY other)
        && (minZ other <= minZ boundingBox && maxZ boundingBox <= maxZ other)


{-| Build a bounding box that contains both given bounding boxes.

    firstBox =
        BoundingBox3d
            { minX = 1
            , maxX = 4
            , minY = 2
            , maxY = 3
            , minZ = 0
            , maxZ = 5
            }

    secondBox =
        BoundingBox3d
            { minX = -2
            , maxX = 2
            , minY = 4
            , maxY = 5
            , minZ = -1
            , maxZ = 0
            }

    BoundingBox3d.hull firstBox secondBox ==
        BoundingBox3d
            { minX = -2
            , maxX = 4
            , minY = 2
            , maxY = 5
            , minZ = -1
            , maxZ = 5
            }
-}
hull : BoundingBox3d -> BoundingBox3d -> BoundingBox3d
hull firstBox secondBox =
    BoundingBox3d
        { minX = min (minX firstBox) (minX secondBox)
        , maxX = max (maxX firstBox) (maxX secondBox)
        , minY = min (minY firstBox) (minY secondBox)
        , maxY = max (maxY firstBox) (maxY secondBox)
        , minZ = min (minZ firstBox) (minZ secondBox)
        , maxZ = max (maxZ firstBox) (maxZ secondBox)
        }


{-| Attempt to build a bounding box that contains all points common to both
given bounding boxes. If the given boxes do not overlap, returns `Nothing`.

    firstBox =
        BoundingBox3d
            { minX = 1
            , maxX = 4
            , minY = 2
            , maxY = 3
            , minZ = 5
            , maxZ = 8
            }

    secondBox =
        BoundingBox3d
            { minX = 2
            , maxX = 5
            , minY = 1
            , maxY = 4
            , minZ = 6
            , maxZ = 7
            }

    thirdBox =
        BoundingBox3d
            { minX = 1
            , maxX = 4
            , minY = 4
            , maxY = 5
            , minZ = 5
            , maxZ = 8
            }

    BoundingBox3d.intersection firstBox secondBox ==
        Just
            (BoundingBox3d
                { minX = 2
                , maxX = 4
                , minY = 2
                , maxY = 3
                , minZ = 6
                , maxZ = 7
                }
            )

    BoundingBox3d.intersection firstBox thirdBox ==
        Nothing
-}
intersection : BoundingBox3d -> BoundingBox3d -> Maybe BoundingBox3d
intersection firstBox secondBox =
    if overlaps firstBox secondBox then
        Just
            (BoundingBox3d
                { minX = max (minX firstBox) (minX secondBox)
                , maxX = min (maxX firstBox) (maxX secondBox)
                , minY = max (minY firstBox) (minY secondBox)
                , maxY = min (maxY firstBox) (maxY secondBox)
                , minZ = max (minZ firstBox) (minZ secondBox)
                , maxZ = min (maxZ firstBox) (maxZ secondBox)
                }
            )
    else
        Nothing