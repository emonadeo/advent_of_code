import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let #(map, guard) =
    lines |> yielder.to_list() |> list.map(string.to_graphemes) |> parse()
  walk(map, guard) |> set.size()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub fn parse(graphemes: List(List(String))) -> #(Map, Guard) {
  let #(width, height) = dimensions(graphemes)
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

pub fn walk(map: Map, guard: Guard) -> Set(#(Int, Int)) {
  let #(visiteds, _) = walk_loop(set.new(), map, guard)
  visiteds
}

fn walk_loop(
  visiteds: Set(#(Int, Int)),
  map: Map,
  guard: Guard,
) -> #(Set(#(Int, Int)), Guard) {
  let Map(width, height, obstacles) = map
  let Guard(position, facing) = guard
  let #(row, column) = position
  case column >= 0 && column < width && row >= 0 && row < height {
    False -> #(visiteds, guard)
    True -> {
      let visiteds = visiteds |> set.insert(position)
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
      walk_loop(visiteds, map, guard)
    }
  }
}

/// position: #(row, column)
pub type Guard {
  Guard(position: #(Int, Int), facing: Direction)
}

pub type Direction {
  North
  East
  South
  West
}

fn parse_direction(grapheme: String) -> Result(Direction, Nil) {
  case grapheme {
    "^" -> Ok(North)
    ">" -> Ok(East)
    "v" -> Ok(South)
    "<" -> Ok(West)
    _ -> Error(Nil)
  }
}

type Symbol {
  Nothing
  Obstacle
  Direction(Direction)
}

fn parse_symbol(grapheme: String) -> Result(Symbol, Nil) {
  case grapheme {
    "^" | ">" | "v" | "<" -> {
      use direction <- result.try(grapheme |> parse_direction())
      Ok(Direction(direction))
    }
    "#" -> Ok(Obstacle)
    "." -> Ok(Nothing)
    _ -> Error(Nil)
  }
}

/// Returns `#(width, height)` of a given list of rows
fn dimensions(rows: List(List(a))) -> #(Int, Int) {
  case rows {
    [] -> #(0, 0)
    [first_row, ..] -> #(list.length(first_row), list.length(rows))
  }
}
