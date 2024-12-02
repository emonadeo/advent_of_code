import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let #(lefts, rights) = lines |> yielder.map(parse_tuple) |> tuples_to_lists
  let lefts = lefts |> list.sort(int.compare) |> yielder.from_list
  let rights = rights |> list.sort(int.compare) |> yielder.from_list
  yielder.zip(lefts, rights)
  |> yielder.map(fn(tuple) { int.absolute_value(tuple.0 - tuple.1) })
  |> yielder.fold(0, fn(acc, element) { acc + element })
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let #(lefts, rights) = lines |> yielder.map(parse_tuple) |> tuples_to_lists
  let counts = rights |> yielder.from_list |> counts
  use sum, value <- yielder.fold(lefts |> yielder.from_list, 0)
  let count = counts |> get_count(value)
  sum + value * count
}

fn parse_tuple(input: String) -> #(Int, Int) {
  let assert Ok(#(left, right)) = input |> string.split_once(" ")
  let assert Ok(left) = left |> string.trim |> int.parse
  let assert Ok(right) = right |> string.trim |> int.parse
  #(left, right)
}

fn tuples_to_lists(
  input: yielder.Yielder(#(Int, Int)),
) -> #(List(Int), List(Int)) {
  use acc, element <- yielder.fold(input, #([], []))
  #(list.append(acc.0, [element.0]), list.append(acc.1, [element.1]))
}

/// Create a dictionary from a yielder, that maps each unique element
/// to the times it appears in the yielder.
///
/// ## Examples
/// ```gleam
/// let a = yielder.from_list([4, 5, 5, 9, 5, 9])
/// counts(a)
/// // -> dict.from_list([#(4, 1), #(5, 3), #(9, 2)])
/// ```
fn counts(values: yielder.Yielder(Int)) -> dict.Dict(Int, Int) {
  use acc, value <- yielder.fold(values, dict.new())
  use count <- dict.upsert(acc, value)
  case count {
    option.Some(count) -> count + 1
    option.None -> 1
  }
}

fn get_count(counts: dict.Dict(Int, Int), value: Int) -> Int {
  case dict.get(counts, value) {
    Ok(count) -> count
    Error(_) -> 0
  }
}
