import gleeunit/should
import days/day_9.{pt_1, pt_2}

const input = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"

const input2 = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal(13)
}

pub fn pt_2_2_test() {
  input2
  |> pt_2()
  |> should.equal(36)
}
