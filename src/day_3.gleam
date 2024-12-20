import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import util

type Ins {
  Enabled
  Disabled
  Do(next: List(String))
  Dont(next: List(String))
  Mul(next: List(String), num1: Option(String), num2: Option(String))
  Product(total: Int)
}

const mul_chars = ["u", "l", "(", ",", ")"]

const dont_chars = ["o", "n", "'", "t", "(", ")"]

const do_chars = ["o", "(", ")"]

pub fn run() {
  let input = util.read_input_for(day: 3)
  let chars = string.to_graphemes(input)
  part_1(chars)
  part_2(chars)
}

fn part_1(chars: List(String)) {
  io.println("Day 3 part 1:")
  let total = calculate_sum(chars, False)
  io.println("Sum of all mul(x, y) is " <> int.to_string(total))
}

fn part_2(chars: List(String)) {
  io.println("Day 3 part 2:")
  let total = calculate_sum(chars, True)
  io.println("Sum of all enabled mul(x, y) is " <> int.to_string(total))
}

fn calculate_sum(chars: List(String), check_dos: Bool) -> Int {
  let #(total, _) =
    chars
    |> list.fold(#(0, Enabled), fn(acc, char) {
      let #(total, ins) = acc
      let next_ins = process_ins(ins, char, check_dos)
      case next_ins {
        Product(x) -> #(total + x, Enabled)
        _ -> #(total, next_ins)
      }
    })

  total
}

fn process_ins(ins: Ins, char: String, check_dos: Bool) -> Ins {
  case ins, char {
    Disabled, "d" if check_dos -> Do(do_chars)
    Disabled, _ -> Disabled
    Do([")"]), ")" -> Enabled
    Do([x, ..rest]), _ if char == x -> Do(rest)
    Do(_), _ -> process_ins(Disabled, char, check_dos)

    Enabled, "d" if check_dos -> Dont(dont_chars)
    Dont([")"]), ")" -> Disabled
    Dont([x, ..rest]), _ if char == x -> Dont(rest)
    Dont(_), _ -> process_ins(Enabled, char, check_dos)

    Enabled, "m" -> Mul(mul_chars, None, None)
    Mul([",", ..rest], Some(num1), None), "," -> Mul(rest, Some(num1), None)
    Mul([",", ..] as next, num1, None), _ ->
      case is_digit(char) {
        True -> Mul(next, Some(append(num1, char)), None)
        False -> process_ins(Enabled, char, check_dos)
      }
    Mul([")"], Some(num1), Some(num2)), ")" ->
      Product(util.parse_int(num1) * util.parse_int(num2))
    Mul([")"], Some(num1), num2), _ ->
      case is_digit(char) {
        True -> Mul([")"], Some(num1), Some(append(num2, char)))
        False -> process_ins(Enabled, char, check_dos)
      }
    Mul([next, ..rest], None, None), _ if char == next -> Mul(rest, None, None)
    Mul(_, _, _), _ -> process_ins(Enabled, char, check_dos)

    _, _ -> Enabled
  }
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
