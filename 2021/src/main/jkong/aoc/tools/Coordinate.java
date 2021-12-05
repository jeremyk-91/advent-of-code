package jkong.aoc.tools;

import org.immutables.value.Value;

@Value.Immutable
public
interface Coordinate {
    int x();

    int y();

    static Coordinate of(int x, int y) {
        return ImmutableCoordinate.builder()
                .x(x)
                .y(y)
                .build();
    }
}
