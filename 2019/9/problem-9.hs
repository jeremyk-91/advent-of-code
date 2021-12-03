import System.Environment
import Data.List
import Debug.Trace

type Memory = ([Int], Int) -- memory, relative base
type BinaryOperator = Int -> Int -> Int
type Output = (Memory, [Int], Int) -- memory, outputs, pointer value
type Instruction = (Int, Int, Int, Int)
type Inputs = [Int]

data Operation = Add Mode Mode Mode | Multiply Mode Mode Mode | Halt | Input Mode | Output Mode
  | JumpIfTrue Mode Mode | JumpIfFalse Mode Mode | LessThan Mode Mode Mode | Equals Mode Mode Mode
  | AdjustRelativeBase Mode
  deriving (Eq, Show)
data Mode = Position | Immediate | Relative deriving (Eq, Show)

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
  | opcode == 1    = Add (parseMode mode1) (parseMode mode2) (parseMode mode3)
  | opcode == 2    = Multiply (parseMode mode1) (parseMode mode2) (parseMode mode3)
  | opcode == 3    = Input (parseMode mode1)
  | opcode == 4    = Output (parseMode mode1)
  | opcode == 5    = JumpIfTrue (parseMode mode1) (parseMode mode2)
  | opcode == 6    = JumpIfFalse (parseMode mode1) (parseMode mode2)
  | opcode == 7    = LessThan (parseMode mode1) (parseMode mode2) (parseMode mode3)
  | opcode == 8    = Equals (parseMode mode1) (parseMode mode2) (parseMode mode3)
  | opcode == 9    = AdjustRelativeBase (parseMode mode1)
  | opcode == 99   = Halt
  | otherwise      = error ("opcode " ++ (show opcode))

parseMode :: Int -> Mode
parseMode 0 = Position
parseMode 1 = Immediate
parseMode 2 = Relative

runIntCode :: Memory -> Inputs -> Output
runIntCode intCode inputs = runIntCodeWithBuffers intCode 0 [] inputs

-- Assumes output is already consumed, only returns fresh outputs
runIntCodeFromState :: Memory -> Int -> Inputs -> Output
runIntCodeFromState memory pointer inputs = runIntCodeWithBuffers memory pointer [] inputs

runIntCodeWithBuffers :: Memory -> Int -> [Int] -> Inputs -> Output
runIntCodeWithBuffers (intCode, rbase) pointer output inputs
  | operation == Halt = ((intCode, rbase), output, pointer)
  | otherwise         = runOperation operation (intCode, rbase) pointer output inputs
  where
    operation = parseOperation . normaliseInstruction $ (intCode!!pointer)

runOperation :: Operation -> Memory -> Int -> [Int] -> Inputs -> Output
runOperation (Add m1 m2 m3) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2, m3) (+) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation (Multiply m1 m2 m3) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2, m3) (*) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation (Input m1) intCode pointer output []
  = (intCode, output, pointer)
runOperation (Input m1) intCode pointer output (input:remainingInputs)
  = runIntCodeWithBuffers
      (setMemory intCode (getArgument intCode m1 (pointer + 1)) input)
      (pointer + 2)
      output
      remainingInputs
runOperation (Output mode) intCode pointer output inputs
  = runIntCodeWithBuffers
      intCode
      (pointer + 2)
      (output ++ [value])
      inputs
      where value = (getValue intCode mode (pointer + 1))
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
runOperation (LessThan m1 m2 m3) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2, m3) (boolToDigital (<)) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation (Equals m1 m2 m3) intCode pointer output inputs
  = runIntCodeWithBuffers
      (performBinaryOperation (m1, m2, m3) (boolToDigital (==)) intCode pointer)
      (pointer + 4)
      output
      inputs
runOperation (AdjustRelativeBase m1) memory@(intcode, rbase) pointer output inputs
  = runIntCodeWithBuffers
      (intcode, rbase + (getValue memory m1 (pointer + 1)))
      (pointer + 2)
      output
      inputs

boolToDigital :: (Int -> Int -> Bool) -> BinaryOperator
boolToDigital f x y
  | f x y     = 1
  | otherwise = 0

performBinaryOperation :: (Mode, Mode, Mode) -> BinaryOperator -> Memory -> Int -> Memory
performBinaryOperation (m1, m2, m3) operator intCode pointer
  = setMemory intCode value3 (operator value1 value2)
  where
    (value1, value2, value3) = parseTwoArgumentsAndDestination (m1, m2, m3) intCode pointer

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

parseTwoArgumentsAndDestination :: (Mode, Mode, Mode) -> Memory -> Int -> (Int, Int, Int)
parseTwoArgumentsAndDestination (mode1, mode2, mode3) intCode pointer = (x, y, z)
  where
    x = getValue intCode mode1 (pointer + 1)
    y = getValue intCode mode2 (pointer + 2)
    z = getArgument intCode mode3 (pointer + 3)

getValue :: Memory -> Mode -> Int -> Int
getValue memory mode pointer
  = loadMemory memory (getArgument memory mode pointer)

getArgument :: Memory -> Mode -> Int -> Int
getArgument _ Immediate x = x
getArgument memory Position position
  = loadMemory memory position
getArgument memory@(intCode, rbase) Relative position
  = (loadMemory memory position) + rbase

-- Gets value
loadMemory :: Memory -> Int -> Int
loadMemory (intcode, rbase) position
  | (length intcode) > position = intcode!!position
  | otherwise                   = 0

-- Sets the value at address (arg 2) to value (arg 3)
setMemory :: Memory -> Int -> Int -> Memory
setMemory (intcode, rbase) position value
  | (length intcode) <= position = setMemoryKnownSafe (newCode, rbase) position value
  | otherwise                    = setMemoryKnownSafe (intcode, rbase) position value
    where newCode = (intcode ++ (take (position - (length intcode) + 1) (repeat 0)))

setMemoryKnownSafe :: Memory -> Int -> Int -> Memory
setMemoryKnownSafe (intcode, rbase) position value
  = (head ++ value:tail, rbase)
    where (head, _:tail) = splitAt position intcode

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

set :: [a] -> Int -> a -> [a]
set l position newValue = h ++ newValue:t
  where (h, _:t) = splitAt position l

set2 :: [a] -> Int -> (a -> a) -> [a]
set2 l position transform = h ++ (transform ov):t
  where (h, ov:t) = splitAt position l

main :: IO()
main = do
  input <- readFile "input-9"
  let parsedInput = map parseInt (splitOn input ',')
  let answer = runIntCode (parsedInput, 0) [2]
  putStrLn (show answer)
