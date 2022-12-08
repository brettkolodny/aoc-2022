import gleeunit/should
import days/day_2.{pt_1, pt_2}

const input = "A Y
B X
C Z"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(15)
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal(12)
}
