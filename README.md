# advent-of-code-2019
I'm working on the [Advent of Code](https://adventofcode.com/) problems for 2019 in this repository.
The goal is to solve as many of the problems as possible, if not all of them, using Haskell. I first learned about it during
my degree at Imperial College, but haven't used it much since besides occasionally doing the
[January tests](http://wp.doc.ic.ac.uk/ajf/haskell-tests/) for fun. Nonetheless, I thoroughly enjoyed learning about Haskell
and working with it - I'm not sure how much can be attributed to the, in my opinion, excellent Tony Field.

I'm most familiar with Java (with C++ a distant second and probably Python third), so working with Haskell can be quite
frustrating in that I'm taking a long time for something I could conceivably implement in under 5 minutes.

I'll write up some of the thinking behind my solutions, as well as what I thought part 2 was going to be when I looked at the
part 1 spec for some of the problems.

## Day 1
Time taken: 25 minutes | Time I'd expect in Java: 3 minutes

Not much to say here, just a question of following the instructions. I think a good chunk of time here was just trying to
remember how to do IO. Part 2 had a fun solution of generating a lazily-evaluated infinite list of weight computations,
and then [applying takeWhile and sum](https://github.com/jeremyk-91/advent-of-code-2019/blob/master/1/problem-1.hs#L14) on it.

## Day 2
Time taken: 30 minutes | Time I'd expect in Java: 10 minutes

We had a number of questions on custom interpreters back in uni. I used to find the syntactic sugar of having types
pointless, though I guess some experience in industry has made me value it more. Again, this felt like just a task of
following instructions. Some of the dereferencing code like `intCode!!(intCode!!(pointer + 1))` seemed horrible.

## Day 3
Time taken: 45 minutes | Time I'd expect in Java: 10 minutes

I went for the obvious solution of enumerating all points along the wires, taking the intersection of these points, and then
mapping Manhattan distance onto that. The first complexity issue popped out here: `List.intersect` is, of course, O(N^2) and
the wires covered around 10^5 points. I simply did a sort-and-merge based algorithm for an O(N log N) solution, which was
good enough; of course I would have just gone with `HashMap` and Immutables in Java to knock this out in linear time.

The real Part 2 was pretty easy, though it made me realise how much I missed things like `Maps.transformValues()` or
`foo.stream().map(function1).sorted(Comparator.comparingLong(longExtractor))`. In the end I decided to look at Haskell's
map library rather than messing around with sorted lists of key-value pairs.

### Jeremy's part 2 idea

> In part 1, the length of each segment of wire was bounded by 2<sup>10</sup>, and the length of each wire was bounded by
  2<sup>18</sup>. What happens if we changed these limits to 2<sup>63</sup> and 2<sup>63</sup> respectively? The number
  of components of each wire is bounded by 2<sup>10</sup>, still.

> Bonus: The number of components of each wire is bounded by 2<sup>20</sup>, not 2<sup>10</sup>: your algorithm
  cannot be quadratic in this.

I originally thought Part 2 would have forced you to do a more elegant geometry-based attack on this problem. Instead of
generating the full footprint of each wire, it would have been sufficient to generate a series of line segments, and then
test these for intersection. A naïve approach here of simply comparing each pair of segments would be quadratic in the
number of segments, but independent of the magnitude of the vectors.

An additional tricky bit here would be what to do with lines that are part of both wires. However, these can be handled
in constant time for each wire: if you have an axis-aligned line segment, the minimised Manhattan distance occurs either at
the end of the segment nearest to the origin on the axis it's parallel to, or in the middle if it crosses zero in the axis.

The bonus version probably can be done with a sweep line style algorithm, which should be log-linear in the number of
components.

## Day 4
Time taken: 10 minutes | Time I'd expect in Java: 8 minutes

Finally, a puzzle without needing input parsing. There are elegant ways of extracting the digits from a number... and then
there is `show` and `read`; as it turned out I didn't even need to convert back to integers, since you only need ordering
and equality on the items bearing the restrictions in mind.

For part 2, I went with a simple approach of condensing each string into a run-length encoded format, e.g. `111122` would
become `[(1, 4), (2, 2)]` and then simply checking if any pair had a second element of 2. Pretty straightforward.

I'm not doing a 25 days/25 languages challenge (I'm not sure I even know 25, and the intcode interpreters will be a
nightmare, as you end up doing quadratic work) but I imagine, if I did, today would be a good choice for languages
which are difficult to use since I'm fairly convinced the answers can be worked out by hand with a bit of combinatorics.

### Jeremy's part 2 idea

> The elves made a mistake and the range of the password was not 248345-746315, but 248345-746315 **centi-millillion**.
  That is, there are 300,003 digits after the first six.
  How many passwords are possible? (Only the part 1 restrictions apply; you can have more than doubled digits.)

Again, I thought Part 2 may have involved a more elegant attack, this time based on combinatorics. For this version of the
puzzle, you'll probably want to begin with each of the six-digit numbers from 248345 to 746314 (note: 746315 followed by
all zeroes is not valid since the numbers decrease), and consider how many ways there are to extend them into a valid
password. While some of these numbers are immediately not extensible, others including non-passwords could be if they were
increasing (e.g. while `234567` is not a valid password, `234567` followed by all 8s is valid).

