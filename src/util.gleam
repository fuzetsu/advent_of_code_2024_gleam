import gleam/int
import simplifile

pub fn read_input_for(day day_num: Int) -> String {
  let day_num = int.to_string(day_num)
  let assert Ok(input) = simplifile.read("./src/inputs/day_" <> day_num)
  input
}

pub fn parse_int(str: String) -> Int {
  let assert Ok(res) = int.parse(str)
  res
}
