import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}
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
    let levels = yielder.from_list(levels)

    let is_safe = case error_tolerance {
      True -> {
        let levels = yielder.index(levels)

        levels
        |> yielder.any(fn(skip) {
          levels
          |> yielder.filter(fn(item) { item.1 != skip.1 })
          |> yielder.map(fn(item) { item.0 })
          |> are_levels_safe
        })
      }
      False -> are_levels_safe(levels)
    }

    case is_safe {
      True -> safe_count + 1
      False -> safe_count
    }
  })
}

fn are_levels_safe(levels: Yielder(Int)) -> Bool {
  levels
  |> yielder.try_fold(#(None, None), fn(acc, level) {
    case acc, level {
      #(None, None), level -> Ok(#(Some(level), None))

      #(Some(prev), dir), level if level > prev && level - prev <= 3 ->
        case dir {
          None | Some(Increasing) -> Ok(#(Some(level), Some(Increasing)))
          _ -> Error(Nil)
        }

      #(Some(prev), dir), level if level < prev && prev - level <= 3 ->
        case dir {
          None | Some(Decreasing) -> Ok(#(Some(level), Some(Decreasing)))
          _ -> Error(Nil)
        }

      _, _ -> Error(Nil)
    }
  })
  |> result.is_ok
}

fn parse_input(input: String) -> Reports {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) { string.split(line, " ") |> list.map(util.parse_int) })
}