Walking down all of the possible passwords, even accounting for pruning of decreasing passwords is likely to be a no-go.
The trick here involves what's known as *memoisation*: for example, 223348 and 223358 can extend to the same number of
passwords, because we already have a double *and* the remaining digits must not decrease from 8, so the ways in which they
can be validly extended to form a full password must have the same suffix. Once we figure this out once, we can re-use
the number without computing it again. The "state" we are looking at here would be the number of digits to fill in,
and our last digit. We actually don't need to worry about the doubling because of a good friend called the pigeonhole
principle: any nondecreasing sequence of length 300,009 will have doubled-up digits.

## Day 5
Time taken: 75 minutes | Time I'd expect in Java: 20 minutes

Probably could have done this faster, but I ended up reimplementing quite a good chunk of the intcode interpreter so
I at least have types to work with. Again, there wasn't very much here other than following the instructions.

There was a bit of slightly dodgy code to parse the digits of a number, with possible leading zeroes. I had

```
normaliseInstruction x = normaliseInstruction' ((map (read . return) $ (reverse $ show x)) ++ (repeat 0))
```

where I basically converted an integer to digits, converted those digits back to numbers, reversed it and added
infinite leading zeroes, then processed it in terms of creating an instruction.

I did struggle with getting the right answer to Part 1 at first, because I didn't initially realise that the output
instruction could take immediate mode arguments. I also lost some time debugging as well because I set input to 55 as
part of testing out the sample programs, and then was wondering why I was having unexpected opcodes of 55 when running
the actual program. I even opened up the GHCI debugger for possibly the first time (definitely the first time in years).

## Day 6
Time taken: 25 minutes | Time I'd expect in Java: 10 minutes

In the first part, the number of things that something is orbiting is given by their distance from the root node,
`COM`, and a way to find this is by breadth-first search. I used the Map interface again to store the graph as,
effectively, an adjacency list. I'd normally use a queue, but went for a frontier-based approach instead because
I wanted the distances.

