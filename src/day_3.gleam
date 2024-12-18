import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import util

type Ins {
  Result(total: Int)
  Mul(next: String, num1: Option(String), num2: Option(String))
  Dont(next: String)
  Disabled
  Do(next: String)
  Enabled
}

const start_ins = Mul("m", None, None)

pub fn run() {
  let input = util.read_input_for(day: 3)
  let chars = string.to_graphemes(input)
  part_1(chars)
  part_2(chars)
}

fn part_1(chars: List(String)) {
  io.println("Day 3 part 1:")
  let #(total, _) =
    chars
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

fn part_2(chars: List(String)) {
  io.println("Day 3 part 2:")
  let #(total, _) =
    chars
    |> list.fold(#(0, Enabled), fn(acc, char) {
      let #(total, ins) = acc
      let next_ins = case ins, char {
        Disabled, "d" -> Do("o")
        Disabled, _ -> Disabled

        Do("o"), "o" -> Do("(")
        Do("("), "(" -> Do(")")
        Do(")"), ")" -> Enabled
        Do(_), _ -> Disabled

        Enabled, "d" | Mul(_, _, _), "d" -> Dont("o")
        Dont("o"), "o" -> Dont("n")
        Dont("n"), "n" -> Dont("'")
        Dont("'"), "'" -> Dont("t")
        Dont("t"), "t" -> Dont("(")
        Dont("("), "(" -> Dont(")")
        Dont(")"), ")" -> Disabled

        Enabled, "m" | Dont(_), "m" -> Mul("u", None, None)
        Mul("u", None, None), "u" -> Mul("l", None, None)
        Mul("l", None, None), "l" -> Mul("(", None, None)
        Mul("(", None, None), "(" -> Mul(",", None, None)

        Mul(",", Some(num1), None), "," -> Mul(")", Some(num1), None)
        Mul(",", num1, None), _ ->
          case is_digit(char) {
            True -> Mul(",", Some(append(num1, char)), None)
            False -> Enabled
          }

        Mul(")", Some(num1), Some(num2)), ")" ->
          Result(util.parse_int(num1) * util.parse_int(num2))
        Mul(")", Some(num1), num2), _ ->
          case is_digit(char) {
            True -> Mul(")", Some(num1), Some(append(num2, char)))
            False -> Enabled
          }

        _, _ -> Enabled
      }

      case next_ins {
        Result(x) -> #(total + x, start_ins)
        _ -> #(total, next_ins)
      }
    })

  io.println("Sum of all enabled mul(x, y) is " <> int.to_string(total))
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
