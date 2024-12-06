import day_06
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import gleeunit/should

const map = [
  "....#.....", ".........#", "..........", "..#.......", ".......#..",
  "..........", ".#..^.....", "........#.", "#.........", "......#...",
]

pub fn parse_test() {
  let #(day_06.Map(width, height, obstacles), day_06.Guard(position, facing)) =
    map
    |> list.map(string.to_graphemes)
    |> day_06.parse()

  width |> should.equal(10)
  height |> should.equal(10)
  position |> should.equal(#(6, 4))
  facing |> should.equal(day_06.North)
  obstacles
  |> should.equal(
    [#(0, 4), #(1, 9), #(3, 2), #(4, 7), #(6, 1), #(7, 8), #(8, 0), #(9, 6)]
    |> set.from_list,
  )
}

pub fn walk_test() {
  let #(map, guard) =
    map
    |> list.map(string.to_graphemes)
    |> day_06.parse()

  let visiteds = day_06.walk(map, guard)
  visiteds |> set.to_list() |> io.debug()
  visiteds |> set.size() |> should.equal(41)
}
