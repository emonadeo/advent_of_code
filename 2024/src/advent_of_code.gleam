import day_01
import file_streams/file_stream
import gleam/int
import gleam/io
import gleam/yielder

pub fn main() {
  let assert Ok(stream) = file_stream.open_read("../inputs/2024/day_01.txt")
  let lines = stream |> stream_to_yielder
  lines |> day_01.part_01 |> int.to_string |> io.println
}

fn stream_to_yielder(stream: file_stream.FileStream) -> yielder.Yielder(String) {
  case stream |> file_stream.read_line {
    Ok(line) -> {
      use <- yielder.yield(line)
      stream_to_yielder(stream)
    }
    Error(_) -> yielder.empty()
  }
}
