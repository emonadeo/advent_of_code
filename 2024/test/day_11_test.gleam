import day_11
import gleeunit/should

pub fn blink_test() {
  let blinked = [125, 17] |> day_11.blink()
  should.equal(blinked, [253_000, 1, 7])
  let blinked = blinked |> day_11.blink()
  should.equal(blinked, [253, 0, 2024, 14_168])
  let blinked = blinked |> day_11.blink()
  should.equal(blinked, [512_072, 1, 20, 24, 28_676_032])
  let blinked = blinked |> day_11.blink()
  should.equal(blinked, [512, 72, 2024, 2, 0, 2, 4, 2867, 6032])
  let blinked = blinked |> day_11.blink()
  should.equal(blinked, [
    1_036_288, 7, 2, 20, 24, 4048, 1, 4048, 8096, 28, 67, 60, 32,
  ])
  let blinked = blinked |> day_11.blink()
  should.equal(blinked, [
    2_097_446_912, 14_168, 4048, 2, 0, 2, 4, 40, 48, 2024, 40, 48, 80, 96, 2, 8,
    6, 7, 6, 0, 3, 2,
  ])
}
