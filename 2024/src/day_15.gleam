import common.{type Direction, type Position}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}

pub fn part_01(lines: Yielder(String)) -> Int {
  let #(warehouse, robot, directions) =
    lines
    |> yielder.to_list()
    |> list.map(string.to_graphemes)
    |> parse()

  let #(warehouse, _) = warehouse |> move_all(robot, directions)

  warehouse
  |> dict.filter(fn(_, object) { object == Box })
  |> dict.keys()
  |> list.map(fn(position) {
    let #(row, column) = position
    100 * row + column
  })
  |> int.sum()
}

pub fn part_02(lines: Yielder(String)) -> Int {
  todo
}

pub fn parse(
  graphemes: List(List(String)),
) -> #(Warehouse, #(Int, Int), List(Direction)) {
  let #(warehouse, directions) =
    graphemes |> list.split_while(fn(row) { !list.is_empty(row) })

  // Remove the empty line splitting `warehouse` from `directions`
  let assert [_, ..directions] = directions

  let assert Ok(directions) =
    directions
    |> list.flatten()
    |> list.map(common.parse_direction)
    |> result.all()

  let #(warehouse, robot) = warehouse |> parse_warehouse()

  #(warehouse, robot, directions)
}

pub type Warehouse =
  Dict(Position, Object)

/// Returns warehouse and starting robot position.
pub fn parse_warehouse(
  graphemes: List(List(String)),
) -> #(Warehouse, #(Int, Int)) {
  use #(warehouse, robot), graphemes, row <- list.index_fold(
    graphemes,
    #(dict.new(), #(0, 0)),
  )
  use #(warehouse, robot), grapheme, column <- list.index_fold(graphemes, #(
    warehouse,
    robot,
  ))
  case grapheme {
    "@" -> #(warehouse, #(row, column))
    "#" -> #(warehouse |> dict.insert(#(row, column), Wall), robot)
    "O" -> #(warehouse |> dict.insert(#(row, column), Box), robot)
    "." -> #(warehouse, robot)
    _ -> panic
  }
}

pub type Object {
  Wall
  Box
}

pub fn parse_object(grapheme: String) -> Result(Option(Object), Nil) {
  case grapheme {
    "." -> Ok(None)
    "#" -> Ok(Some(Wall))
    "O" -> Ok(Some(Box))
    _ -> Error(Nil)
  }
}

pub type Movement {
  North
  East
  South
  West
}

pub fn parse_movements(graphemes: List(String)) -> Result(List(Direction), Nil) {
  graphemes |> list.map(common.parse_direction) |> result.all()
}

pub fn move_all(
  warehouse: Warehouse,
  position: Position,
  directions: List(Direction),
) -> #(Warehouse, Position) {
  use #(w, p), d <- list.fold(directions, #(warehouse, position))
  move(w, p, d)
}

pub fn move(
  warehouse: Warehouse,
  position: Position,
  direction: Direction,
) -> #(Warehouse, Position) {
  let next_position = position |> common.adjacent(direction)
  case warehouse |> dict.get(next_position) {
    Error(Nil) -> #(warehouse, next_position)
    Ok(Wall) -> #(warehouse, position)
    Ok(Box) -> {
      let #(warehouse, next_next_position) =
        move(warehouse, next_position, direction)
      case next_position == next_next_position {
        // Blocked
        True -> #(warehouse, position)
        // Moved successfully
        False -> {
          let warehouse =
            warehouse
            |> dict.delete(next_position)
            |> dict.insert(next_next_position, Box)
          #(warehouse, next_position)
        }
      }
    }
  }
}
