package jkong.aoc.instanced;

import org.immutables.value.Value;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;
import java.util.stream.Collectors;

public class Dive {
    public static void main(String[] args) {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        List<Command> commands = br.lines().map(Command::fromString).collect(Collectors.toList());

        long aim = 0;
        long horizontalPosition = 0;
        long depth = 0;
        for (Command c : commands) {
            if (c.commandType() == CommandType.DOWN) {
                aim += c.numericalParameter();
            } else if (c.commandType() == CommandType.UP) {
                aim -= c.numericalParameter();
            } else {
                horizontalPosition += c.numericalParameter();
                depth += c.numericalParameter() * aim;
            }
        }
        System.out.println(horizontalPosition * depth);
    }

    private static void cartesianAnalysis(List<Command> commands) {
        long horizontalPosition = commands.stream()
                .filter(c -> c.commandType() == CommandType.FORWARD)
                .mapToLong(Command::numericalParameter)
                .sum();
        long verticalPosition = commands.stream()
                .filter(c -> c.commandType() != CommandType.FORWARD)
                .mapToLong(c -> {
                    if (c.commandType() == CommandType.DOWN) {
                        return c.numericalParameter();
                    }
                    return c.numericalParameter() * -1;
                })
                .sum();
        System.out.println(horizontalPosition * verticalPosition);
    }

    enum CommandType {
        FORWARD,
        DOWN,
        UP;

        public static CommandType tryParse(String component) {
            switch (component) {
                case "forward":
                    return FORWARD;
                case "down":
                    return DOWN;
                case "up":
                    return UP;
                default:
                    throw new IllegalStateException("unknown command type" + component);
            }
        }
    }

    @Value.Immutable
    interface Command {
        CommandType commandType();
        long numericalParameter();

        static Command fromString(String stringForm) {
            String[] components = stringForm.split(" ");
            CommandType commandType = CommandType.tryParse(components[0]);
            return ImmutableCommand.builder()
                    .commandType(commandType)
                    .numericalParameter(Long.parseLong(components[1]))
                    .build();
        }
    }
}
