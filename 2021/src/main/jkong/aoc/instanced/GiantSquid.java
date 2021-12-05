package jkong.aoc.instanced;

import com.google.common.base.Preconditions;
import com.google.common.collect.BiMap;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Sets;
import jkong.aoc.tools.Coordinate;
import org.immutables.value.Value;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class GiantSquid {
    private static final int BINGO_CARD_SIZE = 5;

    public static void main(String[] args) {
        // input assumptions: The first line is the ordering. Then follows a blank line, then 5 by 5 bingo grids
        // that are line separated.
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        List<String> data = br.lines().collect(Collectors.toList());
        List<Integer> ordering = Arrays.stream(data.get(0).split(",")).map(Integer::parseInt)
                .collect(Collectors.toList());
        int cardBuildingIndex = 2;
        Set<BingoCard> cards = new HashSet<>();
        while(cardBuildingIndex < data.size()) {
            if (data.get(cardBuildingIndex).isEmpty()) {
                cardBuildingIndex++;
                continue;
            }
            // not empty: start of a 5 line bingo card
            List<String> cardData = data.subList(cardBuildingIndex, cardBuildingIndex + BINGO_CARD_SIZE);
            cards.add(BingoCard.parse(cardData));
            cardBuildingIndex += BINGO_CARD_SIZE;
        }

        Optional<BingoCard> knownTarget = Optional.empty();
        for (int call : ordering) {
            System.out.println(call);
            cards = cards.stream().map(card -> card.tryDaub(call)).collect(Collectors.toSet());
            Set<BingoCard> winningCards = cards.stream().filter(BingoCard::hasWon).collect(Collectors.toSet());
            System.out.println(Sets.difference(cards, winningCards));
            if (Sets.difference(cards, winningCards).size() == 1) {
                knownTarget = Sets.difference(cards, winningCards)
                        .stream().findAny();
            }
            if (knownTarget.isPresent()) {
                BingoCard actualTarget = knownTarget.get();
                BingoCard relevantAnalogue = cards.stream()
                        .filter(card -> card.getCardNumbers().equals(actualTarget.getCardNumbers()))
                        .findAny()
                        .orElseThrow();
                if (relevantAnalogue.hasWon()) {
                    System.out.println("score = " + (relevantAnalogue.sumOfUnmarkedNumbers() * call));
                    return;
                }
            }
        }
    }

    @Value.Immutable
    interface BingoCard {
        Set<Set<Coordinate>> WIN_LINES = getWinLines();

        static Set<Set<Coordinate>> getWinLines() {
            Set<Set<Coordinate>> rows = IntStream.range(0, BINGO_CARD_SIZE)
                    .mapToObj(row -> IntStream.range(0, BINGO_CARD_SIZE)
                            .mapToObj(column -> Coordinate.of(row, column))
                            .collect(Collectors.toSet()))
                    .collect(Collectors.toSet());
            Set<Set<Coordinate>> columns = IntStream.range(0, BINGO_CARD_SIZE)
                    .mapToObj(column -> IntStream.range(0, BINGO_CARD_SIZE)
                            .mapToObj(row -> Coordinate.of(row, column))
                            .collect(Collectors.toSet()))
                    .collect(Collectors.toSet());
            return Sets.union(rows, columns);
        }

        BiMap<Coordinate, Integer> getCardNumbers();

        Set<Coordinate> daubedCoordinates();

        @Value.Lazy
        default boolean hasWon() {
            return WIN_LINES.stream().anyMatch(winLine -> daubedCoordinates().containsAll(winLine));
        }

        @Value.Lazy
        default int sumOfUnmarkedNumbers() {
            return getCardNumbers().entrySet()
                    .stream()
                    .filter(entry -> !daubedCoordinates().contains(entry.getKey()))
                    .mapToInt(Map.Entry::getValue)
                    .sum();
        }

        default BingoCard tryDaub(int calledNumber) {
            if (!getCardNumbers().containsValue(calledNumber)) {
                return this;
            }
            return ImmutableBingoCard.builder()
                    .from(this)
                    .addDaubedCoordinates(getCardNumbers().inverse().get(calledNumber))
                    .build();
        }

        static BingoCard parse(List<String> cardData) {
            ImmutableMap.Builder<Coordinate, Integer> mapBuilder = ImmutableMap.builder();
            Preconditions.checkState(cardData.size() == BINGO_CARD_SIZE,
                    "Unexpected number of strings for a card:\n" + cardData);
            for (int i = 0; i < cardData.size(); i++) {
                List<Integer> numbers = Arrays.stream(cardData.get(i).trim().split(" +"))
                        .map(Integer::parseInt)
                        .collect(Collectors.toList());
                int rowIndexCopy = i;
                IntStream.range(0, numbers.size())
                        .forEach(index -> mapBuilder.put(Coordinate.of(index, rowIndexCopy), numbers.get(index)));
            }
            return ImmutableBingoCard.builder()
                    .putAllCardNumbers(mapBuilder.build())
                    .build();
        }
    }

}
