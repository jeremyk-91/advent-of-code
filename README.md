# advent-of-code-2019
I'm working on the [Advent of Code](https://adventofcode.com/) problems for 2019 in this repository.
The goal is to solve as many of the problems, if not all of them, using Haskell. I first learned about it during my degree
at Imperial College, but haven't used it much since besides occasionally doing the 
[January tests](http://wp.doc.ic.ac.uk/ajf/haskell-tests/) for fun. Nonetheless, I thoroughly enjoyed learning about Haskell
and working with it - I'm not sure how much can be attributed to the, in my opinion, excellent Tony Field.

I'm most familiar with Java (with C++ a distant second and probably Python third), so working with Haskell can be quite 
frustrating in that I'm taking a long time for something I could conceivably implement in under 5 minutes.

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

I was kind of scared Part 2 would have simply expanded the scale of the wires, so that you had to determine the intersections
without actually building the set of what the wires did - and possibly even not be allowed to build the explicit set of 
intersections (if there were too many, because the wires had identical segments running parallel). If you have a vector along 
which both wires intersect, it seems like the closest point is either one of the ends, or possibly some point in the middle if 
the vector crosses zero in either axis.

The real Part 2 was pretty easy, though it made me realise how much I missed things like `Maps.transformValues()` or
`foo.stream().map(function1).sorted(Comparator.comparingLong(longExtractor))`. In the end I decided to look at Haskell's
map library rather than messing around with sorted lists of key-value pairs.
