import common
import gleam/dict.{type Dict}
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/set.{type Set}
import gleam/yielder.{type Yielder}
import position.{type Position}

pub fn part_01(lines: Yielder(String)) -> Int {
  let assert Ok(obstacles) =
    lines
    |> yielder.map(position.parse)
    |> yielder.take(1024)
    |> yielder.to_list()
    |> result.all()
  let obstacles = obstacles |> set.from_list()
  let assert Ok(shortest_path) = shortest_path(obstacles, #(0, 0), #(70, 70))
  shortest_path |> list.length()
}

pub fn part_02(lines: Yielder(String)) -> Int {
  let positions =
    lines
    |> yielder.map(position.parse)

  let obstacles =
    positions
    |> yielder.take(1024)
    |> yielder.to_list()
    |> result.all()
    |> common.assert_unwrap()
    |> set.from_list()

  let #(_, last_position) =
    positions
    |> yielder.drop(1024)
    |> yielder.map(common.assert_unwrap)
    |> yielder.fold_until(#(obstacles, #(0, 0)), fn(accumulator, position) {
      let #(obstacles, _) = accumulator
      let obstacles = obstacles |> set.insert(position)
      let accumulator = #(obstacles, position)
      case shortest_path(obstacles, #(0, 0), #(70, 70)) {
        Error(Nil) -> Stop(accumulator)
        Ok(_) -> Continue(accumulator)
      }
    })
  io.debug(last_position)
  0
}

/// Errors, if `target` is not reachable.
pub fn shortest_path(
  obstacles: Set(Position),
  start: Position,
  target: Position,
) -> Result(List(Position), Nil) {
  let queue =
    start
    |> position.neighbors_4()
    |> list.map(fn(neighbor) { #(start, neighbor, 1) })
    |> set.from_list()
  dijkstra(obstacles, target, queue, dict.new())
  |> trace_to_path(start, target)
  |> result.map(list.reverse)
}

fn trace_to_path(
  trace: Dict(Position, Position),
  start: Position,
  target: Position,
) -> Result(List(Position), Nil) {
  case start == target {
    True -> Ok([])
    False -> {
      use step <- result.try(trace |> dict.get(target))
      use rest <- result.try(trace_to_path(trace, start, step))
      Ok([step, ..rest])
    }
  }
}

fn dijkstra(
  obstacles: Set(Position),
  target: Position,
  queue: Set(#(Position, Position, Int)),
  trace: Dict(Position, Position),
) -> Dict(Position, Position) {
  let lowest =
    queue
    |> set.to_list()
    |> common.min(fn(element) { element.2 })
  case lowest {
    Error(Nil) -> trace
    Ok(lowest) -> {
      let queue = queue |> set.delete(lowest)
      let #(from, to, score) = lowest
      case
        obstacles |> set.contains(to)
        || trace |> dict.has_key(to)
        || is_out_of_bounds(to)
      {
        True -> dijkstra(obstacles, target, queue, trace)
        False -> {
          let trace = trace |> dict.insert(to, from)
          case to == target {
            True -> trace
            False -> {
              let queue =
                position.neighbors_4(to)
                |> list.map(fn(neighbor) { #(to, neighbor, score + 1) })
                |> set.from_list()
                |> set.union(queue)
              dijkstra(obstacles, target, queue, trace)
            }
          }
        }
      }
    }
  }
}

fn is_out_of_bounds(position: Position) -> Bool {
  let #(row, column) = position
  row < 0 || row > 70 || column < 0 || column > 70
}
