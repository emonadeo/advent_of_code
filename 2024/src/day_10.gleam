import common.{type Position}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let height_map =
    lines
    |> yielder.map(string.to_graphemes)
    |> yielder.to_list()
    |> parse_int_matrix()
    |> common.assert_unwrap()
    |> common.matrix_to_map()

  height_map
  |> score_map()
  |> zero_height(height_map)
  |> dict.values()
  |> int.sum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let height_map =
    lines
    |> yielder.map(string.to_graphemes)
    |> yielder.to_list()
    |> parse_int_matrix()
    |> common.assert_unwrap()
    |> common.matrix_to_map()

  height_map
  |> zero_height(height_map)
  |> dict.keys()
  |> list.map(fn(position) { rating(position, height_map) })
  |> int.sum()
}

fn parse_int_matrix(
  graphemes: List(List(String)),
) -> Result(List(List(Int)), Nil) {
  result.all({
    use row <- list.map(graphemes)
    result.all({
      use grapheme <- list.map(row)
      grapheme |> int.parse()
    })
  })
}

/// Given a height map, map every position to the amount
/// of reachable `9`-height positions from that position.
/// The position does **not** have to be `0`-height.
///
/// ## Examples
///
/// ```gleam
/// score_map(dict.from_list([
///   #(#(0, 0), 7), #(#(0, 1), 8), #(#(0, 2), 9),
///   #(#(1, 0), 2), #(#(1, 1), 9), #(#(1, 2), 8),
/// ]))
/// // -> dict.from_list([
/// //      #(#(0, 0), 2), #(#(0, 1), 2), #(#(0, 2), 1),  
/// //                     #(#(1, 1), 1), #(#(1, 2), 2),  
/// //    ])
/// ```
///
/// Visually speaking, the following example is not valid code,
/// but should be helpful to understand `score_map()`.
///
/// ```gleam
/// score_map([[7, 8, 9],
///            [2, 9, 8]])
/// // -> [[2, 2, 1],
/// //     [0, 1, 2]]
/// ```
pub fn score_map(height_map: Dict(Position, Int)) -> Dict(Position, Int) {
  height_map
  |> dict.filter(fn(_, height) { height == 9 })
  |> dict.to_list()
  |> list.map(fn(trail_end) {
    score_map_loop(height_map, set.new(), [trail_end])
  })
  |> list.map(set.to_list)
  |> list.flatten()
  |> common.group_and_count()
}

fn score_map_loop(
  height_map: Dict(Position, Int),
  visited: Set(Position),
  to_visit: List(#(Position, Int)),
) -> Set(Position) {
  case to_visit {
    [] -> visited
    [#(position, expected_height), ..to_visit] -> {
      // continue if position has already been visited
      case visited |> set.contains(position) {
        True -> score_map_loop(height_map, visited, to_visit)
        False -> {
          // continue if height at position does not match the expected height
          case height_map |> dict.get(position) == Ok(expected_height) {
            False -> score_map_loop(height_map, visited, to_visit)
            True -> {
              let visited = visited |> set.insert(position)
              let expected_height = expected_height - 1
              let to_visit =
                position
                |> common.neighbors_4()
                |> list.map(fn(position) { #(position, expected_height) })
                |> list.append(to_visit)
              score_map_loop(height_map, visited, to_visit)
            }
          }
        }
      }
    }
  }
}

pub fn rating(position: Position, height_map: Dict(Position, Int)) -> Int {
  rating_loop(position, height_map, 0)
}

fn rating_loop(
  position: Position,
  height_map: Dict(Position, Int),
  expected_height: Int,
) -> Int {
  case dict.get(height_map, position) == Ok(expected_height), expected_height {
    False, _ -> 0
    True, 9 -> 1
    True, _ -> {
      position
      |> common.neighbors_4()
      |> list.map(fn(position) {
        rating_loop(position, height_map, expected_height + 1)
      })
      |> int.sum()
    }
  }
}

/// Filter entries from `map` to only include positions that are `0`-height according to `height_map`.
pub fn zero_height(
  map: Dict(#(Int, Int), a),
  height_map: Dict(#(Int, Int), Int),
) -> Dict(#(Int, Int), a) {
  let zero_height_map = dict.filter(height_map, fn(_, height) { height == 0 })
  let zero_height_positions = zero_height_map |> dict.keys()
  dict.filter(map, fn(position, _) {
    list.contains(zero_height_positions, position)
  })
}
