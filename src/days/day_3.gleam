// IMPORTS --------------------------------------------------------------------

import gleam/list
import gleam/string
import gleam/int
import gleam/map
import gleam/set
import gleam/option.{Some}

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) -> Int {
  input
  |> parse_input()
  |> list.map(fn(line) {
    line
    |> string.split("")
    |> split_list_in_half()
    |> list.flat_map(fn(backpack) {
      backpack
      |> set.from_list()
      |> set.to_list()
    })
    |> find_overlap(2)
  })
  |> int.sum()
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse_input()
  |> get_groups()
  |> list.map(fn(group) {
    group
    |> list.flat_map(fn(e) {
      e
      |> string.split("")
      |> set.from_list()
      |> set.to_list()
    })
    |> find_overlap(3)
  })
  |> int.sum()
}

// HELPERS --------------------------------------------------------------------

fn split_list_in_half(l: List(a)) -> List(List(a)) {
  assert Ok(middle_index) =
    list.length(l)
    |> int.divide(2)

  let #(first, second) = list.split(l, middle_index)
  [first, second]
}

fn find_overlap(bags: List(String), num: Int) {
  bags
  |> list.fold(
    map.new(),
    fn(acc, char) {
      map.update(
        acc,
        char,
        fn(value) {
          case value {
            Some(v) -> v + 1
            _ -> 1
          }
        },
      )
    },
  )
  |> map.to_list()
  |> list.fold(
    0,
    fn(acc, elem) {
      case acc != 0 {
        True -> acc
        _ -> {
          let #(key, value) = elem
          case value == num {
            True -> letter_to_score(key)
            False -> 0
          }
        }
      }
    },
  )
}

fn get_groups(bags: List(String)) -> List(List(String)) {
  bags
  |> list.fold(
    [],
    fn(acc, elem) {
      case acc {
        [] -> [[elem]]
        [hd, ..tl] ->
          case list.length(hd) {
            3 -> [[elem], hd, ..tl]
            _ -> [[elem, ..hd], ..tl]
          }
      }
    },
  )
}

fn letter_to_score(l: String) -> Int {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  let [first, _] = string.split(letters, l)
  string.length(first) + 1
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(String) {
  input
  |> string.split("\n")
}
