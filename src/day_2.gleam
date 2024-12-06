import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

type Levels =
  List(Int)

type Reports =
  List(Levels)

type Direction {
  Increasing
  Decreasing
}

pub fn run() {
  let input = util.read_input_for(day: 2)
  let reports = parse_input(input)
  part_1(reports)
}

fn part_1(reports: Reports) {
  io.println("Day 2 part 1:")
  let safe_count =
    reports
    |> list.fold(from: 0, with: fn(safe_count, levels) {
      let is_safe = case levels {
        [a, b, ..rest] if a < b -> check_levels(Increasing, a, [b, ..rest])
        [a, b, ..rest] if a > b -> check_levels(Decreasing, a, [b, ..rest])
        _ -> False
      }
      case is_safe {
        True -> safe_count + 1
        False -> safe_count
      }
    })
  io.println("safe_count == " <> int.to_string(safe_count))
}

fn check_levels(direction: Direction, prev: Int, levels: Levels) -> Bool {
  case levels {
    [next, ..rest] -> {
      let diff = case direction {
        Increasing -> next - prev
        Decreasing -> prev - next
      }
      case diff {
        _ if diff >= 1 && diff <= 3 -> check_levels(direction, next, rest)
        _ -> False
      }
    }
    _ -> True
  }
}

fn parse_input(input: String) -> Reports {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) { string.split(line, " ") |> list.map(util.parse_int) })
}
