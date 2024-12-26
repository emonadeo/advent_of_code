import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/yielder
import position.{type Position}

/// Returns `#(width, height)` of a given list of rows.
/// Assumes that every row has the same length.
pub fn dimensions(rows: List(List(a))) -> #(Int, Int) {
  case rows {
    [] -> #(0, 0)
    [first_row, ..] -> #(list.length(first_row), list.length(rows))
  }
}

/// ## Examples
///
/// ```gleam
/// flatten_set(set.from_list([
///   set.from_list(["a", "b"]),
///   set.from_list(["c", "d", "a"])
/// ]))
/// // -> set.from_list(["a", "b", "c", "d"])
/// ```
pub fn flatten_set(set: Set(Set(a))) -> Set(a) {
  use acc, e <- set.fold(set, set.new())
  acc |> set.union(e)
}

/// ## Examples
///
/// ```gleam
/// add_pair(#(1, 3), #(4, 9))
/// // -> #(5, 12)
/// ```
pub fn add_pair(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  let #(ax, ay) = a
  let #(bx, by) = b
  #(ax + bx, ay + by)
}

/// ## Examples
///
/// ```gleam
/// add_pair(#(1, 3), #(4, 9))
/// // -> #(-2, -5)
/// ```
pub fn sub_pair(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  let #(ax, ay) = a
  let #(bx, by) = b
  #(ax - bx, ay - by)
}

/// ## Examples
///
/// ```gleam
/// negate_pair(#(1, 3))
/// // -> #(-1, -3)
/// ```
pub fn negate_pair(a: #(Int, Int)) -> #(Int, Int) {
  let #(ax, ay) = a
  #(-ax, -ay)
}

/// Similar to `deque.pop_back` but skips `None` until it finds a `Some(a)`
///
/// ## Examples
///
/// ```gleam
/// deque.from_list([Some(1), Some(2)]) |> pop_back_some()
/// // -> Ok(#(2, deque.from_list([Some(1)])))
/// deque.from_list([Some(1), Some(2), None]) |> pop_back_some()
/// // -> Ok(#(2, deque.from_list([Some(1)])))
/// deque.from_list([Some(1), Some(2), None, None]) |> pop_back_some()
/// // -> Ok(#(2, deque.from_list([Some(1)])))
/// deque.from_list([]) |> pop_back_some()
/// // -> Error(Nil)
/// deque.from_list([None]) |> pop_back_some()
/// // -> Error(Nil)
/// deque.from_list([None, None]) |> pop_back_some()
/// // -> Error(Nil)
/// ```
pub fn pop_back_some(
  to_compact: Deque(Option(a)),
) -> Result(#(a, Deque(Option(a))), Nil) {
  case to_compact |> deque.pop_back() {
    Ok(#(Some(a), rest)) -> Ok(#(a, rest))
    Ok(#(None, rest)) -> pop_back_some(rest)
    Error(Nil) -> Error(Nil)
  }
}

/// Convert a Matrix (`List(List(a))`) into a Map (`Dict(#(row, column), a)`).
///
/// ## Examples
///
/// ```gleam
/// matrix_to_map([[6, 7], [8, 9]])
/// // -> dict.from_list([
/// //   #(#(0, 0), 6),
/// //   #(#(0, 1), 7),
/// //   #(#(1, 0), 8),
/// //   #(#(1, 1), 9),
/// // ])
///```
pub fn matrix_to_map(rows: List(List(a))) -> Dict(Position, a) {
  use dict, row, row_index <- list.index_fold(rows, dict.new())
  use dict, a, column_index <- list.index_fold(row, dict)
  dict |> dict.insert(#(row_index, column_index), a)
}

/// Extracts the `Ok` value from a result.
/// Panics if the result is an `Error`.
pub fn assert_unwrap(result: Result(a, b)) -> a {
  let assert Ok(value) = result
  value
}

/// ## Examples
///
/// ```gleam
/// group_and_count(["a", "a", "b", "d", "d", "d"])
/// // -> dict.from_list([
/// //   #("a", 2)
/// //   #("b", 1)
/// //   #("c", 3)
/// // ])
/// ```
pub fn group_and_count(list: List(a)) -> Dict(a, Int) {
  list
  |> list.group(fn(a) { a })
  |> dict.map_values(fn(_, a) { list.length(a) })
}

/// ## Examples
///
/// ```gleam
/// pair_to_string(#(69, 429), int.to_string)
/// // -> "#(69, 420)"
/// ```
pub fn pair_to_string(pair: #(a, a), to_string: fn(a) -> String) -> String {
  let #(a, b) = pair
  "#(" <> to_string(a) <> ", " <> to_string(b) <> ")"
}

/// ## Examples
///
/// ```gleam
/// int_pair_to_string(#(69, 429))
/// // -> "#(69, 420)"
/// ```
pub fn int_pair_to_string(pair: #(Int, Int)) -> String {
  pair_to_string(pair, int.to_string)
}

/// Convert a `Step` to a `Result` by mapping
/// `Next(e, a)` to `Ok(#(e, a))` and `Done` to `Error(Nil)`
pub fn step_to_result(step: yielder.Step(e, a)) -> Result(#(e, a), Nil) {
  case step {
    yielder.Next(e, a) -> Ok(#(e, a))
    yielder.Done -> Error(Nil)
  }
}

pub fn min(elements: List(a), value: fn(a) -> Int) -> Result(a, Nil) {
  use lowest, next <- list.reduce(elements)
  let score = value(next)
  let lowest_score = value(lowest)
  case score < lowest_score {
    False -> lowest
    True -> next
  }
}
