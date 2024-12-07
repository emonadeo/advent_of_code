import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let assert Ok(equations) =
    lines |> yielder.map(parse) |> yielder.to_list() |> result.all()

  equations
  |> list.filter(is_possible)
  |> list.map(fn(equation) {
    let #(test_value, _) = equation
    test_value
  })
  |> int.sum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub fn parse(input: String) -> Result(#(Int, List(Int)), Nil) {
  use #(test_value, numbers) <- result.try(input |> string.split_once(":"))
  use test_value <- result.try(test_value |> int.parse())
  use numbers <- result.try(
    numbers
    |> string.trim()
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all(),
  )
  Ok(#(test_value, numbers))
}

pub fn is_possible(equation: #(Int, List(Int))) -> Bool {
  case equation {
    #(_, []) -> panic
    #(y, [a]) if y == a -> True
    #(_, [_]) -> False
    #(y, [a, b, ..numbers]) ->
      is_possible(#(y, [a * b, ..numbers]))
      || is_possible(#(y, [a + b, ..numbers]))
  }
}
