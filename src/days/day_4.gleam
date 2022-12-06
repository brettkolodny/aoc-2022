// IMPORTS --------------------------------------------------------------------

import gleam/int
import gleam/list
import gleam/set
import gleam/string

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) -> Int {
  input
  |> parse_input()
  |> list.map(fn(pair) {
    let [first, second] = pair

    let largest = int.max(list.length(first), list.length(second))

    let first_set = set.from_list(first)
    let second_set = set.from_list(second)

    let union = set.union(first_set, second_set)

    case set.size(union) == largest {
      True -> 1
      False -> 0
    }
  })
  |> int.sum()
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse_input()
  |> list.map(fn(pair) {
    let [first, second] = pair

    let total_length = int.add(list.length(first), list.length(second))

    let first_set = set.from_list(first)
    let second_set = set.from_list(second)

    let union = set.union(first_set, second_set)

    case set.size(union) < total_length {
      True -> 1
      False -> 0
    }
  })
  |> int.sum()
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    string.split(line, ",")
    |> list.map(fn(chores) {
      string.split(chores, "-")
      |> list.map(unsafe_string_to_int)
    })
    |> list.map(fn(r) {
      let [start, end] = r
      list.range(start, end)
    })
  })
}

external fn unsafe_string_to_int(string: String) -> Int =
  "erlang" "binary_to_integer"
