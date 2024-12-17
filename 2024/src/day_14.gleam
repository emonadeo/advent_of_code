import common
import file_streams/file_stream.{type FileStream}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder}
import position.{type Position}

pub fn part_01(lines: Yielder(String)) -> Int {
  lines
  |> yielder.to_list()
  |> list.map(parse_robot)
  |> result.all()
  |> common.assert_unwrap()
  |> list.map(fn(robot) { tick(robot, 100) })
  |> safety_factor()
}

pub fn part_02(lines: Yielder(String)) -> Int {
  io.println("Printing 10000 iterations to day_14.txt...")
  let assert Ok(file) = file_stream.open_write("day_14.txt")
  lines
  |> yielder.to_list()
  |> list.map(parse_robot)
  |> result.all()
  |> common.assert_unwrap()
  |> print_loop(file, 0)
  let assert Ok(Nil) = file_stream.close(file)
  io.println("...Done")
  0
}

const width = 101

const height = 103

pub type Robot {
  Robot(position: Position, velocity: #(Int, Int))
}

pub fn parse_robot(input: String) -> Result(Robot, Nil) {
  use #(position, velocity) <- result.try(input |> string.split_once(" "))

  use #(column, row) <- result.try(
    position |> string.drop_start(2) |> string.split_once(","),
  )
  use row <- result.try(row |> int.parse())
  use column <- result.try(column |> int.parse())
  let position = #(row, column)

  use #(column, row) <- result.try(
    velocity |> string.drop_start(2) |> string.split_once(","),
  )
  use row <- result.try(row |> int.parse())
  use column <- result.try(column |> int.parse())
  let velocity = #(row, column)

  Ok(Robot(position, velocity))
}

pub fn tick(robot: Robot, times: Int) -> Robot {
  let Robot(#(row, column), velocity) = robot
  let #(v_row, v_column) = velocity
  let assert Ok(row) = row + v_row * times |> int.modulo(height)
  let assert Ok(column) = column + v_column * times |> int.modulo(width)
  Robot(#(row, column), velocity)
}

pub fn safety_factor(robots: List(Robot)) -> Int {
  let #(a, b, c, d) = robot_count_in_quadrants(robots)
  a * b * c * d
}

pub fn robot_count_in_quadrants(robots: List(Robot)) -> #(Int, Int, Int, Int) {
  let center_row = height / 2
  let center_column = width / 2
  use #(a, b, c, d), Robot(position, _) <- list.fold(robots, #(0, 0, 0, 0))
  case position {
    #(row, column) if row < center_row && column < center_column -> #(
      a + 1,
      b,
      c,
      d,
    )
    #(row, column) if row < center_row && column > center_column -> #(
      a,
      b + 1,
      c,
      d,
    )
    #(row, column) if row > center_row && column < center_column -> #(
      a,
      b,
      c + 1,
      d,
    )
    #(row, column) if row > center_row && column > center_column -> #(
      a,
      b,
      c,
      d + 1,
    )
    _ -> #(a, b, c, d)
  }
}

pub fn print_loop(robots: List(Robot), file: FileStream, t: Int) -> Nil {
  let assert Ok(Nil) =
    file |> file_stream.write_chars("t = " <> int.to_string(t) <> "\n")
  let positions: Set(Position) =
    robots
    |> list.map(fn(robot) {
      let Robot(position, _) = robot
      position
    })
    |> set.from_list()

  let output =
    list.range(0, height - 1)
    |> list.map(fn(row) {
      list.range(0, width - 1)
      |> list.fold("", fn(output, column) {
        case positions |> set.contains(#(row, column)) {
          True -> output <> "#"
          False -> output <> " "
        }
      })
    })
    |> string.join("\n")

  let assert Ok(Nil) = file |> file_stream.write_chars(output <> "\n")

  case t < 10_000 {
    False -> Nil
    True -> {
      let robots = robots |> list.map(fn(robot) { tick(robot, 1) })
      print_loop(robots, file, t + 1)
    }
  }
}
