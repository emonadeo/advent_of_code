import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let assert [line] = lines |> yielder.to_list()
  let assert Ok(stones) =
    line |> string.split(" ") |> list.map(int.parse) |> result.all()
  blink_and_count_all(stones, 25)
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let assert [line] = lines |> yielder.to_list()
  let assert Ok(stones) =
    line |> string.split(" ") |> list.map(int.parse) |> result.all()
  blink_and_count_all(stones, 75)
}

/// “Blink” a single stone.
///
/// ## Examples
///
/// 1. A zero becomes a one
///    ```gleam
///    blink(0)
///    // -> [1]
///    ```
/// 2. Inputs with an even digit count are split down the middle
///    ```gleam
///    blink(17)
///    // -> [1, 7]
///    blink(6666)
///    // -> [66, 66]
///    blink(28676032)
///    // -> [2867, 6032]
///    ```
/// 3. Inputs with an odd digit count are multiplied by 2024
///    ```gleam
///    blink(1)
///    // -> [2024]
///    blink(2)
///    // -> [4048]
///    blink(4)
///    // -> [8096]
///    blink(125)
///    // -> [253000]
/// ```
pub fn blink(stone: Int) -> List(Int) {
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

/// Count the amount of stones after “blinking” multiple `stones` multiple `times`.
pub fn blink_and_count_all(stones: List(Int), times times: Int) -> Int {
  let #(count, _) =
    stones
    |> list.fold(#(0, dict.new()), fn(accumulator, stone) {
      let #(total_count, memory) = accumulator
      let #(count, memory) = blink_and_count_with_memo(stone, times, memory)
      #(total_count + count, memory)
    })
  count
}

/// Count the amount of stones after “blinking” a single `stone` multiple `times`.
pub fn blink_and_count(stone: Int, times times: Int) -> Int {
  let #(count, _) = blink_and_count_with_memo(stone, times, dict.new())
  count
}

/// `Dict(#(stone, times), count)`
pub type Memory =
  Dict(#(Int, Int), Int)

/// Same as `blink_and_count()` but with memoization.
///
/// `fn(stone, times, memory) -> #(count, memory)`
///
/// Returns the stone `count` after “blinking” a `stone` multiple `times`.
/// Also returns the updated caching table `memory`.
///
/// Panics if `times` is negative.
pub fn blink_and_count_with_memo(
  stone: Int,
  times times: Int,
  memory memory: Memory,
) -> #(Int, Memory) {
  case memory |> dict.get(#(stone, times)) {
    Ok(count) -> #(count, memory)
    Error(Nil) -> {
      let stones = blink(stone)
      case times {
        0 -> #(1, memory)
        _ if times > 0 -> {
          let #(count, memory) =
            list.fold(stones, #(0, memory), fn(accumulator, stone) {
              let #(total_count, memory) = accumulator
              let #(count, memory) =
                blink_and_count_with_memo(stone, times - 1, memory)
              #(total_count + count, memory)
            })
          let memory = memory |> dict.insert(#(stone, times), count)
          #(count, memory)
        }
        // panic if `times` is negative
        _ -> panic
      }
    }
  }
}
