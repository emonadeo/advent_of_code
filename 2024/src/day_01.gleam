import gleam/int
import gleam/list
import gleam/string
import gleam/yielder.{type Yielder}

pub fn part_01(lines: Yielder(String)) -> Int {
  let #(lefts, rights) = lines |> yielder.map(parse_tuple) |> tuples_to_lists
  let lefts = lefts |> list.sort(int.compare) |> yielder.from_list
  let rights = rights |> list.sort(int.compare) |> yielder.from_list
  yielder.zip(lefts, rights)
  |> yielder.map(fn(tuple) { int.absolute_value(tuple.0 - tuple.1) })
  |> yielder.fold(0, fn(acc, element) { acc + element })
}

pub fn parse_tuple(input: String) -> #(Int, Int) {
  let assert Ok(#(left, right)) = input |> string.split_once(" ")
  let assert Ok(left) = left |> string.trim |> int.parse
  let assert Ok(right) = right |> string.trim |> int.parse
  #(left, right)
}

pub fn tuples_to_lists(input: Yielder(#(Int, Int))) -> #(List(Int), List(Int)) {
  use acc, element <- yielder.fold(input, #([], []))
  #(list.append(acc.0, [element.0]), list.append(acc.1, [element.1]))
}
