import common
import day_08
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import gleam/yielder
import gleeunit/should

pub fn parse_test() {
  ["...6", ".a..", "..a.", ".B.."]
  |> list.map(string.to_graphemes)
  |> day_08.parse()
  |> should.equal(
    set.from_list([
      set.from_list([#(0, 3)]),
      set.from_list([#(1, 1), #(2, 2)]),
      set.from_list([#(3, 1)]),
    ]),
  )
}

pub fn part_02_test() {
  // T....#....
  // ...T......
  // .T....#...
  // .........#
  // ..#.......
  // ..........
  // ...#......
  // ..........
  // ....#.....
  // ..........
  let nodes = set.from_list([set.from_list([#(0, 0), #(1, 3), #(2, 1)])])
  let width = 10
  let height = 10
  nodes
  |> set.map(fn(nodes) { day_08.repeating_antinodes(nodes, width, height) })
  |> common.flatten_set()
  |> set.size()
  |> should.equal(9)

  // ##....#....#
  // .#.#....0...
  // ..#.#0....#.
  // ..##...0....
  // ....0....#..
  // .#...#A....#
  // ...#..#.....
  // #....#.#....
  // ..#.....A...
  // ....#....A..
  // .#........#.
  // ...#......##
  let nodes =
    set.from_list([
      set.from_list([#(5, 6), #(8, 8), #(9, 9)]),
      set.from_list([#(1, 8), #(2, 5), #(3, 7), #(4, 4)]),
    ])
  let width = 12
  let height = 12
  nodes
  |> set.map(fn(nodes) { day_08.repeating_antinodes(nodes, width, height) })
  |> common.flatten_set()
  |> set.size()
  |> should.equal(34)
}
