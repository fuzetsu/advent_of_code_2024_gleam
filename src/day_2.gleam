import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
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
    case check_levels(None, None, error_tolerance, levels) {
      True -> safe_count + 1
      False -> safe_count
    }
  })
}

fn check_levels(
  direction: Option(Direction),
  prev: Option(Int),
  error_tolerance: Bool,
  levels: Levels,
) -> Bool {
  case direction, prev {
    None, None ->
      case levels {
        [a, b, ..rest] if a < b ->
          check_levels(Some(Increasing), Some(a), error_tolerance, [b, ..rest])
        [a, b, ..rest] if a > b ->
          check_levels(Some(Decreasing), Some(a), error_tolerance, [b, ..rest])
        [_, ..rest] if error_tolerance -> check_levels(None, None, False, rest)
        _ -> False
      }
    Some(dir), Some(prev) -> {
      case levels {
        [next, ..rest] -> {
          let diff = case dir {
            Increasing -> next - prev
            Decreasing -> prev - next
          }
          case diff {
            _ if diff >= 1 && diff <= 3 ->
              check_levels(direction, Some(next), error_tolerance, rest)
            _ ->
              case error_tolerance {
                True ->
                  case check_levels(direction, Some(prev), False, rest) {
                    True -> True
                    False -> check_levels(direction, Some(next), False, rest)
                  }
                False -> False
              }
          }
        }
        _ -> True
      }
    }
    _, _ -> False
  }
}

fn parse_input(input: String) -> Reports {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) { string.split(line, " ") |> list.map(util.parse_int) })
}
