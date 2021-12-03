import System.Environment
import Data.List
import qualified Data.Map as Map
import qualified Data.Map.Merge.Strict as Map

-- Splits elements in a list based on a delimiter
splitOn :: (Eq a) => [a] -> a -> [[a]]
splitOn [] _ = []
splitOn list@(x:xs) a
  | x == a    = splitOn xs a
  | otherwise = head:(splitOn tail a)
    where (head, tail) = break (\x -> x == a) list

parseInt = read :: String -> Int

splitIntoLayers :: (Eq a) => [a] -> Int -> [[a]]
splitIntoLayers [] _ = []
splitIntoLayers xs size = h:splitIntoLayers t size
  where (h, t) = splitAt size xs

frequencyTable :: (Ord a) => [a] -> Map.Map a Int
frequencyTable [] = Map.empty
frequencyTable (x:xs) = Map.insertWith (+) x 1 $ frequencyTable xs

fewestZeroes :: [Map.Map Char Int] -> Int -> Map.Map Char Int -> Map.Map Char Int
fewestZeroes [] count temp = temp
fewestZeroes (x:xs) count temp
  | f >= count = fewestZeroes xs count temp
  | otherwise  = fewestZeroes xs f x
    where f = Map.findWithDefault 0 '0' x

mergeLayers :: [[Char]] -> [Char]
mergeLayers layers = map (\index -> findDefinitivePixel $ getPixelsFromLayers index) [0, 1..149]
  where getPixelsFromLayers i = map (\x -> x!!i) layers

findDefinitivePixel :: [Char] -> Char
findDefinitivePixel [] = error "Unexpected"
findDefinitivePixel ('2':x) = findDefinitivePixel x
findDefinitivePixel (x:xs) = x

format :: [Char] -> Int -> [[Char]]
format [] _ = []
format cs width = h:(format cs' width)
  where (h, cs') = splitAt width cs

main :: IO()
main = do
  input <- readFile "input-8"
  let parsed = splitIntoLayers ((lines input)!!0) 150
  let layerAnalysis = map frequencyTable parsed
  putStrLn (show $ fewestZeroes layerAnalysis maxBound (layerAnalysis!!0))

main2 :: IO()
main2 = do
  input <- readFile "input-8"
  let parsed = splitIntoLayers ((lines input)!!0) 150
  putStrLn (show $ mergeLayers parsed)
