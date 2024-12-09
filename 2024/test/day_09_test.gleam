import day_09.{type Block, type Disk, Block}
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

// 00...111...2...333.44.5555.6666.777.888899
const disk: Disk = [
  Some(0),
  Some(0),
  None,
  None,
  None,
  Some(1),
  Some(1),
  Some(1),
  None,
  None,
  None,
  Some(2),
  None,
  None,
  None,
  Some(3),
  Some(3),
  Some(3),
  None,
  Some(4),
  Some(4),
  None,
  Some(5),
  Some(5),
  Some(5),
  Some(5),
  None,
  Some(6),
  Some(6),
  Some(6),
  Some(6),
  None,
  Some(7),
  Some(7),
  Some(7),
  None,
  Some(8),
  Some(8),
  Some(8),
  Some(8),
  Some(9),
  Some(9),
]

// 0099811188827773336446555566
const compacted_disk: Disk = [
  Some(0),
  Some(0),
  Some(9),
  Some(9),
  Some(8),
  Some(1),
  Some(1),
  Some(1),
  Some(8),
  Some(8),
  Some(8),
  Some(2),
  Some(7),
  Some(7),
  Some(7),
  Some(3),
  Some(3),
  Some(3),
  Some(6),
  Some(4),
  Some(4),
  Some(6),
  Some(5),
  Some(5),
  Some(5),
  Some(5),
  Some(6),
  Some(6),
]

/// 00...111...2...333.44.5555.6666.777.888899
const blocks: List(Block) = [
  Block(Some(0), 2),
  Block(None, 3),
  Block(Some(1), 3),
  Block(None, 3),
  Block(Some(2), 1),
  Block(None, 3),
  Block(Some(3), 3),
  Block(None, 1),
  Block(Some(4), 2),
  Block(None, 1),
  Block(Some(5), 4),
  Block(None, 1),
  Block(Some(6), 4),
  Block(None, 1),
  Block(Some(7), 3),
  Block(None, 1),
  Block(Some(8), 4),
  Block(Some(9), 2),
]

// 00992111777.44.333....5555.6666.....8888..
const compacted_blocks: List(Block) = [
  Block(Some(0), 2),
  Block(Some(9), 2),
  Block(Some(2), 1),
  Block(Some(1), 3),
  Block(Some(7), 3),
  Block(None, 1),
  Block(Some(4), 2),
  Block(None, 1),
  Block(Some(3), 3),
  Block(None, 4),
  Block(Some(5), 4),
  Block(None, 1),
  Block(Some(6), 4),
  Block(None, 5),
  Block(Some(8), 4),
  Block(None, 2),
]

pub fn blocks_from_disk_test() {
  disk
  |> day_09.blocks_from_disk()
  |> should.equal(blocks)
}

pub fn blocks_to_disk_test() {
  blocks |> day_09.blocks_to_disk() |> should.equal(disk)
}

pub fn checksum_test() {
  compacted_disk |> day_09.checksum() |> should.equal(1928)
}

pub fn compact_blocks_test() {
  blocks
  |> day_09.compact_blocks()
  |> day_09.blocks_to_string()
  |> should.equal(compacted_blocks |> day_09.blocks_to_string())
}

pub fn compact_disk_test() {
  disk
  |> day_09.compact_disk()
  |> should.equal(compacted_disk)
}

pub fn insert_block_test() {
  // 00...111....
  [Block(Some(0), 2), Block(None, 3), Block(Some(1), 3), Block(None, 4)]
  // 99
  |> day_09.insert_block(#(9, 2))
  // 0099.111....
  |> should.equal(
    Ok([
      Block(Some(0), 2),
      Block(Some(9), 2),
      Block(None, 1),
      Block(Some(1), 3),
      Block(None, 4),
    ]),
  )

  // 00.111....
  [Block(Some(0), 2), Block(None, 1), Block(Some(1), 3), Block(None, 4)]
  // 99
  |> day_09.insert_block(#(9, 2))
  // 00.11199..
  |> should.equal(
    Ok([
      Block(Some(0), 2),
      Block(None, 1),
      Block(Some(1), 3),
      Block(Some(9), 2),
      Block(None, 2),
    ]),
  )

  // 00.111
  [Block(Some(0), 2), Block(None, 1), Block(Some(1), 3)]
  // 99
  |> day_09.insert_block(#(9, 2))
  // 99 does not fit into 00.111
  |> should.be_error()
}

pub fn parse_test() {
  "2333133121414131402"
  |> string.to_graphemes()
  |> day_09.parse_disk()
  |> should.equal(disk)
}
