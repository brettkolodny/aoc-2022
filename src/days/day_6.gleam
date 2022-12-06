// IMPORTS --------------------------------------------------------------------

import gleam/string
import gleam/list
import gleam/set

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) -> Int {
  input
  |> parse_input()
  |> find_start_index(4, 0)
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse_input()
  |> find_start_index(14, 0)
}

// HELPERS --------------------------------------------------------------------

fn find_start_index(signal: List(String), total_unique: Int, index: Int) -> Int {
  let num_unique =
    list.take(signal, total_unique)
    |> set.from_list()
    |> set.size()

  case num_unique {
    n if n == total_unique -> index + total_unique
    _ -> {
      assert Ok(rest) = list.rest(signal)
      find_start_index(rest, total_unique, index + 1)
    }
  }
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(String) {
  string.split(input, on: "")
}
