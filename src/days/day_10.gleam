// IMPORTS --------------------------------------------------------------------

import gleam/list
import gleam/string
import gleam/int
import gleam/io
import gleam/map.{Map}
import gleam/result

// TYPES ----------------------------------------------------------------------

type Op {
  Add(Int)
  Noop
}

type Program {
  Program(register: Int, operations: Map(Int, Int))
}

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let operations =
    input
    |> parse_input()

  let total_cycles = get_total_cyclces(operations)

  let program =
    operations
    |> construct_program(1, Program(register: 1, operations: map.new()))

  let #(_, signals) =
    total_cycles
    |> list.range(from: 1, to: _)
    |> list.map_fold(
      program,
      fn(program, cycle) {
        let #(program, #(_register, signal_strength)) =
          run_program_step(cycle, program)

        #(program, signal_strength)
      },
    )

  signals
  |> int.sum()
}

pub fn pt_2(input: String) {
  let operations =
    input
    |> parse_input()

  let total_cycles = get_total_cyclces(operations)

  let program =
    operations
    |> construct_program(1, Program(register: 1, operations: map.new()))

  let #(_, registers) =
    total_cycles
    |> list.range(from: 1, to: _)
    |> list.map_fold(
      program,
      fn(program, cycle) {
        let #(program, #(register, _signal_strength)) =
          run_program_step(cycle, program)

        #(program, register)
      },
    )

  registers
  |> list.sized_chunk(40)
  |> list.map(fn(registers) {
    registers
    |> list.fold(
      #(1, []),
      fn(acc, register) {
        let #(index, line) = acc
        let register = register
        let line = case
          register == index || register - 1 == index || register + 1 == index
        {
          True -> ["#", ..line]
          False -> [".", ..line]
        }

        #(index + 1, line)
      },
    )
  })
  |> list.map(fn(f) {
    let #(_, line) = f
    line
    |> list.reverse()
    |> string.join("")
    |> io.debug
  })

  -1
}

// HELPERS --------------------------------------------------------------------

fn construct_program(
  operations: List(Op),
  cycle: Int,
  program: Program,
) -> Program {
  case operations {
    [] -> program
    [op, ..tl] ->
      case op {
        Noop -> construct_program(tl, cycle + 1, program)
        Add(v) -> {
          let new_program_map = map.insert(program.operations, cycle + 1, v)
          let new_program = Program(register: 1, operations: new_program_map)
          construct_program(tl, cycle + 2, new_program)
        }
      }
  }
}

fn run_program_step(cycle: Int, program: Program) -> #(Program, #(Int, Int)) {
  let Program(register, operations) = program

  let signal_strength = case cycle == 20 || { cycle - 20 } % 40 == 0 {
    True -> register * cycle
    False -> 0
  }

  let new_register =
    map.get(operations, cycle)
    |> result.unwrap(0)
    |> int.add(register)

  let updated_program = Program(register: new_register, operations: operations)

  #(updated_program, #(new_register, signal_strength))
}

fn get_total_cyclces(ops: List(Op)) -> Int {
  ops
  |> list.map(fn(op) {
    case op {
      Noop -> 1
      _ -> 2
    }
  })
  |> int.sum()
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(Op) {
  input
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.map(fn(line) {
    case line {
      ["noop"] -> Noop
      ["addx", v] -> {
        assert Ok(i) = int.parse(v)
        Add(i)
      }
    }
  })
}
