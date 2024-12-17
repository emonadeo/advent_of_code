pub type Direction {
  North
  East
  South
  West
}

/// ## Examples
///
/// ```gleam
/// parse("^")
/// // -> Ok(North)
/// parse(">")
/// // -> Ok(East)
/// parse("v")
/// // -> Ok(South)
/// parse("<")
/// // -> Ok(West)
/// parse("v<")
/// // -> Error(Nil)
///```
pub fn parse(grapheme: String) -> Result(Direction, Nil) {
  case grapheme {
    "^" -> Ok(North)
    ">" -> Ok(East)
    "v" -> Ok(South)
    "<" -> Ok(West)
    _ -> Error(Nil)
  }
}

/// ## Examples
///
/// ```gleam
/// opposite(North)
/// // -> Ok(South)
/// opposite(East)
/// // -> Ok(West)
/// opposite(South)
/// // -> Ok(North)
/// opposite(West)
/// // -> Ok(East)
///```
pub fn opposite(direction: Direction) -> Direction {
  case direction {
    North -> South
    East -> West
    South -> North
    West -> East
  }
}

pub fn rotate_cw(direction: Direction) -> Direction {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

pub fn rotate_ccw(direction: Direction) -> Direction {
  case direction {
    North -> West
    West -> South
    South -> East
    East -> North
  }
}
