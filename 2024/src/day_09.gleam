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
  let assert [input] = lines |> yielder.to_list()
  input
  |> string.to_graphemes()
  |> parse_disk()
  |> blocks_from_disk()
  |> compact_blocks()
  |> blocks_to_disk()
  |> checksum()
}

pub type Disk =
  List(Option(Int))

pub type Block {
  Block(file_id: Option(Int), length: Int)
}

/// ## Examples
///
/// ```gleam
/// block_to_string(Block(Some(99), 2))
/// // -> "99"
/// block_to_string(Block(None, 5))
/// // -> "....."
/// ```
pub fn block_to_string(block: Block) -> String {
  let Block(file_id, length) = block
  let symbol = case file_id {
    Some(file_id) -> int.to_string(file_id)
    None -> "."
  }
  string.repeat(symbol, length)
}

/// ## Examples
///
/// ```gleam
/// blocks_from_disk([Some(0), Some(0), None, Some(1)])
/// // -> [Block(Some(0), 2), Block(None, 1), Block(Some(1), 1)]
/// ```
pub fn blocks_from_disk(disk: Disk) -> List(Block) {
  blocks_from_disk_loop([], disk) |> list.reverse()
}

fn blocks_from_disk_loop(blocks: List(Block), disk: Disk) -> List(Block) {
  case blocks, disk {
    blocks, [] -> blocks
    [Block(last_file_id, last_length), ..blocks], [file_id, ..rest]
      if file_id == last_file_id
    -> {
      blocks_from_disk_loop(
        [Block(last_file_id, last_length + 1), ..blocks],
        rest,
      )
    }
    blocks, [file_id, ..rest] -> {
      blocks_from_disk_loop([Block(file_id, 1), ..blocks], rest)
    }
  }
}

/// ## Examples
///
/// ```gleam
/// blocks_to_disk([Block(Some(0), 2), Block(None, 1), Block(Some(1), 1)])
/// // -> [Some(0), Some(0), None, Some(1)]
/// ```
pub fn blocks_to_disk(blocks: List(Block)) -> Disk {
  case blocks {
    [] -> []
    [Block(file_id, length), ..rest] ->
      list.repeat(file_id, length) |> list.append(rest |> blocks_to_disk())
  }
}

/// ## Examples
///
/// ```gleam
/// blocks_to_string([Block(Some(0), 2), Block(None, 1), Block(Some(1), 1)])
/// // -> "00.1"
/// ```
pub fn blocks_to_string(blocks: List(Block)) -> String {
  case blocks {
    [] -> ""
    [block, ..rest] -> block_to_string(block) <> blocks_to_string(rest)
  }
}

pub fn checksum(disk: Disk) -> Int {
  use sum, file_id, i <- list.index_fold(disk, 0)
  case file_id {
    Some(file_id) -> file_id * i + sum
    None -> sum
  }
}

pub fn compact_blocks(blocks: List(Block)) -> List(Block) {
  compact_blocks_loop([], deque.from_list(blocks))
}

fn compact_blocks_loop(
  compacted: List(Block),
  to_compact: Deque(Block),
) -> List(Block) {
  case to_compact |> deque.pop_back() {
    Error(Nil) -> compacted
    Ok(#(block, rest)) -> {
      case block {
        Block(None, _) -> compact_blocks_loop([block, ..compacted], rest)
        Block(Some(file_id), length) -> {
          case insert_block(deque.to_list(rest), #(file_id, length)) {
            Error(Nil) -> compact_blocks_loop([block, ..compacted], rest)
            Ok(rest) ->
              compact_blocks_loop(
                [Block(None, length), ..compacted],
                deque.from_list(rest),
              )
          }
        }
      }
    }
  }
}

pub fn compact_disk(disk: Disk) -> Disk {
  compact_disk_loop([], deque.from_list(disk)) |> list.reverse()
}

fn compact_disk_loop(compacted: Disk, to_compact: Deque(Option(Int))) -> Disk {
  case to_compact |> deque.pop_front() {
    Error(Nil) -> compacted
    Ok(#(Some(file_id), rest)) ->
      compact_disk_loop([Some(file_id), ..compacted], rest)
    Ok(#(None, rest)) ->
      case rest |> common.pop_back_some() {
        Error(Nil) -> compacted
        Ok(#(file_id, rest)) ->
          compact_disk_loop([Some(file_id), ..compacted], rest)
      }
  }
}

/// ## Examples
/// 
/// ```gleam
/// disk_to_string([Some(9), Some(9), None, Some(1)])
/// // -> "99.1"
/// ```
pub fn disk_to_string(disk: Disk) -> String {
  case disk {
    [] -> ""
    [file_id, ..rest] -> {
      let symbol = case file_id {
        Some(file_id) -> int.to_string(file_id)
        None -> "."
      }
      symbol <> disk_to_string(rest)
    }
  }
}

/// Insert a Block into the next free space available.
/// Errors if there is no free space left, that can fit it.
///
/// ## Examples
///
/// ```gleam
/// // 00...111
/// [Block(Some(0), 2), Block(None, 3), Block(Some(1), 3)]
/// // 99
/// insert_block(#(9, 2))
/// // 0099.111
/// // -> [Block(Some(0), 2), Block(Some(9), 2), Block(None, 1), Block(Some(1), 3)]
/// ```
pub fn insert_block(
  into blocks: List(Block),
  block block: #(Int, Int),
) -> Result(List(Block), Nil) {
  insert_block_loop([], blocks, block)
}

fn insert_block_loop(
  skipped: List(Block),
  to_check: List(Block),
  block: #(Int, Int),
) -> Result(List(Block), Nil) {
  let #(file_id, length) = block
  let block = Block(Some(file_id), length)
  case to_check {
    [] -> Error(Nil)
    [Block(None, available_length), ..rest] if length < available_length ->
      Ok(
        skipped
        |> list.reverse()
        |> list.append([block, Block(None, available_length - length), ..rest]),
      )

    [Block(None, available_length), ..rest] if length == available_length ->
      Ok(
        skipped
        |> list.reverse()
        |> list.append([block, ..rest]),
      )
    [skip, ..rest] ->
      insert_block_loop([skip, ..skipped], rest, #(file_id, length))
  }
}

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
