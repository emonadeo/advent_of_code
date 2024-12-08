import common
import gleam/dict
import gleam/list
import gleam/pair
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let graphemes =
    lines
    |> yielder.to_list()
    |> list.map(string.to_graphemes)
  let #(width, height) = graphemes |> common.dimensions()
  let antinodes =
    graphemes
    |> parse()
    |> set.map(antinodes)
    |> common.flatten_set()
    |> set.filter(fn(node) {
      let #(row, column) = node
      row >= 0 && row < width && column >= 0 && column < height
    })
  antinodes |> set.size()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

/// ## Examples
/// ```gleam
/// ["...6",
///  ".a..",
///  "..a.",
///  ".B.."]
/// |> list.map(string.to_graphemes)
/// |> day_08.parse()
/// // -> [[#(0, 3)],
/// //     [#(1, 1), #(2, 2)],
/// //     [#(3, 1)]]
/// ```
pub fn parse(graphemes: List(List(String))) -> Set(Set(#(Int, Int))) {
  graphemes
  |> common.positions()
  |> list.filter(fn(x) { x |> pair.second() != "." })
  |> list.group(pair.second)
  |> dict.map_values(fn(_, x) { x |> list.map(pair.first) |> set.from_list() })
  |> dict.values()
  |> set.from_list()
}

pub fn antinodes(nodes: Set(#(Int, Int))) -> Set(#(Int, Int)) {
  {
    use #(#(row_a, col_a), #(row_b, col_b)) <- list.map(
      nodes |> set.to_list() |> list.combination_pairs(),
    )
    let row_diff = row_b - row_a
    let col_diff = col_b - col_a
    [
      #(row_a - row_diff, col_a - col_diff),
      #(row_b + row_diff, col_b + col_diff),
    ]
  }
  |> list.flatten()
  |> set.from_list()
}
