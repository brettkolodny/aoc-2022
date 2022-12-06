// IMPORTS --------------------------------------------------------------------

import gleam/string
import gleam/list
import gleam/int

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) -> Int {
  assert Ok(calories) =
    input
    |> parse_input()
    |> calories_in_order()
    |> list.take(1)
    |> list.at(0)

  calories
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse_input()
  |> calories_in_order()
  |> list.take(3)
  |> int.sum()
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(String) {
  input
  |> string.split("\n\n")
}

// HELPERS --------------------------------------------------------------------

fn calories_in_order(calories: List(String)) -> List(Int) {
  calories
  |> list.map(fn(l) {
    l
    |> string.split("\n")
    |> list.map(string_to_int)
    |> int.sum()
  })
  |> list.sort(fn(a, b) { int.compare(b, a) })
}

// EXTERNAL -------------------------------------------------------------------

external fn string_to_int(string: String) -> Int =
  "erlang" "binary_to_integer"
