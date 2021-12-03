import System.Environment
import Data.List
import Debug.Trace
import qualified Data.Map as Map

type Coordinate = (Int, Int)
type Angle = Double

-- Splits elements in a list based on a delimiter
splitOn :: (Eq a) => [a] -> a -> [[a]]
splitOn [] _ = []
splitOn list@(x:xs) a
  | x == a    = splitOn xs a
  | otherwise = head:(splitOn tail a)
    where (head, tail) = break (\x -> x == a) list

getCoordinates :: [String] -> Int -> [Coordinate]
getCoordinates [] _ = []
getCoordinates (s:ss) i = (extractCoordinates s 0 i) ++ remaining
  where remaining = getCoordinates ss (i + 1)

extractCoordinates :: String -> Int -> Int -> [Coordinate]
extractCoordinates [] _ _ = []
extractCoordinates ('.':ss) x y = extractCoordinates ss (x + 1) y
extractCoordinates ('#':ss) x y = (x, y):(extractCoordinates ss (x+1) y)

vectorDiff :: Coordinate -> Coordinate -> Coordinate
vectorDiff (x1, y1) (x2, y2) = (x2 - x1, y2 - y1)

relativeVector :: Coordinate -> Coordinate -> Coordinate
relativeVector (x1, y1) (x2, y2) = ((x2 - x1) `div` t, (y2 - y1) `div` t)
  where t = gcd (x2 - x1) (y2 - y1)

getRelativeVectors :: [Coordinate] -> Coordinate -> [Coordinate]
getRelativeVectors asteroids reference
  = map (\x -> relativeVector reference x) (filter (\x -> x /= reference) asteroids)

--groupByRelativeVectors :: [Coordinate] -> Coordinate -> Map.Map Coordinate [Coordinate]
groupByRelativeVectors asteroids reference
  = unflatten assocs
    where
      asteroidsKeyedByRelativeVector = map (\x -> ((relativeVector reference x), x)) (filter (\x -> x /= reference) asteroids)
      mergedMap = merge asteroidsKeyedByRelativeVector
      sortedMap = Map.map (\x -> sortByVectorMagnitude x reference) mergedMap
      coordinatesMap = Map.map (\coordinates -> map snd coordinates) sortedMap
      assocs = Map.assocs coordinatesMap

unflatten :: [(a, [b])] -> [b]
unflatten [] = []
unflatten xs = (map (takeFirst) xs) ++ (unflatten $ dropFirstRemoving xs)
  where
    takeFirst (x, y:ys) = y

dropFirstRemoving :: [(a, [b])] -> [(a, [b])]
dropFirstRemoving [] = []
dropFirstRemoving ((a, []):xs) = dropFirstRemoving xs
dropFirstRemoving ((a, x:[]):xs) = dropFirstRemoving xs
dropFirstRemoving ((a, x:y):xs) = (a, y):dropFirstRemoving xs

toBearing :: Coordinate -> Angle
toBearing (x, y)
  | x < 0 && y < 0 = arctan2 + (5 * pi / 2)
  | otherwise      = arctan2 + (pi / 2)
  where
    arctan2 = (atan2 (fromIntegral y) (fromIntegral x))

merge :: [(Coordinate, Coordinate)] -> Map.Map Angle [(Coordinate, Coordinate)]
merge [] = Map.empty
merge ((x1,x2):xs) = Map.insertWith (++) (toBearing x1) [(x1, x2)] map'
  where map' = merge xs

magnitude :: Coordinate -> Double
magnitude (x, y) = sqrt(fromIntegral(x*x) + fromIntegral(y*y))

sortByVectorMagnitude :: [(Coordinate, Coordinate)] -> Coordinate -> [(Coordinate, Coordinate)]
sortByVectorMagnitude points reference = sortBy (\x y -> compareMagnitudes reference x y) points

compareMagnitudes :: Coordinate -> (Coordinate, Coordinate) -> (Coordinate, Coordinate) -> Ordering
compareMagnitudes ref (_, v1) (_, v2)
  | m1 < m2   = LT
  | m1 == m2  = EQ
  | otherwise = GT
    where m1 = magnitude $ vectorDiff ref v1
          m2 = magnitude $ vectorDiff ref v2

getNumRelativeVectors :: [Coordinate] -> [(Coordinate, Int)]
getNumRelativeVectors asteroids
  = [(x, length $ nub $ getRelativeVectors asteroids x) | x <- asteroids]

getBestSite :: [(Coordinate, Int)] -> Coordinate
getBestSite pairs
  = fst $ foldl1 maxBySecond pairs

maxBySecond :: Ord b => (a, b) -> (a, b) -> (a, b)
maxBySecond (c1, n1) (c2, n2)
  | n1 > n2   = (c1, n1)
  | otherwise = (c2, n2)

main :: IO()
main = do
  input <- readFile "input-10"
  let asteroids = getCoordinates (lines input) 0
  let answer = getNumRelativeVectors asteroids
  putStrLn (show answer)

main2 :: IO()
main2 = do
  input <- readFile "input-10"
  let asteroids = getCoordinates (lines input) 0
  let vectors = getNumRelativeVectors asteroids
  let bestSite = getBestSite vectors
  let vectorsForBestSite = groupByRelativeVectors asteroids bestSite
  putStrLn (show vectorsForBestSite)

-- 269 is max: this occurs at (13, 17)
