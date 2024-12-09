import common
import day_09
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set
import gleam/string
import gleam/yielder
import gleeunit/should

const disk: day_09.Disk = [
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

const compacted_disk: day_09.CompactedDisk = [
  0, 0, 9, 9, 8, 1, 1, 1, 8, 8, 8, 2, 7, 7, 7, 3, 3, 3, 6, 4, 4, 6, 5, 5, 5, 5,
  6, 6,
]

pub fn parse_test() {
  "2333133121414131402"
  |> string.to_graphemes()
  |> day_09.parse_disk()
  |> should.equal(disk)
}

pub fn compact_disk_test() {
  disk
  |> day_09.compact_disk()
  |> should.equal(compacted_disk)
}

pub fn checksum_test() {
  compacted_disk |> day_09.checksum() |> should.equal(1928)
}
