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
  let assert Ok(#(successor_dict, updates)) =
    lines |> yielder.to_list() |> parse()

  updates
  |> list.filter(fn(update) { update |> is_valid(successor_dict) })
  |> list.map(middle_page_number)
  |> int.sum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let assert Ok(#(successor_dict, updates)) =
    lines |> yielder.to_list() |> parse()

  updates
  |> list.filter(fn(update) {
    update |> is_valid(successor_dict) |> bool.negate()
  })
  |> list.map(fn(update) { update |> sort(successor_dict) })
  |> list.map(middle_page_number)
  |> int.sum()
}

pub type Rule =
  #(Int, Int)

pub type SuccessorDict =
  Dict(Int, Set(Int))

pub type Update =
  List(Int)

pub fn is_valid(update: Update, successor_dict: SuccessorDict) -> Bool {
  case update {
    [] -> True
    [first, ..rest] -> {
      rest
      |> list.all(fn(after) {
        case successor_dict |> dict.get(after) {
          Ok(successors) -> successors |> set.contains(first) |> bool.negate()
          Error(Nil) -> True
        }
      })
      && rest |> is_valid(successor_dict)
    }
  }
}

pub fn parse(lines: List(String)) -> Result(#(SuccessorDict, List(Update)), Nil) {
  case lines |> list.split_while(fn(x) { !string.is_empty(x) }) {
    #(rules, [_, ..updates]) -> {
      use rules <- result.try(rules |> list.map(parse_rule) |> result.all())
      use updates <- result.try(
        updates |> list.map(parse_update) |> result.all(),
      )
      let successor_dict = rules |> from_rules()
      Ok(#(successor_dict, updates))
    }
    _ -> Error(Nil)
  }
}

/// ## Examples
/// ```gleam
/// from_rules([#(5,69), #(5,420), #(5,1000), #(8,32)])
/// // -> dict.from_list([
/// //      #(5, [69, 420, 1000]),
/// //      #(8, [32])
/// //    ])
/// ```
pub fn from_rules(rules: List(Rule)) -> SuccessorDict {
  list.fold(rules, dict.new(), add_rule)
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
pub fn parse_rule(input: String) -> Result(Rule, Nil) {
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
pub fn add_rule(successor_dict: SuccessorDict, rule: Rule) -> SuccessorDict {
  let #(a, b) = rule
  use entry <- dict.upsert(successor_dict, a)
  case entry {
    Some(successors) -> successors |> set.insert(b)
    None -> set.from_list([b])
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
pub fn middle_page_number(update: Update) -> Int {
  update
  |> list.drop(list.length(update) / 2)
  |> list.first
  |> result.unwrap(0)
}

pub fn sort(update: Update, successor_dict: SuccessorDict) -> Update {
  use a, b <- list.sort(update)
  todo
}
