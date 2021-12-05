package jkong.aoc.instanced;

import com.google.common.collect.ImmutableSet;
import jkong.aoc.tools.Coordinate;
import org.immutables.value.Value;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class HydrothermalVenture {
    public static void main(String[] args) {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        List<Segment> segments = br.lines().map(Segment::parse).collect(Collectors.toList());
        Map<Coordinate, Integer> pointFrequency = calculatePointFrequency(segments);
        System.out.println(pointFrequency.entrySet().stream().filter(entry -> entry.getValue() >= 2).count());
    }

    private static Map<Coordinate, Integer> calculatePointFrequency(List<Segment> segments) {
        return segments.stream()
                .flatMap(segment -> segment.findLatticePoints().stream())
                .collect(Collectors.groupingBy(x -> x))
                .entrySet()
                .stream()
                .collect(Collectors.toMap(Map.Entry::getKey, entry -> entry.getValue().size()));
    }

    @Value.Immutable
    interface Segment {
        Coordinate start();
        Coordinate finish();

        @Value.Lazy
        default Set<Coordinate> findLatticePoints() {
            int yDelta = finish().y() - start().y();
            int xDelta = finish().x() - start().x();

            // TODO (jkong): Only works for horizontal or vertical lines
            if (xDelta == 0) {
                return IntStream.rangeClosed(Math.min(start().y(), finish().y()), Math.max(start().y(), finish().y()))
                        .mapToObj(yCoordinate -> Coordinate.of(start().x(), yCoordinate))
                        .collect(Collectors.toSet());
            } else if (yDelta == 0) {
                return IntStream.rangeClosed(Math.min(start().x(), finish().x()), Math.max(start().x(), finish().x()))
                        .mapToObj(xCoordinate -> Coordinate.of(xCoordinate, start().y()))
                        .collect(Collectors.toSet());
            } else if (xDelta == yDelta) {
                if (xDelta > 0) {
                    return IntStream.rangeClosed(0, xDelta)
                            .mapToObj(xCoordinate -> Coordinate.of(start().x() + xCoordinate, start().y() + xCoordinate))
                            .collect(Collectors.toSet());
                } else {
                    return IntStream.rangeClosed(0, Math.abs(xDelta))
                            .mapToObj(xCoordinate -> Coordinate.of(start().x() - xCoordinate, start().y() - xCoordinate))
                            .collect(Collectors.toSet());
                }
            } else if (xDelta == -yDelta) {
                if (xDelta > 0) {
                    return IntStream.rangeClosed(0, xDelta)
                            .mapToObj(xCoordinate -> Coordinate.of(start().x() + xCoordinate, start().y() - xCoordinate))
                            .collect(Collectors.toSet());
                } else {
                    return IntStream.rangeClosed(0, Math.abs(xDelta))
                            .mapToObj(xCoordinate -> Coordinate.of(start().x() - xCoordinate, start().y() + xCoordinate))
                            .collect(Collectors.toSet());
                }
            }
            throw new IllegalStateException("Received line that is not horizontal, vertical, or diagonally 45 degrees");
        }

        private static Segment parse(String input) {
            String[] components = input.split("->");
            return ImmutableSegment.builder()
                    .start(parseCommaDelimited(components[0]))
                    .finish(parseCommaDelimited(components[1]))
                    .build();
        }

        private static Coordinate parseCommaDelimited(String coordinate) {
            List<Integer> numbers = Arrays.stream(coordinate.split(","))
                    .map(String::trim).map(Integer::parseInt).collect(Collectors.toList());
            return Coordinate.of(numbers.get(0), numbers.get(1));
        }
    }
}