For the second part, I added the reverse edges to the graph, and then found the distance from `YOU` to `SAN`.
My BFS already had a visited set to avoid cycles (even though this probably wasn't needed in part 1). One last trick
here was that the number of *transfers* is of course the distance minus 2.

## Day 7
Time taken: 40 minutes | Time I'd expect in Java: 15 minutes

Very much a tale of two different parts. The first was really easy and I almost felt cheap for using Haskell, since
it already gives you the copying for free. Part two, on the other hand, required some nontrivial reengineering - in
particular, I used to only expose the outputs, while I now needed to expose the current value of the pointer of each
program as well.

I also learned about Haskell's `trace` utilities today when trying to find a bug in my part 2 implementation: it turned
out that while I managed a list of input buffers, I forgot to clear the buffers after the program run, meaning that
it would re-process the inputs several times. I was worried that purity would get in the way of my debugging (since
I would just use a debugger or print statements if I was using Java), but once I slapped on a `trace`:

```
testLoopPermutation :: [(Memory, Int)] -> Int -> [[Int]] -> Int
testLoopPermutation programs amp inputs
  | amp == 4 && hasHalted = last outputs
  | otherwise             = trace (show (inputs, outputs)) $ testLoopPermutation programs' amp' inputs'
  where (currentProgram, currentPointer) = programs!!amp
        (mem, outputs, pointer) = runIntCodeFromState currentProgram currentPointer (inputs!!amp)
        hasHalted = mem!!pointer == 99
        programs' = set programs amp (mem, pointer)
        amp' = (amp + 1) `mod` 5
        inputs' = set inputs amp' ((inputs!!amp') ++ outputs) -- WRONG
```

and saw the programs having ever-growing input queues

```
([[6,0],[8],[5],[9],[7]],[0])
([[6,0],[8,0],[5],[9],[7]],[2])
([[6,0],[8,0],[5,2],[9],[7]],[3])
([[6,0],[8,0],[5,2],[9,3],[7]],[6])
([[6,0],[8,0],[5,2],[9,3],[7,6]],[12])
([[6,0,12],[8,0],[5,2],[9,3],[7,6]],[8,0,24])
([[6,0,12],[8,0,8,0,24],[5,2],[9,3],[7,6]],[16,0,10,1,25])
([[6,0,12],[8,0,8,0,24],[5,2,16,0,10,1,25],[9,3],[7,6]],[7,3,17,2,20,2,50])
([[6,0,12],[8,0,8,0,24],[5,2,16,0,10,1,25],[9,3,7,3,17,2,20,2,50],[7,6]],[11,6,9,5,18,4,40,4,100])
```

the problem was obvious. I'd still not be confident doing more sophisticated debugging like this, but having a simple
print-based method should simplify things a lot going forward.

## Day 8
Time taken: 12 minutes | Time I'd expect in Java: 5 minutes

This one is also largely a question of following the instructions. I initially got a wrong answer for part 1 because
I accidentally read the target layer as the one with the most zeroes as opposed to fewer. I found it a bit strange that
part 1 didn't actually reference the positions of the pixels; I simply built frequency tables, treating each layer as
an amorphous string.

Part 2 was pretty much as expected, given the way the question was set up I figured we would get to decoding the images.
I was a bit unsure about what to do for the edge case where all layers are transparent. I decided to just throw, though
in general this wouldn't quite make sense for image editing programs. I'm not sure if a sub-linear algorithm exists, it
feels like you need to read enough pixels to be sure you've found the first non-transparent one.

I was a bit worried reading the answer off the puzzle would have been a bit more puzzle-hunty, possibly involving some
kind of steganography. Or, perhaps worse...

### Jeremy's part 2 idea

> As in the real Part 2, but the image is 8 pixels tall and 1,000,000 pixels in width.
  It is guaranteed that the image contains a message consisting of letters from the English alphabet, but it is not
  guaranteed that the same letter is *exactly* represented in the same way.
  To help you out, it is guaranteed that letters don't overlap, and
  are definitively separated by two columns of white pixels - furthermore, it is never the case that a single letter
  has an internal gap of two columns of white pixels.

In other words, an OCR problem! Thankfully the real part 2 could be done by hand.

## Day 9
Time taken: 80 minutes | Time I'd expect in Java: 45 minutes

Most of the difficulty here was figuring out what the semantics were supposed to be. For some time I had errors in
the old op-codes for add, multiply and logic operators as I didn't account for the arguments of _those_ operations to
be usable in relative mode. I think the tester program in part 1 was also a bit of a trap in that it told me for a while
that `203` was the opcode I was not handling correctly, even when it should actually have been `2xx01` or something
like that.

Otherwise, implementing the new features (long memory, relative mode) was quite easy, with fairly standard refactoring.
At least in some ways part 1 *was* basically the same as part 2 here.

## Day 10
Time taken: 30 minutes | Time I'd expect in Java: 10 minutes

I saw the problem and was immediately reminded of something I'd solved on Codeforces a year or few years ago.
Basically, testing a given site consists of extracting all of the vectors of the asteroids relative to that site,
and then counting the number of unique ones once normalised.

Part 2 was smooth enough in concept: group the asteroids by the bearings of their vectors relative to north, then
repeatedly execute sweeps of the groups until exhausted (or until the 200th element is pulled). I enjoyed the
implementation less, and am not too happy with my solution: still feels very imperative/procedural in nature.

Quite a lot of time was also spent figuring out how to convert `atan2` to bearings relative to north.
