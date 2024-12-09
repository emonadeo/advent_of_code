import gleam/deque.{type Deque}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}

/// Returns `#(width, height)` of a given list of rows
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

/// Transform a matrix of elements into a list of `#(row, column, element)`
///
/// ## Examples
/// ```gleam
/// [["a", "b"], ["c"]] |> annotate_positions()
/// // -> [#(#(0, 0), "a"), #(#(0, 1), "b"), #(#(1, 0), "c")]
/// ```
pub fn positions(rows: List(List(a))) -> List(#(#(Int, Int), a)) {
  {
    use row, row_index <- list.index_map(rows)
    use element, column_index <- list.index_map(row)
    #(#(row_index, column_index), element)
  }
  |> list.flatten()
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
