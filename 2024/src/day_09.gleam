import common
import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/yielder

pub fn part_01(lines: yielder.Yielder(String)) -> Int {
  let assert [input] = lines |> yielder.to_list()
  input
  |> string.to_graphemes()
  |> parse_disk()
  |> compact_disk()
  |> checksum()
}

pub fn part_02(lines: yielder.Yielder(String)) -> Int {
  todo
}

pub type Disk =
  List(Option(Int))

pub type CompactedDisk =
  List(Int)

pub fn parse_disk(graphemes: List(String)) -> Disk {
  parse_disk_loop(graphemes, 0)
}

fn parse_disk_loop(graphemes: List(String), next_id: Int) -> Disk {
  case graphemes {
    [] -> []
    [file_length] -> {
      let assert Ok(file_length) = int.parse(file_length)
      list.repeat(Some(next_id), file_length)
    }
    [file_length, free_length, ..rest] -> {
      let assert Ok(file_length) = int.parse(file_length)
      let assert Ok(free_length) = int.parse(free_length)
      list.repeat(Some(next_id), file_length)
      |> list.append(list.repeat(None, free_length))
      |> list.append(parse_disk_loop(rest, next_id + 1))
    }
  }
}

pub fn compact_disk(disk: Disk) -> CompactedDisk {
  compact_disk_loop([], deque.from_list(disk)) |> list.reverse()
}

fn compact_disk_loop(
  compacted: CompactedDisk,
  to_compact: Deque(Option(Int)),
) -> CompactedDisk {
  case to_compact |> deque.pop_front() {
    Ok(#(Some(file_id), rest)) ->
      [file_id, ..compacted] |> compact_disk_loop(rest)
    Ok(#(None, rest)) ->
      case rest |> common.pop_back_some() {
        Ok(#(file_id, rest)) ->
          [file_id, ..compacted] |> compact_disk_loop(rest)
        Error(Nil) -> compacted
      }
    Error(Nil) -> compacted
  }
}

pub fn checksum(compacted_disk: CompactedDisk) -> Int {
  use sum, file_id, i <- list.index_fold(compacted_disk, 0)
  file_id * i + sum
}
