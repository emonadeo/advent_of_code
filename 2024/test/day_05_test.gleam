import day_05
import gleam/dict
import gleam/io
import gleam/yielder
import gleeunit/should

pub fn part_01_test() {
  [
    "47|53", "97|13", "97|61", "97|47", "75|29", "61|13", "75|53", "29|13",
    "97|29", "53|29", "61|53", "97|53", "61|29", "47|13", "75|47", "97|75",
    "47|61", "75|61", "47|29", "75|13", "53|13", "", "75,47,61,53,29",
    "97,61,53,29,13", "75,29,13", "75,97,47,61,53", "61,13,29", "97,13,75,29,47",
  ]
  |> yielder.from_list()
  |> day_05.part_01()
  |> should.equal(143)
}

pub fn add_rule_test() {
  day_05.add_rule(dict.new(), 69, 420) |> io.debug()
}
