import common.{East, North, South, West}
import day_15.{Box, Wall}
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should

pub fn parse_test() {
  let #(warehouse, robot, directions) =
    [
      "########", "#..O.O.#", "##@.O..#", "#...O..#", "#.#.O..#", "#...O..#",
      "#......#", "########", "", "<^^>>>vv<v>>v<<",
    ]
    |> list.map(string.to_graphemes)
    |> day_15.parse()

  robot |> should.equal(#(2, 2))
  warehouse
  |> should.equal(
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 1), Wall),
      #(#(0, 2), Wall),
      #(#(0, 3), Wall),
      #(#(0, 4), Wall),
      #(#(0, 5), Wall),
      #(#(0, 6), Wall),
      #(#(0, 7), Wall),
      #(#(1, 0), Wall),
      #(#(1, 3), Box),
      #(#(1, 5), Box),
      #(#(1, 7), Wall),
      #(#(2, 0), Wall),
      #(#(2, 1), Wall),
      #(#(2, 4), Box),
      #(#(2, 7), Wall),
      #(#(3, 0), Wall),
      #(#(3, 4), Box),
      #(#(3, 7), Wall),
      #(#(4, 0), Wall),
      #(#(4, 2), Wall),
      #(#(4, 4), Box),
      #(#(4, 7), Wall),
      #(#(5, 0), Wall),
      #(#(5, 4), Box),
      #(#(5, 7), Wall),
      #(#(6, 0), Wall),
      #(#(6, 7), Wall),
      #(#(7, 0), Wall),
      #(#(7, 1), Wall),
      #(#(7, 2), Wall),
      #(#(7, 3), Wall),
      #(#(7, 4), Wall),
      #(#(7, 5), Wall),
      #(#(7, 6), Wall),
      #(#(7, 7), Wall),
    ]),
  )

  directions
  |> should.equal([
    West,
    North,
    North,
    East,
    East,
    East,
    South,
    South,
    West,
    South,
    East,
    East,
    South,
    West,
    West,
  ])
}

pub fn move_all_test() {
  let warehouse =
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 1), Wall),
      #(#(0, 2), Wall),
      #(#(0, 3), Wall),
      #(#(0, 4), Wall),
      #(#(0, 5), Wall),
      #(#(0, 6), Wall),
      #(#(0, 7), Wall),
      #(#(1, 0), Wall),
      #(#(1, 3), Box),
      #(#(1, 5), Box),
      #(#(1, 7), Wall),
      #(#(2, 0), Wall),
      #(#(2, 1), Wall),
      #(#(2, 4), Box),
      #(#(2, 7), Wall),
      #(#(3, 0), Wall),
      #(#(3, 4), Box),
      #(#(3, 7), Wall),
      #(#(4, 0), Wall),
      #(#(4, 2), Wall),
      #(#(4, 4), Box),
      #(#(4, 7), Wall),
      #(#(5, 0), Wall),
      #(#(5, 4), Box),
      #(#(5, 7), Wall),
      #(#(6, 0), Wall),
      #(#(6, 7), Wall),
      #(#(7, 0), Wall),
      #(#(7, 1), Wall),
      #(#(7, 2), Wall),
      #(#(7, 3), Wall),
      #(#(7, 4), Wall),
      #(#(7, 5), Wall),
      #(#(7, 6), Wall),
      #(#(7, 7), Wall),
    ])
  let robot = #(2, 2)
  let directions = [
    West,
    North,
    North,
    East,
    East,
    East,
    South,
    South,
    West,
    South,
    East,
    East,
    South,
    West,
    West,
  ]

  let #(warehouse, robot) = warehouse |> day_15.move_all(robot, directions)

  warehouse
  |> should.equal(
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 1), Wall),
      #(#(0, 2), Wall),
      #(#(0, 3), Wall),
      #(#(0, 4), Wall),
      #(#(0, 5), Wall),
      #(#(0, 6), Wall),
      #(#(0, 7), Wall),
      #(#(1, 0), Wall),
      #(#(1, 5), Box),
      #(#(1, 6), Box),
      #(#(1, 7), Wall),
      #(#(2, 0), Wall),
      #(#(2, 1), Wall),
      #(#(2, 7), Wall),
      #(#(3, 0), Wall),
      #(#(3, 6), Box),
      #(#(3, 7), Wall),
      #(#(4, 0), Wall),
      #(#(4, 2), Wall),
      #(#(4, 3), Box),
      #(#(4, 7), Wall),
      #(#(5, 0), Wall),
      #(#(5, 4), Box),
      #(#(5, 7), Wall),
      #(#(6, 0), Wall),
      #(#(6, 4), Box),
      #(#(6, 7), Wall),
      #(#(7, 0), Wall),
      #(#(7, 1), Wall),
      #(#(7, 2), Wall),
      #(#(7, 3), Wall),
      #(#(7, 4), Wall),
      #(#(7, 5), Wall),
      #(#(7, 6), Wall),
      #(#(7, 7), Wall),
    ]),
  )

  robot |> should.equal(#(4, 4))
}

