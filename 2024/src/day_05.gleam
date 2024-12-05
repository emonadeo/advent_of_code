import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let assert #(rules, [_, ..updates]) =
    lines
    |> yielder.map(string.trim)
    |> yielder.to_list()
    |> list.split_while(fn(x) { !string.is_empty(x) })
  let assert Ok(rules) = rules |> parse_rules()
  let assert Ok(updates) = updates |> list.map(parse_list) |> result.all()
  updates
  |> list.filter(fn(updates) { is_valid(rules, updates) })
  |> list.map(pick_middle)
  |> int.sum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub fn is_valid(rules: Dict(Int, Set(Int)), updates: List(Int)) -> Bool {
  case updates {
    [] -> True
    [first, ..rest] -> {
      rest
      |> list.all(fn(after) {
        case rules |> dict.get(after) {
          Ok(befores) -> befores |> set.contains(first) |> bool.negate()
          Error(Nil) -> True
        }
      })
      && is_valid(rules, rest)
    }
  }
}

pub fn pick_middle(values: List(Int)) -> Int {
  values
  |> list.drop(list.length(values) / 2)
  |> list.first
  |> result.unwrap(0)
}

/// ## Examples
/// ```gleam
/// parse_rules(["5|69", "5|420", "5|1000", "8|32"])
/// // -> dict.from_list([
/// //      #(5, [69, 420, 1000]),
/// //      #(8, [32])
/// //    ])
/// parse_rule("Malformed")
/// // -> Error(Nil)
/// ```
pub fn parse_rules(lines: List(String)) -> Result(Dict(Int, Set(Int)), Nil) {
  use rules, line <- list.fold(lines, Ok(dict.new()))
  use rules <- result.try(rules)
  use rule <- result.try(line |> parse_rule())
  let #(value, before) = rule
  Ok(rules |> add_rule(value, before))
}

/// ## Examples
/// ```gleam
/// parse_rule("1|2")
/// // -> Ok(#(1, 2))
/// parse_rule("47|53")
/// // -> Ok(#(47, 53))
/// parse_rule("Malformed")
/// // -> Error(Nil)
/// ```
pub fn parse_rule(input: String) -> Result(#(Int, Int), Nil) {
  use rule <- result.try(input |> string.split_once("|"))
  let #(value, before) = rule
  use value <- result.try(value |> int.parse())
  use before <- result.try(before |> int.parse())
  Ok(#(value, before))
}

/// ## Examples
/// ```gleam
/// dict.new()
/// |> add_rule(5, 69)
/// // -> dict.from_list([#(5, [69])])
/// |> add_rule(5, 420)
/// // -> dict.from_list([#(5, [69, 420])])
/// |> add_rule(5, 1000)
/// // -> dict.from_list([#(5, [69, 420, 1000])])
/// |> add_rule(8, 32)
/// // -> dict.from_list([
/// //      #(5, [69, 420, 1000]),
/// //      #(8, [32])
/// //    ])
/// ```
pub fn add_rule(
  rules: Dict(Int, Set(Int)),
  value: Int,
  before: Int,
) -> Dict(Int, Set(Int)) {
  use entry <- dict.upsert(rules, value)
  case entry {
    Some(befores) -> befores |> set.insert(before)
    None -> set.from_list([before])
  }
}

/// ## Examples
/// ```gleam
/// parse_updates("1,2,3")
/// // -> Ok([1, 2, 3])
/// parse_updates("75,47,61,53,29")
/// // -> Ok([75, 47, 61, 53, 29])
/// parse_updates("")
/// // -> Ok([])
/// parse_rule("Malformed")
/// // -> Error(Nil)
/// ```
pub fn parse_list(input: String) -> Result(List(Int), Nil) {
  input |> string.split(",") |> list.map(int.parse) |> result.all()
}
