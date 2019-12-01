import System.Environment

findOneComponentMass :: Int -> Int
findOneComponentMass x
  | requiredFuel <= 0 = 0
  | otherwise         = requiredFuel
  where requiredFuel = (div x 3) - 2

findMass :: [Int] -> [Int]
findMass xs = map (findOneComponentMass) xs

findOneComponentSeriesMass :: Int -> Int
findOneComponentSeriesMass c
  | requiredFuel <= 0 = 0
  | otherwise         = requiredFuel + findOneComponentSeriesMass requiredFuel
  where requiredFuel = findOneComponentMass c

findSeriesMass :: [Int] -> [Int]
findSeriesMass xs = map (findOneComponentSeriesMass) xs

parseInt = read :: String -> Int

main :: IO()
main = do
  input <- readFile "input-1"
  let parsedInput = map parseInt (lines input)
  let output = sum $ findSeriesMass parsedInput
  putStrLn (show output)
