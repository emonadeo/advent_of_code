import day_16
import gleam/list
import gleam/string
import gleeunit/should

pub fn lowest_score_test() {
  let assert Ok(#(maze, start, target)) =
    [
      "###############", "#.......#....E#", "#.#.###.#.###.#", "#.....#.#...#.#",
      "#.###.#####.#.#", "#.#.#.......#.#", "#.#.#####.###.#", "#...........#.#",
      "###.#.#####.#.#", "#...#.....#.#.#", "#.#.#.###.#.#.#", "#.....#...#.#.#",
      "#.###.#.#.#.#.#", "#S..#.....#...#", "###############",
    ]
    |> list.map(string.to_graphemes)
    |> day_16.parse()
  maze |> day_16.lowest_score(start, target) |> should.equal(Ok(7036))
}
