import day_11
import gleeunit/should

pub fn blink_and_count_all_test() {
  [125, 17] |> day_11.blink_and_count_all(times: 1) |> should.equal(3)

  [253_000, 1, 7] |> day_11.blink_and_count_all(times: 1) |> should.equal(4)
  [125, 17] |> day_11.blink_and_count_all(times: 2) |> should.equal(4)

  [253, 0, 2024, 14_168] |> day_11.blink_and_count_all(1) |> should.equal(5)
  [125, 17] |> day_11.blink_and_count_all(times: 3) |> should.equal(5)

  [512_072, 1, 20, 24, 28_676_032]
  |> day_11.blink_and_count_all(times: 1)
  |> should.equal(9)
  [125, 17] |> day_11.blink_and_count_all(times: 4) |> should.equal(9)

  [512, 72, 2024, 2, 0, 2, 4, 2867, 6032]
  |> day_11.blink_and_count_all(times: 1)
  |> should.equal(13)
  [125, 17] |> day_11.blink_and_count_all(times: 5) |> should.equal(13)

  [1_036_288, 7, 2, 20, 24, 4048, 1, 4048, 8096, 28, 67, 60, 32]
  |> day_11.blink_and_count_all(times: 1)
  |> should.equal(22)
  [125, 17] |> day_11.blink_and_count_all(times: 6) |> should.equal(22)
}
