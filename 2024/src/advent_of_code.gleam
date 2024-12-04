import day_01
import day_02
import day_03
import day_04
import file_streams/file_stream
import gleam/erlang
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gleam/yielder

pub fn main() {
  let day = prompt_day()
  let assert Ok(stream) =
    file_stream.open_read("../inputs/2024/day_" <> two_digits(day) <> ".txt")
  let part = prompt_part()
  let solve_fn = case day, part {
    1, 1 -> day_01.part_01
    1, 2 -> day_01.part_02
    2, 1 -> day_02.part_01
    2, 2 -> day_02.part_02
    3, 1 -> day_03.part_01
    3, 2 -> day_03.part_02
    4, 1 -> day_04.part_01
    4, 2 -> day_04.part_02
    _, _ -> panic
  }
  let lines = stream |> lines
  lines |> solve_fn |> int.to_string |> io.println
}

fn lines(stream: file_stream.FileStream) -> yielder.Yielder(String) {
  case stream |> file_stream.read_line {
    Ok(line) -> {
      use <- yielder.yield(line)
      lines(stream)
    }
    Error(_) -> yielder.empty()
  }
}

fn prompt_day() -> Int {
  let assert Ok(day) = prompt_number("Enter a day (1-24): ")
  day
}

fn prompt_part() -> Int {
  prompt_number("Enter a part (1): ") |> result.unwrap(1)
}

fn prompt_number(prompt: String) -> Result(Int, Nil) {
  use line <- result.try(erlang.get_line(prompt) |> result.replace_error(Nil))
  use value <- result.try(line |> string.trim |> int.parse)
  Ok(value)
}

/// Converts an integer between 0 and 99 to a string with two digits.
/// Panics if value is < 0 or > 99.
///
/// ## Examples
/// ```gleam
/// two_digits(0)
/// // -> "00"
/// two_digits(1)
/// // -> "01"
/// two_digits(9)
/// // -> "09"
/// two_digits(10)
/// // -> "10"
/// two_digits(99)
/// // -> "99"
/// ```
fn two_digits(value: Int) -> String {
  case value {
    _ if value < 0 -> panic
    _ if value < 10 -> "0" <> int.to_string(value)
    _ if value < 100 -> int.to_string(value)
    _ -> panic
  }
}
