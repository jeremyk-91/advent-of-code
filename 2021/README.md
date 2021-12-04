# advent-of-code-2021

## Foreword
I've tried this a bunch of times, typically with only partial success. Usually I find that I have an ambition to try a
new language. That's well and good, but for a change I should actually try and finish this. We thus stick with my best
language, Java.

## Tasks
### Day 1: Sonar Sweep
This is basically a task of following the instructions. A linear scan should do the job in both cases, and while you
could probably get away with an O(NK) algorithm in the second part, where K is the length of the sliding window 
(especially since `K = 3` in this problem) it felt dirty to do that so I did implement the "proper" sliding window
check.

### Day 2: Dive
This one asks you to parse a string and then follow the specification on what each of the possible commands actually
does. The first part can be handled in a stateless way (and was how I implemented it) while the latter requires
tracking a very minimal amount of state.

### Day 3: Binary Diagnostic
The first part is straightforward counting. The second I think was more a problem of reading the spec carefully, though
they were very kind with the test cases. Pretty straightforward overall, though I can see factoring this neatly, and/or
dealing with edge cases in practice somewhat challenging or annoying. Doing this efficiently might also be tricky.

### Day 4: Giant Squid
Tasks around 2D arrays tend to be finicky to implement, especially if they MUST be done efficiently. Thankfully it
didn't need to be super-efficient and I was thus able to get away with having a map of coordinates. The approach was
fairly straightforward: simulate the gameplay loop on each of the bingo cards, and pick the first (or in part 2, the
last) to win. I had a bit of an inconvenience with an approach of choosing immutable wrappers of coordinate-number
maps as opposed to mutating state in part two (since one needs to remember which card was relevant for more iterations
of the gameplay loop before scoring).

This would probably also have been the first day where the input format of the tickets might have posed a challenge (in
particular, naive use of string splitting would fail). I knew to use a `+`for the regex, but missed leading whitespace 
causing problems for my `String.split()` on the first go-around, though quickly isolated it with the debugger.
