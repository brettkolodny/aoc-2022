// IMPORTS --------------------------------------------------------------------

import gleam/list
import gleam/string
import gleam/regex
import gleam/option
import gleam/io

// TYPES ----------------------------------------------------------------------

type CrateMover {
  NineThousand
  NineThousandOne
}

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) -> Int {
  let #(boxes, moves) = parse_input(input)

  let #(new_boxes, _) =
    moves
    |> list.map_fold(
      boxes,
      fn(acc, move) {
        let boxes = move_boxes(acc, move, NineThousand)
        #(boxes, move)
      },
    )

  new_boxes
  |> list.flat_map(list.take(_, 1))
  |> string.join("")
  |> io.debug()
  0
}

pub fn pt_2(input: String) -> Int {
  let #(boxes, moves) = parse_input(input)

  let #(new_boxes, _) =
    moves
    |> list.map_fold(
      boxes,
      fn(acc, move) {
        let boxes = move_boxes(acc, move, NineThousandOne)
        #(boxes, move)
      },
    )

  new_boxes
  |> list.flat_map(list.take(_, 1))
  |> string.join("")
  |> io.debug()
  0
}

// HELPERS --------------------------------------------------------------------

fn move_boxes(
  boxes: List(List(String)),
  move: List(Int),
  crane_type: CrateMover,
) -> List(List(String)) {
  let [num_boxes, from, to] = move

  assert Ok(col_from) = list.at(boxes, from - 1)
  let boxes_to_move = case crane_type {
    NineThousand ->
      list.take(col_from, num_boxes)
      |> list.reverse()
    NineThousandOne -> list.take(col_from, num_boxes)
  }

  boxes
  |> list.index_map(fn(i, x) {
    case i + 1 {
      col_index if col_index == to -> list.append(boxes_to_move, x)
      col_index if col_index == from -> {
        let #(_, rest) = list.split(x, list.length(boxes_to_move))
        rest
      }
      _ -> x
    }
  })
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> #(List(List(String)), List(List(Int))) {
  let [boxes_input, moves_input] = string.split(input, on: "\n\n")

  let boxes = parse_boxes(boxes_input)
  let moves = parse_moves(moves_input)

  #(boxes, moves)
}

fn parse_boxes(input: String) -> List(List(String)) {
  input
  |> string.split(on: "\n")
  |> fn(in) {
    let length = list.length(in)
    list.take(in, length - 1)
  }
  |> list.map(with: fn(line) {
    string.split(line, on: "")
    |> parse_boxes_line([])
  })
  |> rotate_boxes()
}

fn parse_boxes_line(line: List(String), acc: List(String)) {
  case line {
    [] -> list.reverse(acc)
    ["[", b, "]", " ", ..tl] -> parse_boxes_line(tl, [b, ..acc])
    [" ", " ", " ", " ", ..tl] -> parse_boxes_line(tl, [" ", ..acc])
    [" ", " ", " "] -> parse_boxes_line([], [" ", ..acc])
    ["[", b, "]"] -> parse_boxes_line([], [b, ..acc])
  }
}

fn rotate_boxes(boxes: List(List(String))) -> List(List(String)) {
  let num_stacks = list.length(boxes)

  boxes
  |> list.interleave()
  |> list.sized_chunk(into: num_stacks)
  |> list.map(fn(col) { list.filter(col, fn(i) { i != " " }) })
}

fn parse_moves(moves_input: String) -> List(List(Int)) {
  assert Ok(r) = regex.from_string("move (\\d+) from (\\d+) to (\\d+)")

  moves_input
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    assert Ok(match) =
      regex.scan(r, line)
      |> list.at(0)

    list.map(
      match.submatches,
      fn(match) {
        assert Ok(m) = option.to_result(match, Nil)
        unsafe_string_to_int(m)
      },
    )
  })
}

// EXTERNAL -------------------------------------------------------------------

external fn unsafe_string_to_int(string: String) -> Int =
  "erlang" "binary_to_integer"
