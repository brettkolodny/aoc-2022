import gleeunit/should
import days/day_3.{pt_1, pt_2}

const input = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(157)
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal(70)
}
