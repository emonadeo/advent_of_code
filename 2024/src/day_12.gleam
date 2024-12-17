import common
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import position.{type Position}

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let plants_map =
    lines
    |> yielder.map(string.to_graphemes)
    |> yielder.to_list()
    |> common.matrix_to_map()
  plants_map |> regions() |> list.map(region_price) |> int.sum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub type Region =
  Set(Position)

pub fn regions(plant_map: Dict(Position, String)) -> List(Region) {
  regions_loop(plant_map, dict.keys(plant_map))
}

fn regions_loop(
  plant_map: Dict(Position, String),
  queue: List(Position),
) -> List(Region) {
  case queue {
    [] -> []
    [position, ..queue] -> {
      let region = region(plant_map, position)
      let queue =
        queue
        |> set.from_list()
        |> set.difference(region)
        |> set.to_list()
      [region, ..regions_loop(plant_map, queue)]
    }
  }
}

fn region(plant_map: Dict(Position, String), position: Position) -> Region {
  let plant = plant_map |> dict.get(position) |> common.assert_unwrap()
  region_loop(plant_map, plant, position, set.new())
}

fn region_loop(
  plant_map: Dict(Position, String),
  plant: String,
  position: Position,
  region: Region,
) -> Region {
  case
    // `position` already in `region`
    region |> set.contains(position)
    // `position` not in `plant_map`
    || dict.get(plant_map, position) != Ok(plant)
  {
    True -> region
    False -> {
      let region = region |> set.insert(position)
      let #(row, column) = position
      let region = region_loop(plant_map, plant, #(row - 1, column), region)
      let region = region_loop(plant_map, plant, #(row + 1, column), region)
      let region = region_loop(plant_map, plant, #(row, column + 1), region)
      let region = region_loop(plant_map, plant, #(row, column - 1), region)
      region
    }
  }
}

pub fn region_price(region: Region) -> Int {
  region_area(region) * region_perimeter(region)
}

pub fn region_area(region: Region) -> Int {
  region |> set.size()
}

pub fn region_perimeter(region: Region) -> Int {
  case region |> set.to_list() |> list.first() {
    Ok(position) -> {
      let #(perimeter, _) = region_perimeter_loop(region, position, set.new())
      perimeter
    }
    Error(Nil) -> 0
  }
}

fn region_perimeter_loop(
  region: Region,
  position: Position,
  checked: Set(Position),
) -> #(Int, Set(Position)) {
  case checked |> set.contains(position) {
    True -> #(0, checked)
    False -> {
      let checked = checked |> set.insert(position)
      use accumulator, position <- list.fold(
        position |> position.neighbors_4(),
        #(0, checked),
      )
      let #(perimeter, checked) = accumulator
      case region |> set.contains(position) {
        False -> #(perimeter + 1, checked)
        True -> {
          let #(p, checked) = region_perimeter_loop(region, position, checked)
          #(perimeter + p, checked)
        }
      }
    }
  }
}

pub fn region_sides_amount(region: Region) -> Int {
  case region |> set.to_list() |> list.first() {
    Ok(position) -> {
      let #(perimeter, _) =
        region_sides_amount_loop(region, position, set.new())
      perimeter
    }
    Error(Nil) -> 0
  }
}

fn region_sides_amount_loop(
  region: Region,
  position: Position,
  checked: Set(Position),
) -> #(Int, Set(Position)) {
  case checked |> set.contains(position) {
    True -> #(0, checked)
    False -> {
      let checked = checked |> set.insert(position)
      todo
    }
  }
}

/// Find a random position `#(row, column)` inside a region,
/// where `#(row - 1, column)` is outside of the region.
/// Errors if the region is empty.
fn region_top_border_position(region: Region) -> Result(Position, Nil) {
  use position <- result.try(region |> set.to_list() |> list.first())
  Ok(region_top_border_position_loop(region, position))
}

fn region_top_border_position_loop(
  region: Region,
  position: Position,
) -> Position {
  let #(row, column) = position
  case region |> set.contains(#(row - 1, column)) {
    False -> position
    True -> region_top_border_position_loop(region, position)
  }
}
