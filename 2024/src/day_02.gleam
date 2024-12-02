import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let reports = yielder.map(lines, parse_report)
  yielder.filter(reports, is_safe) |> yielder.length
}

fn parse_report(line: String) -> List(Int) {
  let line = line |> string.trim
  let levels = {
    use level <- yielder.map(line |> string.split(" ") |> yielder.from_list)
    let assert Ok(level) = level |> int.parse()
    level
  }
  levels |> yielder.to_list()
}

pub fn is_safe(report: List(Int)) -> Bool {
  is_safe_with_order(report, None)
}

fn is_safe_with_order(report: List(Int), increasing: Option(Bool)) -> Bool {
  case report, increasing {
    [], _ -> True
    [_], _ -> True
    // differ at least by 1
    [first, second, ..], _ if first == second -> False
    // differ at most by 3
    [first, second, ..], _ if first < second && second - first > 3 -> False
    [first, second, ..], _ if first > second && first - second > 3 -> False
    // always increase or always decrease
    [first, second, ..], Some(True) if first > second -> False
    [first, second, ..], Some(False) if first < second -> False
    // recurse
    [first, second, ..rest], None ->
      is_safe_with_order([second, ..rest], Some(second > first))
    [_, second, ..rest], Some(_) ->
      is_safe_with_order([second, ..rest], increasing)
  }
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}
