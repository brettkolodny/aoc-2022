import gleeunit/should
import days/day_6.{pt_1, pt_2}

const input = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(7)
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal(19)
}
