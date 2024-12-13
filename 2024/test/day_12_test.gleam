import common
import day_12
import gleam/list
import gleam/set
import gleam/string
import gleeunit/should

pub fn regions_test() {
  ["AAAA", "BBCD", "BBCC", "EEEC"]
  |> list.map(string.to_graphemes)
  |> common.matrix_to_map()
  |> day_12.regions()
  |> set.from_list()
  |> should.equal(
    set.from_list([
      set.from_list([#(0, 0), #(0, 1), #(0, 2), #(0, 3)]),
      set.from_list([#(1, 0), #(1, 1), #(2, 0), #(2, 1)]),
      set.from_list([#(1, 2), #(2, 2), #(2, 3), #(3, 3)]),
      set.from_list([#(1, 3)]),
      set.from_list([#(3, 0), #(3, 1), #(3, 2)]),
    ]),
  )
}

pub fn region_area_test() {
  set.from_list([#(0, 0), #(0, 1), #(0, 2), #(0, 3)])
  |> day_12.region_area()
  |> should.equal(4)

  set.from_list([#(1, 0), #(1, 1), #(2, 0), #(2, 1)])
  |> day_12.region_area()
  |> should.equal(4)

  set.from_list([#(1, 2), #(2, 2), #(2, 3), #(3, 3)])
  |> day_12.region_area()
  |> should.equal(4)

  set.from_list([#(1, 3)])
  |> day_12.region_area()
  |> should.equal(1)

  set.from_list([#(3, 0), #(3, 1), #(3, 2)])
  |> day_12.region_area()
  |> should.equal(3)
}

pub fn region_perimeter_test() {
  set.from_list([#(0, 0), #(0, 1), #(0, 2), #(0, 3)])
  |> day_12.region_perimeter()
  |> should.equal(10)

  set.from_list([#(1, 0), #(1, 1), #(2, 0), #(2, 1)])
  |> day_12.region_perimeter()
  |> should.equal(8)

  set.from_list([#(1, 2), #(2, 2), #(2, 3), #(3, 3)])
  |> day_12.region_perimeter()
  |> should.equal(10)

  set.from_list([#(1, 3)])
  |> day_12.region_perimeter()
  |> should.equal(4)

  set.from_list([#(3, 0), #(3, 1), #(3, 2)])
  |> day_12.region_perimeter()
  |> should.equal(8)
}
