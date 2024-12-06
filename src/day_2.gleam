import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

type Levels =
  List(Int)

type Reports =
  List(Levels)

type State {
  Danger
  Decreasing
  Increasing
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
      let state = case levels {
        [a, b, ..rest] if a < b -> is_increasing(a, [b, ..rest])
        [a, b, ..rest] if a > b -> is_decreasing(a, [b, ..rest])
        _ -> Danger
      }
      case state {
        Increasing | Decreasing -> safe_count + 1
        _ -> safe_count
      }
    })
  io.println("safe_count == " <> int.to_string(safe_count))
}

fn is_increasing(prev: Int, levels: Levels) -> State {
  case levels {
    [next, ..rest] ->
      case next - prev {
        diff if diff >= 1 && diff <= 3 -> is_increasing(next, rest)
        _ -> Danger
      }
    _ -> Increasing
  }
}

fn is_decreasing(prev: Int, levels: Levels) -> State {
  case levels {
    [next, ..rest] ->
      case prev - next {
        diff if diff > 0 && diff <= 3 -> is_decreasing(next, rest)
        _ -> Danger
      }
    _ -> Decreasing
  }
}

fn parse_input(input: String) -> Reports {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) { string.split(line, " ") |> list.map(util.parse_int) })
}
