import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  lines
  |> yielder.map(string.to_graphemes)
  |> yielder.to_list()
  |> count_xmas()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub fn count_xmas(graphemes: List(List(String))) -> Int {
  count_xmas_loop(graphemes)
}

fn count_xmas_loop(graphemes: List(List(String))) -> Int {
  let graphemes_normalized = normalize(graphemes)
  let count =
    count_xmas_horizontal(graphemes_normalized)
    + count_xmas_vertical(graphemes_normalized)
    + count_xmas_diagonal_1(graphemes_normalized)
    + count_xmas_diagonal_2(graphemes_normalized)

  count
  + case graphemes {
    [] -> 0
    [first, ..rest] ->
      case list.rest(first) {
        Ok(first) -> count_xmas_loop([first, ..rest])
        Error(Nil) -> count_xmas_loop(rest)
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

fn width(graphemes: List(List(String))) -> Int {
  case graphemes {
    [] -> 0
    [line, ..] -> line |> list.length()
  }
}

fn height(graphemes: List(List(String))) -> Int {
  list.length(graphemes)
}
