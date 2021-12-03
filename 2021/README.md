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
