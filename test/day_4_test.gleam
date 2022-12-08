import gleeunit/should
import days/day_4.{pt_1, pt_2}

const input = "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(2)
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal(4)
}
