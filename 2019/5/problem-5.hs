import System.Environment
import Data.List

type Memory = [Int]
type BinaryOperator = Int -> Int -> Int
type Output = (Memory, [Int])
type Instruction = (Int, Int, Int, Int)

data Operation = Add Mode Mode | Multiply Mode Mode | Halt | Input | Output Mode
  | JumpIfTrue Mode Mode | JumpIfFalse Mode Mode | LessThan Mode Mode | Equals Mode Mode
  deriving (Eq, Show)
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
  | opcode == 5    = JumpIfTrue (parseMode mode1) (parseMode mode2)
  | opcode == 6    = JumpIfFalse (parseMode mode1) (parseMode mode2)
  | opcode == 7    = LessThan (parseMode mode1) (parseMode mode2)
  | opcode == 8    = Equals (parseMode mode1) (parseMode mode2)
  | opcode == 99   = Halt
  | otherwise      = error ("opcode " ++ (show opcode))

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
      (performBinaryOperation (m1, m2) (+) intCode pointer)
      (pointer + 4)
      output
runOperation (Multiply m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (*) intCode pointer)
      (pointer + 4)
      output
runOperation Input intCode pointer output
  = runIntCodeWithBuffers
      (setMemory intCode (loadMemory intCode (pointer + 1)) 5)
      (pointer + 2)
      output
runOperation (Output mode) intCode pointer output
  = runIntCodeWithBuffers
      intCode
      (pointer + 2)
      (output ++ [(getValue intCode mode (pointer + 1))])
runOperation op@(JumpIfTrue m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      intCode
      (shiftPointer op intCode pointer)
      output
runOperation op@(JumpIfFalse m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      intCode
      (shiftPointer op intCode pointer)
      output
runOperation (LessThan m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (boolToDigital (<)) intCode pointer)
      (pointer + 4)
      output
runOperation (Equals m1 m2) intCode pointer output
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (boolToDigital (==)) intCode pointer)
      (pointer + 4)
      output

boolToDigital :: (Int -> Int -> Bool) -> BinaryOperator
boolToDigital f x y
  | f x y     = 1
  | otherwise = 0

performBinaryOperation :: (Mode, Mode) -> BinaryOperator -> Memory -> Int -> Memory
performBinaryOperation (m1, m2) operator intCode pointer
  = setMemory intCode value3 (operator value1 value2)
  where
    (value1, value2, value3) = parseTwoArgumentsAndDestination (m1, m2) intCode pointer

-- Returns the new value of the pointer for jumps
shiftPointer :: Operation -> Memory -> Int -> Int
shiftPointer (JumpIfTrue m1 m2) intCode pointer
  | value1 == 0 = pointer + 3
  | otherwise   = value2
  where
    value1 = getValue intCode m1 (pointer + 1)
    value2 = getValue intCode m2 (pointer + 2)
shiftPointer (JumpIfFalse m1 m2) intCode pointer
  | value1 == 0 = value2
  | otherwise   = pointer + 3
  where
    value1 = getValue intCode m1 (pointer + 1)
    value2 = getValue intCode m2 (pointer + 2)

parseTwoArgumentsAndDestination :: (Mode, Mode) -> Memory -> Int -> (Int, Int, Int)
parseTwoArgumentsAndDestination (mode1, mode2) intCode pointer = (x, y, z)
  where
    x = getValue intCode mode1 (pointer + 1)
    y = getValue intCode mode2 (pointer + 2)
    z = loadMemory intCode (pointer + 3)

getValue :: Memory -> Mode -> Int -> Int
getValue memory mode pointer
  = loadMemory memory (getArgument memory mode pointer)

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
