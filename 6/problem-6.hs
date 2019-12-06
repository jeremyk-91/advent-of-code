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

parseGraph :: [[String]] -> Map.Map String [String]
parseGraph [] = Map.empty
parseGraph (x:xs) = Map.insertWith (++) (x!!0) [x!!1] restGraph
  where restGraph = parseGraph xs

type MemoTable = Map.Map String Int

bfs :: Map.Map String [String] -> [String] -> MemoTable -> Int -> MemoTable
bfs _ [] memo _ = memo
bfs orbits frontier memo depth = bfs orbits frontier' memo' (depth + 1)
  where adjacent = concat $ map (\x -> Map.findWithDefault [] x orbits) frontier
        frontier' = filter (\x -> not (Map.member x memo)) adjacent
        newFrontierEntries = Map.fromList [(x, depth) | x <- frontier']
        memo' = Map.union memo newFrontierEntries

main :: IO()
main = do
  input <- readFile "input-6"
  let adjList = map (\x -> splitOn x ')') (lines input)
  let parsed = parseGraph adjList
  let depths = Map.toList $ bfs parsed ["COM"] Map.empty 1
  let answer = sum $ map snd depths
  -- let answer = runIntCode parsedInput
  putStrLn (show answer)

main2 :: IO()
main2 = do
  input <- readFile "input-6"
  let adjList = map (\x -> splitOn x ')') (lines input)
  let reversedEdges = [[x!!1, x!!0] | x <- adjList]
  let parsed = parseGraph (adjList ++ reversedEdges)
  let answer = ((Map.!) (bfs parsed ["YOU"] Map.empty 1) "SAN") - 2
  putStrLn (show answer)
