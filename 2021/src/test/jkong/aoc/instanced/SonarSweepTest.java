package jkong.aoc.instanced;

import com.google.common.collect.ImmutableList;
import org.junit.Test;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

public class SonarSweepTest {
    @Test
    public void sampleSimpleIncreases() {
        assertThat(SonarSweep.countIncreases(list(199, 200, 208, 210, 200, 207, 240, 269, 260, 263)))
                .isEqualTo(7);
    }

    @Test
    public void sampleSlidingIncreases() {
        assertThat(SonarSweep.countSlidingIncreases(list(199, 200, 208, 210, 200, 207, 240, 269, 260, 263)))
                .isEqualTo(5);
    }

    private static List<Long> list(int... numbers) {
        return Arrays.stream(numbers).asLongStream().boxed().collect(Collectors.toList());
    }
}