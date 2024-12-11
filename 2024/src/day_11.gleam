import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let assert [line] = lines |> yielder.to_list()
  let assert Ok(stones) =
    line |> string.split(" ") |> list.map(int.parse) |> result.all()

  list.range(1, 25)
  |> list.fold(stones, fn(stones, _) { blink(stones) })
  |> list.length()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub fn blink(stones: List(Int)) -> List(Int) {
  use stone <- list.flat_map(stones)
  case stone {
    0 -> [1]
    _ -> {
      let assert Ok(digits) = int.digits(stone, 10)
      let digit_count = list.length(digits)
      case int.is_even(digit_count) {
        True -> {
          let #(head, tail) = digits |> list.split(digit_count / 2)
          let assert Ok(head) = int.undigits(head, 10)
          let assert Ok(tail) = int.undigits(tail, 10)
          [head, tail]
        }
        False -> [stone * 2024]
      }
    }
  }
}
