import gleam/list
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  lines
  |> yielder.map(string.to_graphemes)
  |> yielder.to_list()
  |> count_xmas()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  lines
  |> yielder.map(string.to_graphemes)
  |> yielder.to_list()
  |> count_x_mas()
}

pub fn count_xmas(graphemes: List(List(String))) -> Int {
  let graphemes_normalized = normalize(graphemes)
  count_xmas_horizontal(graphemes_normalized)
  + count_xmas_vertical(graphemes_normalized)
  + count_xmas_diagonal_1(graphemes_normalized)
  + count_xmas_diagonal_2(graphemes_normalized)
  + case graphemes {
    [] -> 0
    [first, ..rest] ->
      case list.rest(first) {
        Ok(first) -> count_xmas([first, ..rest])
        Error(Nil) -> count_xmas(rest)
      }
  }
}

fn normalize(graphemes: List(List(String))) -> List(List(String)) {
  case graphemes {
    [] -> graphemes
    [_] -> graphemes
    [first, ..rest] -> {
      [
        first,
        ..{
          use line <- list.map(rest)
          line |> list.drop(list.length(line) - list.length(first))
        }
      ]
    }
  }
}

fn count_xmas_horizontal(graphemes: List(List(String))) -> Int {
  case graphemes {
    [["X", "M", "A", "S", ..], ..] -> 1
    [["S", "A", "M", "X", ..], ..] -> 1
    _ -> 0
  }
}

fn count_xmas_vertical(graphemes: List(List(String))) -> Int {
  case graphemes {
    [["X", ..], ["M", ..], ["A", ..], ["S", ..], ..] -> 1
    [["S", ..], ["A", ..], ["M", ..], ["X", ..], ..] -> 1
    _ -> 0
  }
}

fn count_xmas_diagonal_1(graphemes: List(List(String))) -> Int {
  case graphemes {
    [["X", ..], [_, "M", ..], [_, _, "A", ..], [_, _, _, "S", ..], ..] -> 1
    [["S", ..], [_, "A", ..], [_, _, "M", ..], [_, _, _, "X", ..], ..] -> 1
    _ -> 0
  }
}

fn count_xmas_diagonal_2(graphemes: List(List(String))) -> Int {
  case graphemes {
    [[_, _, _, "X", ..], [_, _, "M", ..], [_, "A", ..], ["S", ..], ..] -> 1
    [[_, _, _, "S", ..], [_, _, "A", ..], [_, "M", ..], ["X", ..], ..] -> 1
    _ -> 0
  }
}

pub fn count_x_mas(graphemes: List(List(String))) -> Int {
  case normalize(graphemes) {
    [["M", _, "M", ..], [_, "A", _, ..], ["S", _, "S", ..], ..] -> 1
    [["S", _, "M", ..], [_, "A", _, ..], ["S", _, "M", ..], ..] -> 1
    [["M", _, "S", ..], [_, "A", _, ..], ["M", _, "S", ..], ..] -> 1
    [["S", _, "S", ..], [_, "A", _, ..], ["M", _, "M", ..], ..] -> 1
    _ -> 0
  }
  + case graphemes {
    [] -> 0
    [first, ..rest] ->
      case list.rest(first) {
        Ok(first) -> count_x_mas([first, ..rest])
        Error(Nil) -> count_x_mas(rest)
      }
  }
}