pub fn to_large_test() {
  let #(warehouse, robot) =
    [
      "##########", "#..O..O.O#", "#......O.#", "#.OO..O.O#", "#..O@..O.#",
      "#O#..O...#", "#O..O..O.#", "#.OO.O.OO#", "#....O...#", "##########",
    ]
    |> list.map(string.to_graphemes)
    |> day_15.parse_warehouse()

  let #(warehouse, robot) = warehouse |> day_15.to_large(robot)

  robot |> should.equal(#(4, 8))
  warehouse
  |> should.equal(
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 10), Wall),
      #(#(0, 12), Wall),
      #(#(0, 14), Wall),
      #(#(0, 16), Wall),
      #(#(0, 18), Wall),
      #(#(0, 2), Wall),
      #(#(0, 4), Wall),
      #(#(0, 6), Wall),
      #(#(0, 8), Wall),
      #(#(1, 0), Wall),
      #(#(1, 12), Box),
      #(#(1, 16), Box),
      #(#(1, 18), Wall),
      #(#(1, 6), Box),
      #(#(2, 0), Wall),
      #(#(2, 14), Box),
      #(#(2, 18), Wall),
      #(#(3, 0), Wall),
      #(#(3, 12), Box),
      #(#(3, 16), Box),
      #(#(3, 18), Wall),
      #(#(3, 4), Box),
      #(#(3, 6), Box),
      #(#(4, 0), Wall),
      #(#(4, 14), Box),
      #(#(4, 18), Wall),
      #(#(4, 6), Box),
      #(#(5, 0), Wall),
      #(#(5, 10), Box),
      #(#(5, 18), Wall),
      #(#(5, 2), Box),
      #(#(5, 4), Wall),
      #(#(6, 0), Wall),
      #(#(6, 14), Box),
      #(#(6, 18), Wall),
      #(#(6, 2), Box),
      #(#(6, 8), Box),
      #(#(7, 0), Wall),
      #(#(7, 10), Box),
      #(#(7, 14), Box),
      #(#(7, 16), Box),
      #(#(7, 18), Wall),
      #(#(7, 4), Box),
      #(#(7, 6), Box),
      #(#(8, 0), Wall),
      #(#(8, 10), Box),
      #(#(8, 18), Wall),
      #(#(9, 0), Wall),
      #(#(9, 10), Wall),
      #(#(9, 12), Wall),
      #(#(9, 14), Wall),
      #(#(9, 16), Wall),
      #(#(9, 18), Wall),
      #(#(9, 2), Wall),
      #(#(9, 4), Wall),
      #(#(9, 6), Wall),
      #(#(9, 8), Wall),
    ]),
  )
}

