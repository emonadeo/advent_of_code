import direction.{type Direction}
import gleam/pair
import position.{type Position}

pub type DirectedPosition =
  #(Position, Direction)

/// ## Examples
///
/// ```gleam
/// position(#(#(0, 0), North))
/// // -> #(0, 0)
/// ```
pub fn position(directed_position: DirectedPosition) -> Position {
  directed_position |> pair.first()
}

/// ## Examples
///
/// ```gleam
/// direction(#(#(0, 0), North))
/// // -> North
/// ```
pub fn direction(directed_position: DirectedPosition) -> Direction {
  directed_position |> pair.second()
}

pub fn map_position(
  directed_position: DirectedPosition,
  function: fn(Position) -> Position,
) -> DirectedPosition {
  directed_position |> pair.map_first(function)
}

pub fn map_direction(
  directed_position: DirectedPosition,
  function: fn(Direction) -> Direction,
) -> DirectedPosition {
  directed_position |> pair.map_second(function)
}

/// Move `position` one unit into the `direction` it is “facing”.
///
/// ## Examples
///
/// ```gleam
/// advance(#(#(0, 0), North))
/// // -> #(#(-1, 0), North)
/// advance(#(#(0, 0), East))
/// // -> #(#(0, 1), East)
/// advance(#(#(0, 0), South))
/// // -> #(#(1, 0), South)
/// advance(#(#(0, 0), West))
/// // -> #(#(0, -1), West)
/// ```
pub fn advance(directed_position: DirectedPosition) -> DirectedPosition {
  let #(position, direction) = directed_position
  let position = position |> position.adjacent(direction)
  #(position, direction)
}
