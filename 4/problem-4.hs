import System.Environment
import Data.List

hasDoubleNumber :: Int -> Bool
hasDoubleNumber = hasRepeatCharacter . show

hasRepeatCharacter :: String -> Bool
hasRepeatCharacter str = hasRepeatCharacter' (tail str) (head str)

hasRepeatCharacter' :: String -> Char -> Bool
hasRepeatCharacter' [] _ = False
hasRepeatCharacter' (x:xs) c
  | x == c    = True
  | otherwise = hasRepeatCharacter' xs x

hasSomeStrictlyDoubleNumber :: Int -> Bool
hasSomeStrictlyDoubleNumber = hasSomeStrictlyRepeatingCharacter . show

hasSomeStrictlyRepeatingCharacter :: String -> Bool
hasSomeStrictlyRepeatingCharacter xs = null $ filter (\(x, y) -> y == 2) runs
  where runs = segmentIntoRuns xs

segmentIntoRuns :: (Eq a) => [a] -> [(a, Int)]
segmentIntoRuns [] = []
segmentIntoRuns (x:xs) = segmentIntoRuns' xs x 1

segmentIntoRuns' :: (Eq a) => [a] -> a -> Int -> [(a, Int)]
segmentIntoRuns' [] e freq = [(e, freq)]
segmentIntoRuns' (x:xs) e freq
  | x == e    = segmentIntoRuns' xs e (freq + 1)
  | otherwise = (e, freq):segmentIntoRuns' xs x 1

isNondecreasingDigitSequence :: Int -> Bool
isNondecreasingDigitSequence = areCharactersNondecreasing . show

areCharactersNondecreasing :: String -> Bool
areCharactersNondecreasing str = all (\(x,y) -> x <= y) $ (zip str $ tail str)

nums = [248345, 248346..746315]
possiblePasswords = filter (\x -> hasDoubleNumber x && isNondecreasingDigitSequence x) nums
answer1 = length possiblePasswords

possiblePasswords' = filter (\x -> hasSomeStrictlyDoubleNumber x && isNondecreasingDigitSequence x) nums
answer2 = length possiblePasswords'
