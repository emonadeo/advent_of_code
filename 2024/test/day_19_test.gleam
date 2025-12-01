import day_19
import gleam/set
import gleeunit/should

pub fn can_form_test() {
  let patterns =
    ["r", "wr", "b", "g", "bwu", "rb", "gb", "br"] |> set.from_list()
  day_19.can_form(patterns, "brwrr")
  |> should.equal(True)
  day_19.can_form(patterns, "bggr")
  |> should.equal(True)
  day_19.can_form(patterns, "gbbr")
  |> should.equal(True)
  day_19.can_form(patterns, "rrbgbr")
  |> should.equal(True)
  day_19.can_form(patterns, "ubwu")
  |> should.equal(False)
  day_19.can_form(patterns, "bwurrg")
  |> should.equal(True)
  day_19.can_form(patterns, "brgr")
  |> should.equal(True)
  day_19.can_form(patterns, "bbrgwb")
  |> should.equal(False)
}
