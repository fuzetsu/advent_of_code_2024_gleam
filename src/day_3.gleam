import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import util

type Ins {
  Mul(next: String, num1: Option(String), num2: Option(String))
  Result(total: Int)
}

const start_ins = Mul("m", None, None)

pub fn run() {
  let input = util.read_input_for(day: 3)
  part_1(input)
}

fn part_1(input: String) {
  io.println("Day 3 part 1:")
  let #(total, _) =
    input
    |> string.to_graphemes
    |> list.fold(#(0, start_ins), fn(acc, char) {
      let #(total, ins) = acc
      let next_ins = case ins, char {
        Mul("m", None, None), "m" -> Mul("u", None, None)
        Mul("u", None, None), "u" -> Mul("l", None, None)
        Mul("l", None, None), "l" -> Mul("(", None, None)
        Mul("(", None, None), "(" -> Mul(",", None, None)

        Mul(",", Some(num1), None), "," -> Mul(")", Some(num1), None)
        Mul(",", num1, None), _ ->
          case is_digit(char) {
            True -> Mul(",", Some(append(num1, char)), None)
            False -> start_ins
          }

        Mul(")", Some(num1), Some(num2)), ")" ->
          Result(util.parse_int(num1) * util.parse_int(num2))
        Mul(")", Some(num1), num2), _ ->
          case is_digit(char) {
            True -> Mul(")", Some(num1), Some(append(num2, char)))
            False -> start_ins
          }

        _, _ -> start_ins
      }

      case next_ins {
        Result(x) -> #(total + x, start_ins)
        _ -> #(total, next_ins)
      }
    })

  io.println("Sum of all mul(x, y) is " <> int.to_string(total))
}

fn append(start: Option(String), add: String) -> String {
  case start {
    Some(start) -> start <> add
    _ -> add
  }
}

fn is_digit(char: String) -> Bool {
  char |> int.parse |> result.is_ok
}
