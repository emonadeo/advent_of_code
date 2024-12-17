import common.{East, North, South, West}
import day_15.{Box, Wall}
import gleam/dict
import gleam/list
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

  robot |> should.equal(#(2, 2))

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

pub fn move_test() {
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
