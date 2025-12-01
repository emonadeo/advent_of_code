import gleam/list.{Continue, Stop}
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder}

pub fn part_01(lines: Yielder(String)) -> Int {
  let assert [patterns, _, ..towels] = lines |> yielder.to_list()
  let patterns = patterns |> string.split(", ") |> set.from_list()
  towels
  |> list.filter(fn(towel) { patterns |> can_form(towel) })
  |> list.length()
}

pub fn part_02(lines: Yielder(String)) -> Int {
  todo
}

pub fn can_form(patterns: Set(String), string: String) -> Bool {
  case string {
    "" -> True
    _ ->
      patterns
      |> set.filter(fn(pattern) { string |> string.starts_with(pattern) })
      |> set.map(fn(pattern) {
        string.drop_start(string, string.length(pattern))
      })
      |> set.to_list()
      |> list.any(fn(rest) { can_form(patterns, rest) })
  }
}
// pub fn can_form_some(strings: List(String), patterns: List(String)) -> Bool {
//   case strings |> list.contains("") {
//     True -> True
//     False ->
//       patterns
//       |> list.filter(fn(pattern) { string |> string.starts_with(pattern) })
//       |> list.map(fn(pattern) {
//         string.drop_start(string, string.length(pattern))
//       })
//       |> can_form(patterns)
//   }
// }
