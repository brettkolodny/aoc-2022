import gleeunit/should
import days/day_8.{pt_1, pt_2}

const input = "30373
25512
65332
33549
35390"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(21)
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal(8)
}
