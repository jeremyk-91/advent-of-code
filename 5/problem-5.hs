import System.Environment
import Data.List

type Memory = [Int]
type BinaryOperator = Int -> Int -> Int
type Output = (Memory, [Int])
type Instruction = (Int, Int, Int, Int)

data Operation = Add Mode Mode | Multiply Mode Mode | Halt | Input | Output Mode deriving (Eq, Show)
data Mode = Position | Immediate deriving (Eq, Show)

-- Splits elements in a list based on a delimiter
splitOn :: (Eq a) => [a] -> a -> [[a]]
splitOn [] _ = []
splitOn list@(x:xs) a
  | x == a    = splitOn xs a
  | otherwise = head:(splitOn tail a)
    where (head, tail) = break (\x -> x == a) list

normaliseInstruction :: Int -> Instruction
normaliseInstruction x = normaliseInstruction' ((map (read . return) $ (reverse $ show x)) ++ (repeat 0))

normaliseInstruction' :: [Int] -> Instruction
normaliseInstruction' x = (opcode, mode1, mode2, mode3)
  where opcode = 10 * x!!1 + x!!0
        mode1 = x!!2
        mode2 = x!!3
        mode3 = x!!4

parseOperation :: Instruction -> Operation
parseOperation (opcode, mode1, mode2, mode3)
  | opcode == 1    = Add (parseMode mode1) (parseMode mode2)
  | opcode == 2    = Multiply (parseMode mode1) (parseMode mode2)
  | opcode == 3    = Input
  | opcode == 4    = Output (parseMode mode1)
  | opcode == 99   = Halt

parseMode :: Int -> Mode
parseMode 0 = Position
parseMode 1 = Immediate

runIntCode :: Memory -> Output
runIntCode intCode = runIntCodeWithBuffers intCode 0 []

runIntCodeWithBuffers :: Memory -> Int -> [Int] -> Output
runIntCodeWithBuffers intCode pointer output
  | operation == Halt = (intCode, output)
  | otherwise         = runOperation operation intCode pointer output
  where
    operation = parseOperation . normaliseInstruction $ (intCode!!pointer)

runOperation :: Operation -> Memory -> Int -> [Int] -> Output
runOperation (Add m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      (setMemory intCode (loadMemory intCode (pointer + 3)) ((getArgument intCode m1 (loadMemory intCode (pointer + 1))) + (getArgument intCode m2 (loadMemory intCode (pointer + 2)))))
      (pointer + 4)
      output
runOperation (Multiply m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      (setMemory intCode (loadMemory intCode (pointer + 3)) ((getArgument intCode m1 (loadMemory intCode (pointer + 1))) * (getArgument intCode m2 (loadMemory intCode (pointer + 2)))))
      (pointer + 4)
      output
runOperation Input intCode pointer output
  = runIntCodeWithBuffers
      (setMemory intCode (loadMemory intCode (pointer + 1)) 1)
      (pointer + 2)
      output
runOperation (Output mode) intCode pointer output
  = runIntCodeWithBuffers
      intCode
      (pointer + 2)
      (output ++ [(loadMemory intCode (getArgument intCode mode (pointer + 1)))])

getArgument :: Memory -> Mode -> Int -> Int
getArgument _ Immediate x = x
getArgument memory Position position
  = loadMemory memory position

-- Gets value
loadMemory :: Memory -> Int -> Int
loadMemory memory position
  = memory!!position

-- Sets the value at address (arg 2) to value (arg 3)
setMemory :: Memory -> Int -> Int -> Memory
setMemory memory position value
  = head ++ value:tail
    where (head, _:tail) = splitAt position memory

parseInt = read :: String -> Int

main :: IO()
main = do
  input <- readFile "input-5"
  let parsedInput = map parseInt (splitOn input ',')
  let answer = runIntCode parsedInput
  putStrLn (show answer)

-- main2 :: IO()
-- main2 = do
--   input <- readFile "input-2"
--   let parsedInput = map parseInt (splitOn input ',')
--   let answer = chaseValues parsedInput [0, 1..99] [0, 1..99] 19690720
--   putStrLn (show answer)