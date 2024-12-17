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
  let graphemes =
    lines
    |> yielder.to_list()
    |> list.map(string.to_graphemes)
  let #(width, height) = graphemes |> common.dimensions()
  let antinodes =
    graphemes
    |> parse()
    |> set.map(fn(nodes) { repeating_antinodes(nodes, width, height) })
    |> common.flatten_set()
    |> set.filter(fn(node) {
      let #(row, column) = node
      row >= 0 && row < width && column >= 0 && column < height
    })
  antinodes |> set.size()
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
  |> common.matrix_to_map()
  |> dict.to_list()
  |> list.filter(fn(x) { x |> pair.second() != "." })
  |> list.group(pair.second)
  |> dict.map_values(fn(_, x) { x |> list.map(pair.first) |> set.from_list() })
  |> dict.values()
  |> set.from_list()
}

pub fn antinodes(nodes: Set(#(Int, Int))) -> Set(#(Int, Int)) {
  {
    use #(a, b) <- list.map(nodes |> set.to_list() |> list.combination_pairs())
    let delta = b |> common.sub_pair(a)
    [a |> common.sub_pair(delta), b |> common.add_pair(delta)]
  }
  |> list.flatten()
  |> set.from_list()
}

pub fn repeating_antinodes(
  nodes: Set(#(Int, Int)),
  width: Int,
  height: Int,
) -> Set(#(Int, Int)) {
  {
    use #(a, b) <- list.map(nodes |> set.to_list() |> list.combination_pairs())
    expand(a, b, width, height)
  }
  |> list.flatten()
  |> set.from_list()
}

/// Calculate all points that are in line with points `a` and `b` (`#(row, column)`)
/// inside a boundary of `0 <= row < height` and `0 <= column < width`
fn expand(
  a: #(Int, Int),
  b: #(Int, Int),
  width: Int,
  height: Int,
) -> List(#(Int, Int)) {
  let delta = b |> common.sub_pair(a)
  let head = expand_loop([b], delta, width, height)
  let tail = expand_loop([a], delta |> common.negate_pair(), width, height)
  list.append(head, tail)
}

fn expand_loop(
  points: List(#(Int, Int)),
  delta: #(Int, Int),
  width: Int,
  height: Int,
) -> List(#(Int, Int)) {
  case points {
    [] -> panic
    [#(row, column), ..rest]
      if row < 0 || row >= height || column < 0 || column >= width
    -> rest
    [a, ..rest] ->
      [a |> common.add_pair(delta), a, ..rest]
      |> expand_loop(delta, width, height)
  }
}
