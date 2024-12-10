import common
import gleam/dict
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn matrix_to_map_test() {
  [[6, 7], [8, 9]]
  |> common.matrix_to_map()
  |> should.equal(
    dict.from_list([#(#(0, 0), 6), #(#(0, 1), 7), #(#(1, 0), 8), #(#(1, 1), 9)]),
  )
}
