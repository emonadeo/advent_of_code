import common
import day_17
import gleeunit/should

pub fn execute_test() {
  [5, 0, 5, 1, 5, 4]
  |> day_17.execute(10, 0, 0)
  |> common.assert_unwrap()
  |> should.equal([0, 1, 2])

  [0, 1, 5, 4, 3, 0]
  |> day_17.execute(729, 0, 0)
  |> common.assert_unwrap()
  |> should.equal([4, 6, 3, 5, 6, 3, 5, 2, 1, 0])

  [0, 1, 5, 4, 3, 0]
  |> day_17.execute(2024, 0, 0)
  |> common.assert_unwrap()
  |> should.equal([4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0])
}

pub fn bst_test() {
  day_17.new_state(0, 0, 9)
  |> day_17.execute_instruction(day_17.Bst, 6)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 1, 9, 2, []))
}

pub fn bxl_test() {
  day_17.new_state(0, 29, 0)
  |> day_17.execute_instruction(day_17.Bxl, 5)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 24, 0, 2, []))

  day_17.new_state(0, 29, 0)
  |> day_17.execute_instruction(day_17.Bxl, 6)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 27, 0, 2, []))

  day_17.new_state(0, 29, 0)
  |> day_17.execute_instruction(day_17.Bxl, 7)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 26, 0, 2, []))

  day_17.new_state(0, 29, 0)
  |> day_17.execute_instruction(day_17.Bxl, 7)
  |> common.assert_unwrap()
  |> day_17.execute_instruction(day_17.Bxl, 5)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 31, 0, 4, []))
}

pub fn bxc_test() {
  day_17.new_state(0, 2024, 43_690)
  |> day_17.execute_instruction(day_17.Bxc, 0)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 44_354, 43_690, 2, []))
}

pub fn adv_test() {
  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Adv, 0)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 0, 0, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Adv, 1)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(34, 0, 0, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Adv, 2)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(17, 0, 0, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Adv, 3)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(8, 0, 0, 2, []))

  day_17.new_state(10, 0, 0)
  |> day_17.execute_instruction(day_17.Adv, 4)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(0, 0, 0, 2, []))

  day_17.new_state(69, 2, 0)
  |> day_17.execute_instruction(day_17.Adv, 5)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(17, 2, 0, 2, []))

  day_17.new_state(69, 0, 2)
  |> day_17.execute_instruction(day_17.Adv, 6)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(17, 0, 2, 2, []))
}

pub fn bdv_test() {
  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Bdv, 0)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 69, 0, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Bdv, 1)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 34, 0, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Bdv, 2)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 17, 0, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Bdv, 3)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 8, 0, 2, []))

  day_17.new_state(10, 0, 0)
  |> day_17.execute_instruction(day_17.Bdv, 4)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(10, 0, 0, 2, []))

  day_17.new_state(69, 2, 0)
  |> day_17.execute_instruction(day_17.Bdv, 5)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 17, 0, 2, []))

  day_17.new_state(69, 0, 2)
  |> day_17.execute_instruction(day_17.Bdv, 6)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 17, 2, 2, []))
}

pub fn cdv_test() {
  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Cdv, 0)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 0, 69, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Cdv, 1)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 0, 34, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Cdv, 2)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 0, 17, 2, []))

  day_17.new_state(69, 0, 0)
  |> day_17.execute_instruction(day_17.Cdv, 3)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 0, 8, 2, []))

  day_17.new_state(10, 0, 0)
  |> day_17.execute_instruction(day_17.Cdv, 4)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(10, 0, 0, 2, []))

  day_17.new_state(69, 2, 0)
  |> day_17.execute_instruction(day_17.Cdv, 5)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 2, 17, 2, []))

  day_17.new_state(69, 0, 2)
  |> day_17.execute_instruction(day_17.Cdv, 6)
  |> common.assert_unwrap()
  |> should.equal(day_17.State(69, 0, 17, 2, []))
}
