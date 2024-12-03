import day_03
import gleeunit/should

pub fn evaluate_test() {
  day_03.evaluate(
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
  )
  |> should.equal(161)
}

pub fn evaluate_with_do_test() {
  day_03.evaluate_with_do(
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
    True,
  )
  |> should.equal(48)
}

pub fn extract_int_test() {
  day_03.extract_int("69420hello")
  |> should.equal(Ok(#(69_420, "hello")))
  day_03.extract_int("69hello420") |> should.equal(Ok(#(69, "hello420")))
  day_03.extract_int("hello69420") |> should.equal(Error(Nil))
}

pub fn extract_digits_test() {
  day_03.extract_digits("69420hello")
  |> should.equal(Ok(#([6, 9, 4, 2, 0], "hello")))
  day_03.extract_digits("69hello420") |> should.equal(Ok(#([6, 9], "hello420")))
  day_03.extract_digits("hello69420") |> should.equal(Error(Nil))
}
