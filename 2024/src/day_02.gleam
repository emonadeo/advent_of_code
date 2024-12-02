import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let reports = yielder.map(lines, parse_report)
  yielder.filter(reports, is_safe) |> yielder.length
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  let reports = yielder.map(lines, parse_report)
  yielder.filter(reports, is_mostly_safe) |> yielder.length
}

/// Convert a `String` of space-separated numbers into a `List(Int)`.
/// Whitespace around the start and end is ignored.
/// ## Examples
/// ```gleam
/// parse_report("")
/// // -> []
/// parse_report("\n")
/// // -> []
/// parse_report("1 2 3")
/// // -> [1, 2, 3]
/// parse_report("1 2 3\n")
/// // -> [1, 2, 3]
/// ```
fn parse_report(line: String) -> List(Int) {
  let line = line |> string.trim
  let levels = {
    use level <- yielder.map(line |> string.split(" ") |> yielder.from_list)
    let assert Ok(level) = level |> int.parse()
    level
  }
  levels |> yielder.to_list()
}

/// A report (a.k.a a list of numbers) is considered “safe”
/// if all elements are either in increasing or decreasing order
/// where two adjacent numbers must not be equal and have a difference of three or less
pub fn is_safe(report: List(Int)) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [a, b, ..] -> is_safe_with_ctx(report, b > a)
  }
}

fn is_safe_with_ctx(report: List(Int), should_increase: Bool) -> Bool {
  case report {
    [] -> True
    [_] -> True
    [a, b, ..rest] ->
      is_safe_one(a, b, should_increase)
      && is_safe_with_ctx([b, ..rest], should_increase)
  }
}

/// Same as `is_safe`, but considers unsafe reports that
/// become safe by skipping a single entry safe as well
pub fn is_mostly_safe(report: List(Int)) -> Bool {
  is_mostly_safe_with_ctx(report, should_increase: None, can_skip: True)
}

fn is_mostly_safe_with_ctx(
  report report: List(Int),
  should_increase should_increase: Option(Bool),
  can_skip can_skip: Bool,
) -> Bool {
  case report, should_increase, can_skip {
    [], _, _ -> True
    [_], _, _ -> True
    [curr, next, ..], None, False ->
      is_mostly_safe_with_ctx(
        report,
        should_increase: Some(next > curr),
        can_skip: False,
      )
    [curr, next, ..rest], None, True -> {
      is_safe_one(curr, next, should_increase: next > curr)
      && is_mostly_safe_with_ctx(
        report: [next, ..rest],
        should_increase: Some(next > curr),
        can_skip: True,
      )
      || is_mostly_safe_with_ctx(
        report: [next, ..rest],
        should_increase: None,
        can_skip: False,
      )
      || is_mostly_safe_with_ctx(
        report: [curr, ..rest],
        should_increase: None,
        can_skip: False,
      )
    }
    [curr, next, ..rest], Some(should_increase), False ->
      is_safe_one(curr, next, should_increase)
      && is_mostly_safe_with_ctx(
        report: [next, ..rest],
        should_increase: Some(should_increase),
        can_skip: False,
      )
    [curr, next, ..rest], Some(should_increase), True ->
      case is_safe_one(curr, next, should_increase) {
        True ->
          is_mostly_safe_with_ctx(
            report: [next, ..rest],
            should_increase: Some(should_increase),
            can_skip: True,
          )
        False ->
          is_mostly_safe_with_ctx(
            report: [curr, ..rest],
            should_increase: Some(should_increase),
            can_skip: False,
          )
      }
  }
}

/// A pair of numbers is considered “safe”, if they are not equal and
/// increase/decrease according to `should_increase` with a difference of three or less
fn is_safe_one(a: Int, b: Int, should_increase should_increase: Bool) -> Bool {
  case int.compare(a, b), should_increase {
    order.Lt, True if b - a <= 3 -> True
    order.Gt, False if a - b <= 3 -> True
    _, _ -> False
  }
}
