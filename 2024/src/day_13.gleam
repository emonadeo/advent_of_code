import common.{type Position}
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder, Done, Next}

pub fn part_01(lines: Yielder(String)) -> Int {
  parse(lines)
  |> list.map(win_presses)
  |> result.values()
  |> list.map(token_cost)
  |> int.sum()
}

pub fn part_02(lines: Yielder(String)) -> Int {
  todo
}

pub type Machine {
  Machine(button_a: #(Int, Int), button_b: #(Int, Int), prize: #(Int, Int))
}

pub fn parse(lines: Yielder(String)) -> List(Machine) {
  let #(machine, lines) = parse_machine(lines)
  case lines |> yielder.step() {
    Done -> [machine]
    Next(_, lines) -> [machine, ..parse(lines)]
  }
}

pub fn parse_machine(lines: Yielder(String)) -> #(Machine, Yielder(String)) {
  let assert Next(button_a, lines) = lines |> yielder.step()
  let assert Next(button_b, lines) = lines |> yielder.step()
  let assert Next(prizes, lines) = lines |> yielder.step()

  let #(a_x, a_y): #(String, String) =
    button_a
    |> string.drop_start(10)
    |> string.split_once(", ")
    |> common.assert_unwrap()
  let a_x = a_x |> string.drop_start(2) |> int.parse() |> common.assert_unwrap()
  let a_y = a_y |> string.drop_start(2) |> int.parse() |> common.assert_unwrap()
  let button_a: #(Int, Int) = #(a_x, a_y)

  let #(b_x, b_y): #(String, String) =
    button_b
    |> string.drop_start(10)
    |> string.split_once(", ")
    |> common.assert_unwrap()
  let b_x = b_x |> string.drop_start(2) |> int.parse() |> common.assert_unwrap()
  let b_y = b_y |> string.drop_start(2) |> int.parse() |> common.assert_unwrap()
  let button_b: #(Int, Int) = #(b_x, b_y)

  let #(prize_x, prize_y): #(String, String) =
    prizes
    |> string.drop_start(7)
    |> string.split_once(", ")
    |> common.assert_unwrap()
  let prize_x =
    prize_x |> string.drop_start(2) |> int.parse() |> common.assert_unwrap()
  let prize_y =
    prize_y |> string.drop_start(2) |> int.parse() |> common.assert_unwrap()
  let prizes: #(Int, Int) = #(prize_x, prize_y)

  let machine = Machine(button_a, button_b, prizes)
  #(machine, lines)
}

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
