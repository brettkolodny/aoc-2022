import gleeunit/should
import days/day_5.{pt_1, pt_2}

const input = "    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"

pub fn pt_1_test() {
  input
  |> pt_1()
  |> should.equal("CMZ")
}

pub fn pt_2_test() {
  input
  |> pt_2()
  |> should.equal("MCD")
}
