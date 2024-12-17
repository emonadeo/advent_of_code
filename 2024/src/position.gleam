import direction.{type Direction, East, North, South, West}

/// `#(row, column)`
pub type Position =
  #(Int, Int)

/// Offset a `position` by 1 unit into a given `direction`.
///
/// ## Examples
///
/// ```gleam
/// adjacent(#(0, 0), North)
/// // -> #(-1, 0)
/// adjacent(#(0, 0), East)
/// // -> #(0, 1)
/// adjacent(#(0, 0), South)
/// // -> #(1, 0)
/// adjacent(#(0, 0), West)
/// // -> #(0, -1)
/// ```
pub fn adjacent(position: Position, direction: Direction) -> Position {
  let #(row, column) = position
  case direction {
    North -> #(row - 1, column)
    East -> #(row, column + 1)
    South -> #(row + 1, column)
    West -> #(row, column - 1)
  }
}

/// Returns 4-connected neighbors of a given `position`.
/// Also known as “Von Neumann neigborhood”.
///
/// ## Examples
///
/// ```gleam
/// neighbors_4(#(0, 0))
/// // -> [#(-1, 0), #(0, 1), #(1, 0), #(0, -1)]
/// ```
pub fn neighbors_4(position: Position) -> List(Position) {
  let #(row, column) = position
  [
    #(row - 1, column),
    #(row, column + 1),
    #(row + 1, column),
    #(row, column - 1),
  ]
}

/// Returns 8-connected neighbors of a given `position`.
/// Also known as “Von Neumann neigborhood”.
///
/// ## Examples
///
/// ```gleam
/// neighbors_4(#(0, 0))
/// // -> [#(-1, 0), #(-1, 1), #(0, 1), #(1, 1),
/// // #(1, 0), #(1, -1), #(0, -1), #(-1, -1)]
/// ```
pub fn neighbors_8(position: Position) -> List(Position) {
  let #(row, column) = position
  [
    #(row - 1, column),
    #(row - 1, column + 1),
    #(row, column + 1),
    #(row + 1, column + 1),
    #(row + 1, column),
    #(row + 1, column - 1),
    #(row, column - 1),
    #(row - 1, column - 1),
  ]
}
