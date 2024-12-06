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
  part_2(reports)
}

fn part_1(reports: Reports) {
  io.println("Day 2 part 1:")
  let safe_count = get_safe_count(reports, False)
  io.println("safe_count == " <> int.to_string(safe_count))
}

fn part_2(reports: Reports) {
  io.println("Day 2 part 2:")
  let safe_count = get_safe_count(reports, True)
  io.println("safe_count == " <> int.to_string(safe_count))
}

fn get_safe_count(reports: Reports, error_tolerance: Bool) -> Int {
  reports
  |> list.fold(from: 0, with: fn(safe_count, levels) {
    let is_safe = case levels {
      [a, b, ..rest] if a < b ->
        check_levels(Increasing, a, error_tolerance, [b, ..rest])
      [a, b, ..rest] if a > b ->
        check_levels(Decreasing, a, error_tolerance, [b, ..rest])
      [a, b, ..rest] if error_tolerance && a == b ->
        case rest {
          [c, ..rest] if b < c ->
            check_levels(Increasing, b, False, [c, ..rest])
          [c, ..rest] if c > b ->
            check_levels(Decreasing, b, False, [c, ..rest])
          _ -> False
        }
      _ -> False
    }
    case is_safe {
      True -> safe_count + 1
      False -> safe_count
    }
  })
}

fn check_levels(
  direction: Direction,
  prev: Int,
  error_tolerance: Bool,
  levels: Levels,
) -> Bool {
  case levels {
    [next, ..rest] -> {
      let diff = case direction {
        Increasing -> next - prev
        Decreasing -> prev - next
      }
      case diff {
        _ if diff >= 1 && diff <= 3 ->
          check_levels(direction, next, error_tolerance, rest)
        _ ->
          case error_tolerance {
            True ->
              case check_levels(direction, prev, False, rest) {
                True -> True
                False -> check_levels(direction, next, False, rest)
              }
            False -> False
          }
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
