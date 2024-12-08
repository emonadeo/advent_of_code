import common
import day_08
import gleam/io
import gleam/list
import gleam/set
import gleam/string
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
