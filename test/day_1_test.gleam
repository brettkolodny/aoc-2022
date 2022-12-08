import gleeunit/should
import days/day_1.{pt_1, pt_2}

const input = "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(24000)
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal(45000)
}
