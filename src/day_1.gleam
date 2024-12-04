import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import read_input.{read_input_for}

pub fn run() {
  let input = read_input_for(day: 1)
  let #(list_1, list_2) = parse_input(input)
  part_1(list_1, list_2)
  part_2(list_1, list_2)
}

fn part_1(list_1: List(Int), list_2: List(Int)) {
  io.println("Day 1 part 1:")

  let list_1_sorted = list.sort(list_1, by: int.compare)
  let list_2_sorted = list.sort(list_2, by: int.compare)

  let total_distance = calc_distance(list_1_sorted, list_2_sorted, 0)

  io.println("total_distance == " <> int.to_string(total_distance))
}

fn part_2(list_1: List(Int), list_2: List(Int)) {
  io.println("Day 1 part 2:")
  let counts =
    list.fold(list_2, dict.new(), fn(counts, num) {
      dict.insert(counts, num, result.unwrap(dict.get(counts, num), 0) + 1)
    })
  let total_similarity =
    list.fold(list_1, 0, fn(acc, num) {
      let num_count = result.unwrap(dict.get(counts, num), 0)
      acc + { num * num_count }
    })

  io.println("total_similarity == " <> int.to_string(total_similarity))
}

fn parse_input(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.fold(from: #([], []), with: fn(acc, line) {
    let assert [a, b] = string.split(line, "   ")
    #([parse_int(a), ..acc.0], [parse_int(b), ..acc.1])
  })
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
