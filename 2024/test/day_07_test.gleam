import day_07
import gleeunit/should

pub fn concat_test() {
  1 |> day_07.concat(1) |> should.equal(11)
  15 |> day_07.concat(6) |> should.equal(156)
}

pub fn is_possible_test() {
  #(190, [10, 19]) |> day_07.is_possible() |> should.be_true()
  #(3267, [81, 40, 27]) |> day_07.is_possible() |> should.be_true()
  #(83, [17, 5]) |> day_07.is_possible() |> should.be_false()
  #(156, [15, 6]) |> day_07.is_possible() |> should.be_false()
  #(7290, [6, 8, 6, 15]) |> day_07.is_possible() |> should.be_false()
  #(161_011, [16, 10, 13]) |> day_07.is_possible() |> should.be_false()
  #(192, [17, 8, 14]) |> day_07.is_possible() |> should.be_false()
  #(21_037, [9, 7, 18, 13]) |> day_07.is_possible() |> should.be_false()
  #(292, [11, 6, 16, 20]) |> day_07.is_possible() |> should.be_true()
}

pub fn is_possible_with_concat_test() {
  #(190, [10, 19]) |> day_07.is_possible_with_concat() |> should.be_true()
  #(3267, [81, 40, 27]) |> day_07.is_possible_with_concat() |> should.be_true()
  #(83, [17, 5]) |> day_07.is_possible_with_concat() |> should.be_false()
  #(156, [15, 6]) |> day_07.is_possible_with_concat() |> should.be_true()
  #(7290, [6, 8, 6, 15]) |> day_07.is_possible_with_concat() |> should.be_true()
  #(161_011, [16, 10, 13])
  |> day_07.is_possible_with_concat()
  |> should.be_false()
  #(192, [17, 8, 14]) |> day_07.is_possible_with_concat() |> should.be_true()
  #(21_037, [9, 7, 18, 13])
  |> day_07.is_possible_with_concat()
  |> should.be_false()
  #(292, [11, 6, 16, 20])
  |> day_07.is_possible_with_concat()
  |> should.be_true()
}
