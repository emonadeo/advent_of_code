import common.{type Direction, East, North, South, West}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let #(map, guard) =
    lines |> yielder.to_list() |> list.map(string.to_graphemes) |> parse()
  let assert Walk(visited_positions, False) = walk(map, guard)
  visited_positions |> set.size()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let #(map, guard) =
    lines |> yielder.to_list() |> list.map(string.to_graphemes) |> parse()
  looping_obstacles(map, guard) |> set.size()
}

pub fn parse(graphemes: List(List(String))) -> #(Map, Guard) {
  let #(width, height) = common.dimensions(graphemes)
  case parse_loop(graphemes, #(0, 0), set.new(), None) {
    #(obstacles, Some(guard)) -> #(Map(width, height, obstacles), guard)
    #(_, None) -> panic
  }
}

fn parse_loop(
  graphemes: List(List(String)),
  position: #(Int, Int),
  obstacles: Obstacles,
  guard: Option(Guard),
) -> #(Obstacles, Option(Guard)) {
  let #(row_index, column_index) = position
  case graphemes {
    [] -> #(obstacles, guard)
    [[], ..rows] -> parse_loop(rows, #(row_index + 1, 0), obstacles, guard)
    [[grapheme, ..row], ..rows] -> {
      let #(obstacles, guard) = case grapheme |> parse_symbol() {
        Ok(Nothing) -> #(obstacles, guard)
        Ok(Obstacle) -> #(obstacles |> set.insert(position), guard)
        Ok(Direction(direction)) -> #(
          obstacles,
          Some(Guard(position, direction)),
        )
        Error(Nil) -> panic
      }
      parse_loop(
        [row, ..rows],
        #(row_index, column_index + 1),
        obstacles,
        guard,
      )
    }
  }
}

pub type Map {
  Map(width: Int, height: Int, obstacles: Obstacles)
}

pub type Obstacles =
  Set(#(Int, Int))

pub type Walk {
  Walk(visited_positions: Set(#(Int, Int)), has_loop: Bool)
}

pub fn walk(map: Map, guard: Guard) -> Walk {
  let #(visited_positions, _) = walk_loop(set.new(), map, guard)
  visited_positions
}

/// Get the position of a guard without the facing direction
fn get_position(guard: Guard) -> #(Int, Int) {
  let Guard(position, _) = guard
  position
}

fn walk_loop(
  guard_history: Set(Guard),
  map: Map,
  guard: Guard,
) -> #(Walk, Guard) {
  let Map(width, height, obstacles) = map
  let Guard(position, facing) = guard
  let #(row, column) = position
  case guard_history |> set.contains(guard) {
    True -> #(Walk(guard_history |> set.map(get_position), True), guard)
    False ->
      case column >= 0 && column < width && row >= 0 && row < height {
        False -> #(Walk(guard_history |> set.map(get_position), False), guard)
        True -> {
          let guard_history = guard_history |> set.insert(guard)
          let guard = case facing {
            North ->
              case obstacles |> set.contains(#(row - 1, column)) {
                False -> Guard(#(row - 1, column), North)
                True -> Guard(position, East)
              }
            East ->
              case obstacles |> set.contains(#(row, column + 1)) {
                False -> Guard(#(row, column + 1), East)
                True -> Guard(position, South)
              }
            South ->
              case obstacles |> set.contains(#(row + 1, column)) {
                False -> Guard(#(row + 1, column), South)
                True -> Guard(position, West)
              }
            West ->
              case obstacles |> set.contains(#(row, column - 1)) {
                False -> Guard(#(row, column - 1), West)
                True -> Guard(position, North)
              }
          }
          walk_loop(guard_history, map, guard)
        }
      }
  }
}

/// position: #(row, column)
pub type Guard {
  Guard(position: #(Int, Int), facing: Direction)
}

type Symbol {
  Nothing
  Obstacle
  Direction(Direction)
}

fn parse_symbol(grapheme: String) -> Result(Symbol, Nil) {
  case grapheme {
    "^" | ">" | "v" | "<" -> {
      use direction <- result.try(grapheme |> common.parse_direction())
      Ok(Direction(direction))
    }
    "#" -> Ok(Obstacle)
    "." -> Ok(Nothing)
    _ -> Error(Nil)
  }
}

/// Find all positions that would have the guard walk in a loop
/// if there were an obstacle
pub fn looping_obstacles(map: Map, guard: Guard) -> Set(#(Int, Int)) {
  let assert Walk(visited_positions, False) = walk(map, guard)
  let Map(width, height, obstacles) = map
  let Guard(position, _) = guard
  let candidates =
    visited_positions
    |> set.delete(position)
  use candidate <- set.filter(candidates)
  let Walk(_, has_loop) =
    walk(Map(width, height, obstacles |> set.insert(candidate)), guard)
  has_loop
}
