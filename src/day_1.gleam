import gleam/int
import gleam/io
import gleam/list
import gleam/string
import read_input.{read_input_for}

pub fn run() {
  io.println("Day 1:")
  let #(list_1, list_2) =
    read_input_for(day: 1)
    |> string.trim()
    |> string.split("\n")
    |> list.fold(from: #([], []), with: fn(acc, line) {
      let #(list_1, list_2) = acc
      case string.split(line, "   ") {
        [a, b] -> #([parse_int(a), ..list_1], [parse_int(b), ..list_2])
        _ -> panic as "bruh– this should not happen"
      }
    })

  let list_1_sorted = list.sort(list_1, by: int.compare)
  let list_2_sorted = list.sort(list_2, by: int.compare)

  let total_distance = calc_distance(list_1_sorted, list_2_sorted, 0)

  io.println("The final result is " <> int.to_string(total_distance))
}

fn parse_int(str: String) -> Int {
  let assert Ok(res) = int.parse(str)
  res
}

fn calc_distance(list_1: List(Int), list_2: List(Int), total: Int) -> Int {
  case list_1, list_2 {
    [a, ..rest_1], [b, ..rest_2] ->
      calc_distance(rest_1, rest_2, total + int.absolute_value(a - b))
    _, _ -> total
  }
}
