import System.Environment
import Data.List
import Debug.Trace

type Memory = [Int]
type BinaryOperator = Int -> Int -> Int
type Output = (Memory, [Int], Int) -- memory, outputs, pointer value
type Instruction = (Int, Int, Int, Int)
type Inputs = [Int]

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

runIntCode :: Memory -> Inputs -> Output
runIntCode intCode inputs = runIntCodeWithBuffers intCode 0 [] inputs

-- Assumes output is already consumed, only returns fresh outputs
runIntCodeFromState :: Memory -> Int -> Inputs -> Output
runIntCodeFromState memory pointer inputs = runIntCodeWithBuffers memory pointer [] inputs

runIntCodeWithBuffers :: Memory -> Int -> [Int] -> Inputs -> Output
runIntCodeWithBuffers intCode pointer output inputs
  | operation == Halt = (intCode, output, pointer)
  | otherwise         = runOperation operation intCode pointer output inputs
  where
    operation = parseOperation . normaliseInstruction $ (intCode!!pointer)

runOperation :: Operation -> Memory -> Int -> [Int] -> Inputs -> Output
runOperation (Add m1 m2) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (+) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation (Multiply m1 m2) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (*) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation Input intCode pointer output []
  = (intCode, output, pointer)
runOperation Input intCode pointer output (input:remainingInputs)
  = runIntCodeWithBuffers
      (setMemory intCode (loadMemory intCode (pointer + 1)) input)
      (pointer + 2)
      output
      remainingInputs
runOperation (Output mode) intCode pointer output inputs
  = runIntCodeWithBuffers
      intCode
      (pointer + 2)
      (output ++ [(getValue intCode mode (pointer + 1))])
      inputs
runOperation op@(JumpIfTrue m1 m2) intCode pointer output inputs
  = runIntCodeWithBuffers
      intCode
      (shiftPointer op intCode pointer)
      output
      inputs
runOperation op@(JumpIfFalse m1 m2) intCode pointer output inputs
  = runIntCodeWithBuffers
      intCode
      (shiftPointer op intCode pointer)
      output
      inputs
runOperation (LessThan m1 m2) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (boolToDigital (<)) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation (Equals m1 m2) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2) (boolToDigital (==)) intCode pointer)
      (pointer + 4)
      output
      inputs

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

inputPossibilities = permutations [1,2,3,4,0]
part2Possibilities = permutations [5,6,7,8,9]

part2SignalsUngarnished = map (map (\x -> [x])) part2Possibilities
part2Signals = [(x ++ [0]):y | x:y <- part2SignalsUngarnished]

testSignalPermutation :: [Int] -> Memory -> Int -> Int
testSignalPermutation [] intCode outputSignal = outputSignal
testSignalPermutation (phase:phases) intCode outputSignal = testSignalPermutation phases intCode outputSignal'
  where (mem, outputs, pointer) = runIntCode intCode [phase, outputSignal]
        outputSignal' = head outputs

-- First arg is the programmatic state of the five amplifiers
-- Second arg is the phase settings
-- Third arg is which amplifier we're looking at (0=A, 4=E etc.)
-- Fourth arg is the input buffer for each amplifier
-- Return value is the final thing
testLoopPermutation :: [(Memory, Int)] -> Int -> [[Int]] -> Int
testLoopPermutation programs amp inputs
  | amp == 4 && hasHalted = last outputs
  | otherwise             = testLoopPermutation programs' amp' inputs'
  where (currentProgram, currentPointer) = programs!!amp
        (mem, outputs, pointer) = runIntCodeFromState currentProgram currentPointer (inputs!!amp)
        hasHalted = mem!!pointer == 99
        programs' = set programs amp (mem, pointer)
        amp' = (amp + 1) `mod` 5
        inputs' = set (set inputs amp' ((inputs!!amp') ++ outputs)) amp []

set :: [a] -> Int -> a -> [a]
set l position newValue = h ++ newValue:t
  where (h, _:t) = splitAt position l

set2 :: [a] -> Int -> (a -> a) -> [a]
set2 l position transform = h ++ (transform ov):t
  where (h, ov:t) = splitAt position l

main :: IO()
main = do
  input <- readFile "input-7"
  let parsedInput = map parseInt (splitOn input ',')
  let answer = maximum $ map (\x -> testSignalPermutation x parsedInput 0) inputPossibilities
  putStrLn (show answer)

main2 :: IO()
main2 = do
  input <- readFile "input-7"
  let parsedInput = map parseInt (splitOn input ',')
  let programs = [(x, 0) | x <- take 5 $ repeat parsedInput]
  let answer = maximum $ map (\x -> testLoopPermutation programs 0 x) part2Signals
  putStrLn (show answer)

-- main2 :: IO()
-- main2 = do
--   input <- readFile "input-2"
--   let parsedInput = map parseInt (splitOn input ',')
--   let answer = chaseValues parsedInput [0, 1..99] [0, 1..99] 19690720
--   putStrLn (show answer)
