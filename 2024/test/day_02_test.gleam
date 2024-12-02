import day_02
import gleeunit/should

pub fn is_safe_test() {
  day_02.is_safe([7, 6, 4, 2, 1]) |> should.be_true
  day_02.is_safe([1, 2, 7, 8, 9]) |> should.be_false
  day_02.is_safe([9, 7, 6, 2, 1]) |> should.be_false
  day_02.is_safe([1, 3, 2, 4, 5]) |> should.be_false
  day_02.is_safe([8, 6, 4, 4, 1]) |> should.be_false
  day_02.is_safe([1, 3, 6, 7, 9]) |> should.be_true
}

pub fn is_mostly_safe_test() {
  day_02.is_mostly_safe([7, 6, 4, 2, 1]) |> should.be_true
  day_02.is_mostly_safe([1, 2, 7, 8, 9]) |> should.be_false
  day_02.is_mostly_safe([9, 7, 6, 2, 1]) |> should.be_false
  day_02.is_mostly_safe([1, 3, 2, 4, 5]) |> should.be_true
  day_02.is_mostly_safe([8, 6, 4, 4, 1]) |> should.be_true
  day_02.is_mostly_safe([1, 3, 6, 7, 9]) |> should.be_true
  day_02.is_mostly_safe([2, 1, 2, 3, 4]) |> should.be_true
}
