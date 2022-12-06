// IMPORTS --------------------------------------------------------------------

import gleam/list
import gleam/string
import gleam/int

// TYPES ----------------------------------------------------------------------

type RPS {
  Rock
  Paper
  Scissors
}

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) -> Int {
  input
  |> parse_input()
  |> list.map(fn(round) { list.map(round, string_to_rps) })
  |> list.map(get_round_points)
  |> int.sum()
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse_input()
  |> list.map(fn(round) {
    let [m1, m2] = round

    let oponent_move = string_to_rps(m1)

    case m2 {
      "X" -> [oponent_move, get_losing_move(oponent_move)]
      "Y" -> [oponent_move, oponent_move]
      "Z" -> [oponent_move, get_winning_move(oponent_move)]
    }
  })
  |> list.map(get_round_points)
  |> int.sum()
}

// HELPERS --------------------------------------------------------------------

fn string_to_rps(s: String) {
  case s {
    "A" | "X" -> Rock
    "B" | "Y" -> Paper
    "C" | "Z" -> Scissors
  }
}

fn get_winning_move(move: RPS) {
  case move {
    Rock -> Paper
    Paper -> Scissors
    Scissors -> Rock
  }
}

fn get_losing_move(move: RPS) {
  case move {
    Rock -> Scissors
    Paper -> Rock
    Scissors -> Paper
  }
}

fn get_match_points(move1: RPS, move2: RPS) {
  case move1 == move2 {
    True -> 3
    False ->
      case get_losing_move(move1) == move2 {
        True -> 0
        False -> 6
      }
  }
}

fn get_move_points(move: RPS) {
  case move {
    Rock -> 1
    Paper -> 2
    Scissors -> 3
  }
}

fn get_round_points(round: List(RPS)) {
  let [m1, m2] = round
  let match_points = get_match_points(m1, m2)
  let move_points = get_move_points(m2)

  match_points + move_points
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(List(String)) {
  input
  |> string.split("\n")
  |> list.map(string.split(_, " "))
}
