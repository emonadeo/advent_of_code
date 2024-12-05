import day_04
import gleam/list
import gleam/string
import gleeunit/should

pub fn count_xmas_test() {
  ["XMAS"]
  |> list.map(string.to_graphemes)
  |> day_04.count_xmas()
  |> should.equal(1)

  ["X...", "M...", "A...", "S..."]
  |> list.map(string.to_graphemes)
  |> day_04.count_xmas()
  |> should.equal(1)

  ["..X...", ".SAMX.", ".A..A.", "XMAS.S", ".X...."]
  |> list.map(string.to_graphemes)
  |> day_04.count_xmas()
  |> should.equal(4)

  [
    "MMMSXXMASM", "MSAMXMSMSA", "AMXSXMAAMM", "MSAMASMSMX", "XMASAMXAMM",
    "XXAMMXXAMA", "SMSMSASXSS", "SAXAMASAAA", "MAMMMXMMMM", "MXMXAXMASX",
  ]
  |> list.map(string.to_graphemes)
  |> day_04.count_xmas()
  |> should.equal(18)
}

pub fn count_x_mas_test() {
  [
    "MMMSXXMASM", "MSAMXMSMSA", "AMXSXMAAMM", "MSAMASMSMX", "XMASAMXAMM",
    "XXAMMXXAMA", "SMSMSASXSS", "SAXAMASAAA", "MAMMMXMMMM", "MXMXAXMASX",
  ]
  |> list.map(string.to_graphemes)
  |> day_04.count_x_mas()
  |> should.equal(9)
}
