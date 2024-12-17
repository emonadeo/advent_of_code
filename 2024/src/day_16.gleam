import common.{type Position, East}
import directed_position.{type DirectedPosition}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder}

pub fn part_01(lines: Yielder(String)) -> Int {
  let assert Ok(#(maze, start, target)) =
    lines
    |> yielder.map(string.to_graphemes)
    |> yielder.to_list()
    |> parse()

  let assert Ok(score) = maze |> lowest_score(start, target)
  score
}

pub fn part_02(lines: Yielder(String)) -> Int {
  todo
}

pub type Maze =
  Set(Position)

/// Parse a maze, start position and target position from a grapheme matrix.
/// A maze is a set of positions that can be walked on.
///
/// `S` marks the start position.
/// `E` marks the target position.
/// `.` is interpreted as walkable space.
/// Everything else is treated as a wall.
///
/// Returns `#(maze, start, target)`.
/// Errors if maze contains zero or multiple start and target positions.
pub fn parse(
  graphemes: List(List(String)),
) -> Result(#(Maze, DirectedPosition, Position), Nil) {
  let grapheme_map = graphemes |> common.matrix_to_map()

  use start <- result.try(case
    grapheme_map
    |> dict.filter(fn(_, grapheme) { grapheme == "S" })
    |> dict.keys()
  {
    [start] -> Ok(start)
    _ -> Error(Nil)
  })

  use target <- result.try(case
    grapheme_map
    |> dict.filter(fn(_, grapheme) { grapheme == "E" })
    |> dict.keys()
  {
    [target] -> Ok(target)
    _ -> Error(Nil)
  })

  let maze =
    grapheme_map
    |> dict.filter(fn(_, grapheme) { grapheme == "." })
    |> dict.keys()
    |> set.from_list()
    |> set.insert(start)
    |> set.insert(target)

  Ok(#(maze, #(start, East), target))
}

/// Get all adjacent walkable positions to a given `position`.
/// Panics, if `position` is not walkable space.
pub fn adjacent(maze: Maze, position: Position) -> List(Position) {
  let assert True = maze |> set.contains(position)
  use position <- list.filter(position |> common.neighbors_4())
  maze |> set.contains(position)
}

/// Errors, if `target` is not reachable.
pub fn lowest_score(
  maze: Maze,
  start: DirectedPosition,
  target: Position,
) -> Result(Int, Nil) {
  lowest_score_loop(maze, start, target, set.new())
}

fn lowest_score_loop(
  maze: Maze,
  current: DirectedPosition,
  target: Position,
  visited: Set(Position),
) -> Result(Int, Nil) {
  let current_position = current |> directed_position.position()
  case
    maze |> set.contains(current_position) |> bool.negate()
    || visited |> set.contains(current_position)
  {
    True -> Error(Nil)
    False ->
      case current_position == target {
        True -> Ok(0)
        False ->
          [
            // advance straight
            lowest_score_loop(
              maze,
              current |> directed_position.advance(),
              target,
              visited |> set.insert(current_position),
            )
              |> result.map(fn(score) { score + 1 }),
            // rotate clockwise and advance
            lowest_score_loop(
              maze,
              current
                |> directed_position.map_direction(common.rotate_cw)
                |> directed_position.advance(),
              target,
              visited |> set.insert(current_position),
            )
              |> result.map(fn(score) { score + 1001 }),
            // rotate counterclockwise and advance
            lowest_score_loop(
              maze,
              current
                |> directed_position.map_direction(common.rotate_ccw)
                |> directed_position.advance(),
              target,
              visited |> set.insert(current_position),
            )
              |> result.map(fn(score) { score + 1001 }),
          ]
          |> result.values()
          |> list.reduce(int.min)
      }
  }
}
