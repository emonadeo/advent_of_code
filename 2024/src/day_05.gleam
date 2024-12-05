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
  let assert Ok(#(rules, updates)) =
    lines |> yielder.to_list() |> parse_rules_and_updates()
  updates
  |> list.filter(fn(update) { is_valid(rules, update) })
  |> list.map(middle)
  |> int.sum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let assert Ok(#(rules, updates)) =
    lines |> yielder.to_list() |> parse_rules_and_updates()
  updates
  |> list.filter(fn(update) { !is_valid(rules, update) })
  |> list.map(fn(update) { fix_update(rules, update) })
  |> list.map(middle)
  |> int.sum()
}

type Rules =
  Dict(Int, Set(Int))

type Update =
  List(Int)

pub fn is_valid(rules: Rules, update: Update) -> Bool {
  case update {
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

/// `is_valid` should be checked before.
/// This function assumes that the given update is faulty.
/// Calling this on a valid update results in unnecessary computation.
pub fn fix_update(rules: Rules, update: Update) -> Update {
  use update, value <- list.fold(update, [])
  update |> append_update(value, rules)
}

pub fn append_update(update: Update, value: Int, rules: Rules) -> Update {
  let #(left, right) = {
    use element <- list.split_while(update)
    case rules |> dict.get(value) {
      Ok(befores) -> befores |> set.contains(element) |> bool.negate()
      Error(Nil) -> True
    }
  }
  case left {
    [] -> [value, ..right]
    _ -> list.append(left, [value, ..right])
  }
}

pub fn parse_rules_and_updates(
  lines: List(String),
) -> Result(#(Rules, List(Update)), Nil) {
  case lines |> list.split_while(fn(x) { !string.is_empty(x) }) {
    #(rules, [_, ..updates]) -> {
      use rules <- result.try(rules |> parse_rules())
      use updates <- result.try(
        updates |> list.map(parse_update) |> result.all(),
      )
      Ok(#(rules, updates))
    }
    _ -> Error(Nil)
  }
}

/// ## Examples
/// ```gleam
/// parse_rules(["5|69", "5|420", "5|1000", "8|32"])
/// // -> Ok(dict.from_list([
/// //      #(5, [69, 420, 1000]),
/// //      #(8, [32])
/// //    ]))
/// parse_rules("Malformed")
/// // -> Error(Nil)
/// ```
pub fn parse_rules(lines: List(String)) -> Result(Rules, Nil) {
  use rules <- result.try(lines |> list.map(parse_rule) |> result.all())
  Ok(rules |> rules_from_list())
}

/// ## Examples
/// ```gleam
/// rules_from_list([#(5,69), #(5,420), #(5,1000), #(8,32)])
/// // -> dict.from_list([
/// //      #(5, [69, 420, 1000]),
/// //      #(8, [32])
/// //    ])
/// ```
pub fn rules_from_list(rules: List(#(Int, Int))) -> Rules {
  use rules, rule <- list.fold(rules, dict.new())
  let #(value, before) = rule
  rules |> add_rule(value, before)
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
pub fn add_rule(rules: Rules, value: Int, before: Int) -> Rules {
  use entry <- dict.upsert(rules, value)
  case entry {
    Some(befores) -> befores |> set.insert(before)
    None -> set.from_list([before])
  }
}

/// ## Examples
/// ```gleam
/// parse_update("1,2,3")
/// // -> Ok([1, 2, 3])
/// parse_update("75,47,61,53,29")
/// // -> Ok([75, 47, 61, 53, 29])
/// parse_update("")
/// // -> Ok([])
/// parse_update("Malformed")
/// // -> Error(Nil)
/// ```
pub fn parse_update(input: String) -> Result(Update, Nil) {
  input |> string.split(",") |> list.map(int.parse) |> result.all()
}

/// ## Examples
/// ```gleam
/// middle([])
/// // -> 0
/// middle([1, 2])
/// // -> 1 
/// middle([1, 2, 3])
/// // -> 2
/// middle([1, 2, 3, 4])
/// // -> 2
/// middle([1, 2, 3, 4, 5])
/// // -> 3 
/// middle([75, 47, 61, 53, 29])
/// // -> 61
/// ```
pub fn middle(input: Update) -> Int {
  input
  |> list.drop(list.length(input) / 2)
  |> list.first
  |> result.unwrap(0)
}
