package jkong.aoc.instanced;

import com.google.common.annotations.VisibleForTesting;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;
import java.util.stream.Collectors;

public class SonarSweep {
    public static void main(String[] args) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        List<Long> depths = reader.lines().map(Long::parseLong).collect(Collectors.toList());

        // Part 2
        int slidingIncreases = countSlidingIncreases(depths);
        System.out.println(slidingIncreases);
    }

    @VisibleForTesting
    static int countSlidingIncreases(List<Long> depths) {
        int slidingIncreases = 0;
        long slidingWindowValue = depths.get(0) + depths.get(1) + depths.get(2);
        for (int i = 3; i < depths.size(); i++) {
            long newSlidingValue = slidingWindowValue + depths.get(i) - depths.get(i - 3);
            if (newSlidingValue > slidingWindowValue) {
                slidingIncreases++;
            }
            slidingWindowValue = newSlidingValue;
        }
        return slidingIncreases;
    }

    @VisibleForTesting
    static int countIncreases(List<Long> depths) { // Part 1
        int increases = 0;
        for (int i = 0; i < depths.size() - 1; i++) {
            if (depths.get(i+1) > depths.get(i)) {
                increases++;
            }
        }
        return increases;
    }
}
