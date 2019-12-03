import System.Environment
import Data.List

type Memory = [Int]
type BinaryOperator = Int -> Int -> Int

-- Splits elements in a list based on a delimiter
splitOn :: (Eq a) => [a] -> a -> [[a]]
splitOn [] _ = []
splitOn list@(x:xs) a
  | x == a    = splitOn xs a
  | otherwise = head:(splitOn tail a)
    where (head, tail) = break (\x -> x == a) list

-- Returns the final state of an intcode program
runIntCode :: Memory -> Memory
runIntCode intCode = runIntCodeWithPointer intCode 0

getReturnValueOfIntCode :: Memory -> Int
getReturnValueOfIntCode intCode = (runIntCode intCode)!!0

runIntCodeWithPointer :: Memory -> Int -> Memory
runIntCodeWithPointer intCode pointer
  | opcode == 1  = runIntCodeWithPointer (curriedTransform (+)) nextPointerSlot
  | opcode == 2  = runIntCodeWithPointer (curriedTransform (*)) nextPointerSlot
  | opcode == 99 = intCode
    where opcode = intCode!!pointer
          firstArg = intCode!!(intCode!!(pointer + 1))
          secondArg = intCode!!(intCode!!(pointer + 2))
          destination = intCode!!(pointer + 3)
          curriedTransform = transform intCode firstArg secondArg destination
          nextPointerSlot = pointer + 4

transform :: Memory -> Int -> Int -> Int -> BinaryOperator -> Memory
transform intCode firstArg secondArg destination binaryOperator
  = head ++ (binaryOperator firstArg secondArg):tail
    where (head, _:tail) = splitAt destination intCode

-- Maybe a little hacky, but I thought I'd like to reuse the transform code.
setState :: Memory -> Int -> Int -> Memory
setState intCode position value
  = transform intCode value 0 position (\x y -> x)

-- Tests the Cartesian product of the second and third arguments as registers 1 and 2.
-- Returns all pairs of arguments that result in returning the value that was argument 4.
chaseValues :: Memory -> [Int] -> [Int] -> Int -> [(Int, Int)]
chaseValues intCode xs ys target
  = map (recoverArguments . fst) acceptableComputations
    where cartesianProduct = [(x, y) | x <- xs, y <- ys]
          initializedRegisters = map (\x -> initializeRegisters intCode x) cartesianProduct
          computations = [(x, getReturnValueOfIntCode x) | x <- initializedRegisters]
          acceptableComputations = filter (\(args, rv) -> rv == target) computations
          recoverArguments xs = (xs!!1, xs!!2)

-- There's probably something that can be done to make this a one-liner.
initializeRegisters :: Memory -> (Int, Int) -> Memory
initializeRegisters intCode (x, y)
  = setState (setState intCode 1 x) 2 y

parseInt = read :: String -> Int

main :: IO()
main = do
  input <- readFile "input-2"
  let parsedInput = map parseInt (splitOn input ',')
  let answer = runIntCode parsedInput
  putStrLn (show answer)

main2 :: IO()
main2 = do
  input <- readFile "input-2"
  let parsedInput = map parseInt (splitOn input ',')
  let answer = chaseValues parsedInput [0, 1..99] [0, 1..99] 19690720
  putStrLn (show answer)
