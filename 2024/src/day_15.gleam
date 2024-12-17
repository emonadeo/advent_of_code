import direction.{type Direction, East, North, South, West}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}
import position.{type Position}

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
  let #(warehouse, robot, directions) =
    lines
    |> yielder.to_list()
    |> list.map(string.to_graphemes)
    |> parse()

  let #(warehouse, robot) = warehouse |> to_large(robot)
  let #(warehouse, _) = warehouse |> move_large_all(robot, directions)

  let boxes =
    warehouse
    |> dict.filter(fn(_, object) { object == Box })
    |> dict.keys()

  boxes
  |> list.map(fn(position) {
    let #(row, column) = position
    100 * row + column
  })
  |> int.sum()
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
    |> list.map(direction.parse)
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
  let next_position = position |> position.adjacent(direction)
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

pub fn to_large(warehouse: Warehouse, robot: Position) -> #(Warehouse, Position) {
  let warehouse =
    warehouse
    |> dict.to_list()
    |> list.map(fn(entry) {
      let #(#(row, column), object) = entry
      let column = 2 * column
      #(#(row, column), object)
    })
    |> dict.from_list()

  let #(row, column) = robot
  let robot = #(row, column * 2)

  #(warehouse, robot)
}

pub fn move_large_all(
  warehouse: Warehouse,
  robot: Position,
  directions: List(Direction),
) -> #(Warehouse, Position) {
  use #(w, r), d <- list.fold(directions, #(warehouse, robot))
  move_large(w, r, d)
}

pub fn move_large(
  warehouse: Warehouse,
  robot: Position,
  direction: Direction,
) -> #(Warehouse, Position) {
  let #(row, column) = robot
  // Robot must not clip inside a `Box` or `Wall`
  let assert Error(Nil) = warehouse |> dict.get(#(row, column - 1))

  let moved = case direction {
    North -> {
      use warehouse <- result.try(
        warehouse |> move_large_box(#(row - 1, column), direction),
      )
      warehouse |> move_large_box(#(row - 1, column - 1), direction)
    }
    East -> warehouse |> move_large_box(#(row, column + 1), direction)
    South -> {
      use warehouse <- result.try(
        warehouse |> move_large_box(#(row + 1, column), direction),
      )
      warehouse |> move_large_box(#(row + 1, column - 1), direction)
    }
    West -> {
      use warehouse <- result.try(
        warehouse |> move_large_box(#(row, column - 1), direction),
      )
      warehouse |> move_large_box(#(row, column - 2), direction)
    }
  }

  case moved {
    Ok(warehouse) -> #(warehouse, robot |> position.adjacent(direction))
    Error(Nil) -> #(warehouse, robot)
  }
}

/// Returns the `warehouse` unchanged if there isn't an object at the given `position`.
/// Errors if the `warehouse` has a `Wall` at the given `position`.
/// If there is a `Box`, try to push it.
/// Errors if it cannot be pushed, return the updated `warehouse` otherwise.
fn move_large_box(
  warehouse: Warehouse,
  position: Position,
  direction: Direction,
) -> Result(Warehouse, Nil) {
  case warehouse |> dict.get(position) {
    Error(Nil) -> Ok(warehouse)
    Ok(Wall) -> Error(Nil)
    Ok(Box) -> {
      let #(row, column) = position
      use warehouse <- result.try(case direction {
        North -> {
          use warehouse <- result.try(
            warehouse |> move_large_box(#(row - 1, column - 1), direction),
          )
          use warehouse <- result.try(
            warehouse |> move_large_box(#(row - 1, column), direction),
          )
          warehouse |> move_large_box(#(row - 1, column + 1), direction)
        }
        East -> warehouse |> move_large_box(#(row, column + 2), direction)
        South -> {
          use warehouse <- result.try(
            warehouse |> move_large_box(#(row + 1, column - 1), direction),
          )
          use warehouse <- result.try(
            warehouse |> move_large_box(#(row + 1, column), direction),
          )
          warehouse |> move_large_box(#(row + 1, column + 1), direction)
        }
        West -> move_large_box(warehouse, #(row, column - 2), direction)
      })

      warehouse
      |> dict.delete(position)
      |> dict.insert(position |> position.adjacent(direction), Box)
      |> Ok()
    }
  }
}
