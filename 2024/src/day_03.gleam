import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  use sum, line <- yielder.fold(lines, 0)
  sum + evaluate(line |> string.trim())
}

/// Evaluate all `mul(a,b)` expressions in a given string and sum them together.
///
/// ## Examples
/// ```gleam
/// evaluate("mul(2,3)")
/// // -> 6
/// evaluate("mul(2,3)mul(2,3)")
/// // -> 12
/// evaluate("helloworld")
/// // -> 0 
/// evaluate("mul(2,3)helloworldmul(2,3)")
/// // -> 12
/// ```
pub fn evaluate(input: String) -> Int {
  case extract_mul(input) {
    Error(Nil) ->
      case input |> string.pop_grapheme() {
        Error(Nil) -> 0
        Ok(#(_, rest)) -> evaluate(rest)
      }
    Ok(#(value, rest)) -> {
      value + evaluate(rest)
    }
  }
}

/// Parse a `mul(a,b)` expression,
/// returning both the evaluated result and string remainder.
/// The expression must be at the start of the string.
///
/// ## Examples
/// ```gleam
/// extract_int("mul(2,3)hello")
/// // -> Ok(#(6, "hello"))
/// extract_int("hellomul(2,3)")
/// // -> Error(Nil)
/// ```
pub fn extract_mul(value: String) -> Result(#(Int, String), Nil) {
  case value {
    "mul(" <> rest -> {
      use #(a, rest) <- result.try(extract_int(rest))
      case rest {
        "," <> rest -> {
          use #(b, rest) <- result.try(extract_int(rest))
          case rest {
            ")" <> rest -> Ok(#(a * b, rest))
            _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

/// Parse a given string as a single integer as far as possible,
/// returning both the integer and string remainder.
/// The integer must be at the start of the string.
///
/// ## Examples
/// ```gleam
/// extract_int("69420hello")
/// // -> Ok(#(69420, "hello"))
/// extract_int("69hello420")
/// // -> Ok(#(69, "hello420"))
/// extract_int("hello69420")
/// // -> Error(Nil)
/// ```
pub fn extract_int(value: String) -> Result(#(Int, String), Nil) {
  use #(digits, rest) <- result.try(value |> extract_digits)
  use number <- result.try(digits |> int.undigits(10))
  Ok(#(number, rest))
}

/// Same as `extract_int`, except digits are
/// not automatically merged into an integer.
///
/// ## Examples
/// ```gleam
/// extract_digits("69420hello")
/// // -> Ok(#([6, 9, 4, 2, 0], "hello"))
/// extract_digits("69hello420")
/// // -> Ok(#([6, 9], "hello420"))
/// extract_digits("hello69420")
/// // -> Error(Nil)
/// ```
pub fn extract_digits(value: String) -> Result(#(List(Int), String), Nil) {
  use #(digit, rest) <- result.try(value |> string.pop_grapheme())
  case digit |> int.parse() {
    Ok(digit) -> {
      case extract_digits(rest) {
        Error(Nil) -> Ok(#([digit], rest))
        Ok(#(next_digits, next_rest)) ->
          Ok(#(list.append([digit], next_digits), next_rest))
      }
    }
    Error(Nil) -> Error(Nil)
  }
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}
