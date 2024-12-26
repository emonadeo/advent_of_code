import common
import directed_position.{type DirectedPosition}
import direction.{East}
import gleam/bool
import gleam/dict
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder}
import position.{type Position}

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
  use position <- list.filter(position |> position.neighbors_4())
  maze |> set.contains(position)
}

/// Errors, if `target` is not reachable.
pub fn lowest_score(
  maze: Maze,
  start: DirectedPosition,
  target: Position,
) -> Result(Int, Nil) {
  lowest_score_loop(maze, target, set.from_list([#(start, 0)]), set.new())
}

fn lowest_score_loop(
  maze: Maze,
  target: Position,
  queue: Set(#(DirectedPosition, Int)),
  visited: Set(Position),
) -> Result(Int, Nil) {
  let lowest = queue |> set.to_list() |> common.min(pair.second)
  case lowest {
    Error(Nil) -> Error(Nil)
    Ok(current) -> {
      let #(directed_position, score) = current
      let #(position, _) = directed_position
      let queue = queue |> set.delete(current)
      case
        maze |> set.contains(position) |> bool.negate()
        || visited |> set.contains(position)
      {
        True -> {
          let visited = visited |> set.insert(position)
          lowest_score_loop(maze, target, queue, visited)
        }
        False if position == target -> Ok(score)
        False -> {
          let visited = visited |> set.insert(position)
          let queue =
            queue
            |> set.insert(#(
              directed_position |> directed_position.advance(),
              score + 1,
            ))
            |> set.insert(#(
              directed_position
                |> directed_position.map_direction(direction.rotate_cw)
                |> directed_position.advance(),
              score + 1001,
            ))
            |> set.insert(#(
              directed_position
                |> directed_position.map_direction(direction.rotate_ccw)
                |> directed_position.advance(),
              score + 1001,
            ))
          lowest_score_loop(maze, target, queue, visited)
        }
      }
    }
  }
}
