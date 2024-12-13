import common
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder, Done, Next}

pub fn part_01(lines: Yielder(String)) -> Int {
  parse_many(lines)
  |> common.assert_unwrap()
  |> list.map(win_presses)
  |> result.values()
  |> list.map(token_cost)
  |> int.sum()
}

pub fn part_02(lines: Yielder(String)) -> Int {
  parse_many(lines)
  |> common.assert_unwrap()
  |> list.map(fn(machine) {
    let Machine(button_a, button_b, #(prize_x, prize_y)) = machine
    Machine(button_a, button_b, #(
      prize_x + 10_000_000_000_000,
      prize_y + 10_000_000_000_000,
    ))
  })
  |> list.map(win_presses)
  |> result.values()
  |> list.map(token_cost)
  |> int.sum()
}

pub type Machine {
  Machine(button_a: #(Int, Int), button_b: #(Int, Int), prize: #(Int, Int))
}

pub fn parse_many(lines: Yielder(String)) -> Result(List(Machine), Nil) {
  use #(machine, lines) <- result.try(parse(lines))
  case lines |> yielder.step() {
    Done -> Ok([machine])
    Next(_, lines) -> {
      use rest <- result.try(parse_many(lines))
      Ok([machine, ..rest])
    }
  }
}

/// ## Examples
///
/// ```gleam
/// ["Button A: X+94, Y+34",
///  "Button B: X+22, Y+67",
///  "Prize: X=8400, Y=5400",
///  "...",
///  "Lorem Ipsum"]
/// |> yielder.from_list()
/// |> parse_machine()
/// // -> #(
/// //   Machine(#(94, 34), #(22, 67), #(8400, 5400)),
/// //   yielder.from_list(["...", "Lorem Ipsum"])
/// // )
/// ```
pub fn parse(lines: Yielder(String)) -> Result(#(Machine, Yielder(String)), Nil) {
  use #(button_a, lines) <- result.try(
    lines
    |> yielder.step()
    |> common.step_to_result(),
  )
  use button_a <- result.try(button_a |> parse_tuple())
  use #(button_b, lines) <- result.try(
    lines
    |> yielder.step()
    |> common.step_to_result(),
  )
  use button_b <- result.try(button_b |> parse_tuple())
  use #(prize, lines) <- result.try(
    lines
    |> yielder.step()
    |> common.step_to_result(),
  )
  use prize <- result.try(prize |> parse_tuple())
  let machine = Machine(button_a, button_b, prize)
  Ok(#(machine, lines))
}

/// ## Examples
///
/// ```gleam
/// parse_tuple("Button A: X+94, Y+34")
/// // -> Ok(#(94, 34))
/// parse_tuple("Button B: X+22, Y+67")
/// // -> Ok(#(22, 67))
/// parse_tuple("Prize: X=8400, Y=5400")
/// // -> Ok(#(8400, 5400))
/// ```
fn parse_tuple(input: String) -> Result(#(Int, Int), Nil) {
  use #(_, xy) <- result.try(input |> string.split_once(": "))
  use #(x, y) <- result.try(xy |> string.split_once(", "))
  use x <- result.try(x |> string.trim() |> string.drop_start(2) |> int.parse())
  use y <- result.try(y |> string.trim() |> string.drop_start(2) |> int.parse())
  Ok(#(x, y))
}

/// Calculate how many button presses are needed to win the prize of a machine.
/// Errors if it is impossible to win the prize.
/// Panics if it divides by zero.
///
/// ## Examples
///
/// ```gleam
/// win_presses(Machine(#(94, 34), #(22, 67), #(8400, 5400)))
/// // -> Ok(#(80, 40))
/// win_presses(Machine(#(26, 66), #(67, 21), #(12748, 12176)))
/// // -> Error(Nil)
/// ```
pub fn win_presses(machine: Machine) -> Result(#(Int, Int), Nil) {
  let Machine(#(a_x, a_y), #(b_x, b_y), #(target_x, target_y)) = machine
  let assert Ok(b_presses_precise) =
    int.to_float(target_x * a_y - target_y * a_x)
    |> float.divide(int.to_float(b_x * a_y - b_y * a_x))
  let b_presses = float.truncate(b_presses_precise)
  case int.to_float(b_presses) == b_presses_precise {
    False -> Error(Nil)
    True -> {
      let assert Ok(a_presses) = target_x - b_presses * b_x |> int.divide(a_x)
      Ok(#(a_presses, b_presses))
    }
  }
}

pub fn token_cost(presses: #(Int, Int)) -> Int {
  let #(a_presses, b_presses) = presses
  3 * a_presses + b_presses
}