pub fn move_large_test() {
  // ##############
  // ##......##..##
  // ##..........##
  // ##....[][]@.##
  // ##....[]....##
  // ##..........##
  // ##############
  let robot = #(3, 10)
  let warehouse =
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 10), Wall),
      #(#(0, 12), Wall),
      #(#(0, 2), Wall),
      #(#(0, 4), Wall),
      #(#(0, 6), Wall),
      #(#(0, 8), Wall),
      #(#(1, 0), Wall),
      #(#(1, 12), Wall),
      #(#(1, 8), Wall),
      #(#(2, 0), Wall),
      #(#(2, 12), Wall),
      #(#(3, 0), Wall),
      #(#(3, 12), Wall),
      #(#(3, 6), Box),
      #(#(3, 8), Box),
      #(#(4, 0), Wall),
      #(#(4, 12), Wall),
      #(#(4, 6), Box),
      #(#(5, 0), Wall),
      #(#(5, 12), Wall),
      #(#(6, 0), Wall),
      #(#(6, 10), Wall),
      #(#(6, 12), Wall),
      #(#(6, 2), Wall),
      #(#(6, 4), Wall),
      #(#(6, 6), Wall),
      #(#(6, 8), Wall),
    ])

  let #(warehouse, robot) = day_15.move_large(warehouse, robot, West)

  robot |> should.equal(#(3, 9))
  warehouse
  |> should.equal(
    // ##############
    // ##......##..##
    // ##..........##
    // ##...[][]@..##
    // ##....[]....##
    // ##..........##
    // ##############
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 10), Wall),
      #(#(0, 12), Wall),
      #(#(0, 2), Wall),
      #(#(0, 4), Wall),
      #(#(0, 6), Wall),
      #(#(0, 8), Wall),
      #(#(1, 0), Wall),
      #(#(1, 12), Wall),
      #(#(1, 8), Wall),
      #(#(2, 0), Wall),
      #(#(2, 12), Wall),
      #(#(3, 0), Wall),
      #(#(3, 12), Wall),
      #(#(3, 5), Box),
      #(#(3, 7), Box),
      #(#(4, 0), Wall),
      #(#(4, 12), Wall),
      #(#(4, 6), Box),
      #(#(5, 0), Wall),
      #(#(5, 12), Wall),
      #(#(6, 0), Wall),
      #(#(6, 10), Wall),
      #(#(6, 12), Wall),
      #(#(6, 2), Wall),
      #(#(6, 4), Wall),
      #(#(6, 6), Wall),
      #(#(6, 8), Wall),
    ]),
  )
}

pub fn move_large_all_test() {
  let warehouse =
    dict.from_list([
      #(#(0, 0), Wall),
      #(#(0, 10), Wall),
      #(#(0, 12), Wall),
      #(#(0, 14), Wall),
      #(#(0, 16), Wall),
      #(#(0, 18), Wall),
      #(#(0, 2), Wall),
      #(#(0, 4), Wall),
      #(#(0, 6), Wall),
      #(#(0, 8), Wall),
      #(#(1, 0), Wall),
      #(#(1, 12), Box),
      #(#(1, 16), Box),
      #(#(1, 18), Wall),
      #(#(1, 6), Box),
      #(#(2, 0), Wall),
      #(#(2, 14), Box),
      #(#(2, 18), Wall),
      #(#(3, 0), Wall),
      #(#(3, 12), Box),
      #(#(3, 16), Box),
      #(#(3, 18), Wall),
      #(#(3, 4), Box),
      #(#(3, 6), Box),
      #(#(4, 0), Wall),
      #(#(4, 14), Box),
      #(#(4, 18), Wall),
      #(#(4, 6), Box),
      #(#(5, 0), Wall),
      #(#(5, 10), Box),
      #(#(5, 18), Wall),
      #(#(5, 2), Box),
      #(#(5, 4), Wall),
      #(#(6, 0), Wall),
      #(#(6, 14), Box),
      #(#(6, 18), Wall),
      #(#(6, 2), Box),
      #(#(6, 8), Box),
      #(#(7, 0), Wall),
      #(#(7, 10), Box),
      #(#(7, 14), Box),
      #(#(7, 16), Box),
      #(#(7, 18), Wall),
      #(#(7, 4), Box),
      #(#(7, 6), Box),
      #(#(8, 0), Wall),
      #(#(8, 10), Box),
      #(#(8, 18), Wall),
      #(#(9, 0), Wall),
      #(#(9, 10), Wall),
      #(#(9, 12), Wall),
      #(#(9, 14), Wall),
      #(#(9, 16), Wall),
      #(#(9, 18), Wall),
      #(#(9, 2), Wall),
      #(#(9, 4), Wall),
      #(#(9, 6), Wall),
      #(#(9, 8), Wall),
    ])
  let robot = #(4, 8)

  let assert Ok(directions) =
    string.to_graphemes(
      "<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^"
      <> "vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v"
      <> "><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<"
      <> "<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^"
      <> "^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><"
      <> "^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^"
      <> ">^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^"
      <> "<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>"
      <> "^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>"
      <> "v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^",
    )
    |> list.map(common.parse_direction)
    |> result.all()

  let #(warehouse, robot) =
    warehouse |> day_15.move_large_all(robot, directions)

  robot |> should.equal(#(7, 4))

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
  |> should.equal(9021)
}
