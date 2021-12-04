package jkong.aoc.instanced;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.util.*;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.stream.Collectors;

public class BinaryDiagnostic {
    public static void main(String[] args) {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        List<String> binaryInputs = br.lines().collect(Collectors.toList());
        System.out.println(findOxygenGeneratorRating(binaryInputs) * findCo2ScrubberRating(binaryInputs));
    }

    private static long findOxygenGeneratorRating(List<String> initialInputs) {
        return runEliminationAlgorithm(initialInputs,
                (frequencyCount, groupedStrings) -> {
                    if (frequencyCount.getOrDefault('0', 0) > frequencyCount.getOrDefault('1', 0)) {
                        return groupedStrings.get('0');
                    } else {
                        return groupedStrings.get('1');
                    }
                });
    }

    private static long findCo2ScrubberRating(List<String> initialInputs) {
        return runEliminationAlgorithm(initialInputs,
                (frequencyCount, groupedStrings) -> {
                    if (frequencyCount.getOrDefault('0', 0) <= frequencyCount.getOrDefault('1', 0)) {
                        return groupedStrings.get('0');
                    } else {
                        return groupedStrings.get('1');
                    }
                });
    }

    private static long runEliminationAlgorithm(
            List<String> initialInputs,
            BiFunction<Map<Character, Integer>, Map<Character, Set<String>>, Set<String>> candidateSelector) {
        Set<String> remainingStrings = new HashSet<>(initialInputs);
        int positionConsidered = 0;
        while (remainingStrings.size() > 1) {
            Map<Character, Integer> frequencyCount = countFrequenciesAtIndex(remainingStrings, positionConsidered);
            int finalPositionConsidered = positionConsidered;
            Map<Character, Set<String>> candidateRemainers = remainingStrings.stream()
                    .collect(Collectors.groupingBy(string -> string.charAt(finalPositionConsidered), Collectors.toSet()));
            remainingStrings = candidateSelector.apply(frequencyCount, candidateRemainers);
            positionConsidered++;
        }
        return new BigInteger(remainingStrings.iterator().next(), 2).longValue();
    }

    private static Map<Character, Integer> countFrequenciesAtIndex(Collection<String> binaryInputs, int index) {
        Map<Character, Integer> frequencyCount = new HashMap<>();
        for (String input : binaryInputs) {
            if (input.length() > index) {
                countFrequencyAtIndex(frequencyCount, input, index);
            }
        }
        return frequencyCount;
    }

    private static Map<Integer, Map<Character, Integer>> countFrequencies(Collection<String> binaryInputs) {
        Map<Integer, Map<Character, Integer>> frequencyCount = new HashMap<>();

        for (String input : binaryInputs) {
            for (int index = 0; index < input.length(); index++) {
                countFrequencyAtIndex(frequencyCount.computeIfAbsent(index, _unused -> new HashMap<>()), input, index);
            }
        }
        return frequencyCount;
    }

    private static void countFrequencyAtIndex(Map<Character, Integer> frequencyMap, String input, int index) {
        frequencyMap.put(input.charAt(index), frequencyMap.getOrDefault(input.charAt(index), 0) + 1);
    }

    private static void findGammaAndEpsilon(Map<Integer, Map<Character, Integer>> frequencyCount) {
        StringBuilder gammaBuilder = new StringBuilder();
        StringBuilder epsilonBuilder = new StringBuilder();
        for (int index = 0; index < frequencyCount.size(); index++) {
            int zeroes = frequencyCount.get(index).getOrDefault('0', 0);
            int ones = frequencyCount.get(index).getOrDefault('1', 0);
            if (zeroes < ones) {
                gammaBuilder.append('1');
                epsilonBuilder.append('0');
            } else {
                gammaBuilder.append('0');
                epsilonBuilder.append('1');
            }
        }
        String gamma = gammaBuilder.toString();
        String epsilon = epsilonBuilder.toString();
        BigInteger numericGamma = new BigInteger(gamma, 2);
        BigInteger numericEpsilon = new BigInteger(epsilon, 2);
        System.out.println(numericGamma.multiply(numericEpsilon));
    }
}
