// IMPORTS --------------------------------------------------------------------

import gleam/list
import gleam/int
import gleam/string
import gleam/float
import gleam/set

// TYPES ----------------------------------------------------------------------

type Coordinate =
  #(Int, Int)

type Direction {
  Up
  Down
  Left
  Right
  UpRight
  UpLeft
  DownRight
  DownLeft
  NoMove
}

type Move =
  #(Direction, Int)

const rope_init = #(
  #(0, 0),
  [
    #(0, 0),
    #(0, 0),
    #(0, 0),
    #(0, 0),
    #(0, 0),
    #(0, 0),
    #(0, 0),
    #(0, 0),
    #(0, 0),
  ],
)

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) {
  input
  |> parse_input()
  |> process_moves(#(#(0, 0), [#(0, 0)]), [])
  |> list.map(fn(rope) {
    let #(_, tail) = rope
    assert Ok(end_of_tail) = list.at(tail, list.length(tail) - 1)
    end_of_tail
  })
  |> set.from_list()
  |> set.size()
}

pub fn pt_2(input: String) {
  input
  |> parse_input()
  |> process_moves(rope_init, [])
  |> list.map(fn(rope) {
    let #(_, tail) = rope
    assert Ok(end_of_tail) = list.at(tail, list.length(tail) - 1)
    end_of_tail
  })
  |> set.from_list()
  |> set.size()
}

// HELPERS --------------------------------------------------------------------

fn process_moves(
  moves: List(Move),
  rope: #(Coordinate, List(Coordinate)),
  all_tail_coordinates: List(#(Coordinate, List(Coordinate))),
) -> List(#(Coordinate, List(Coordinate))) {
  case moves {
    [] -> [rope_init, ..all_tail_coordinates]
    [move, ..moves] -> {
      let next_coordinates = get_next_coordinates(move, rope)
      let all_tail_coordinates = [next_coordinates, ..all_tail_coordinates]
      process_moves(moves, next_coordinates, all_tail_coordinates)
    }
  }
}

fn get_next_coordinates(
  move: Move,
  head_tail: #(Coordinate, List(Coordinate)),
) -> #(Coordinate, List(Coordinate)) {
  let #(head_coord, tail) = head_tail

  let new_head_coordinate = get_next_head_coordinate(move, head_coord)

  let #(_, new_tail) =
    tail
    |> list.map_fold(
      new_head_coordinate,
      fn(head, tail_coordinate) {
        let new_tail_coordinate =
          get_next_tail_coordinate(head, tail_coordinate)

        #(new_tail_coordinate, new_tail_coordinate)
      },
    )

  #(new_head_coordinate, new_tail)
}

fn get_next_head_coordinate(move: Move, current_head: Coordinate) -> Coordinate {
  let #(head_x, head_y) = current_head

  case move {
    #(Up, m) -> #(head_x, head_y + m)
    #(Down, m) -> #(head_x, head_y - m)
    #(Left, m) -> #(head_x - m, head_y)
    #(Right, m) -> #(head_x + m, head_y)
  }
}

fn get_next_tail_coordinate(
  head_location: Coordinate,
  tail_location: Coordinate,
) -> Coordinate {
  let #(tail_x, tail_y) = tail_location

  let direction = get_direction(head: head_location, tail: tail_location)

  let new_coordinate = case distance(head_location, tail_location) >. 1.0 {
    True ->
      case direction {
        Up -> #(tail_x, tail_y + 1)
        UpLeft -> #(tail_x - 1, tail_y + 1)
        UpRight -> #(tail_x + 1, tail_y + 1)
        Down -> #(tail_x, tail_y - 1)
        DownRight -> #(tail_x + 1, tail_y - 1)
        DownLeft -> #(tail_x - 1, tail_y - 1)
        Left -> #(tail_x - 1, tail_y)
        Right -> #(tail_x + 1, tail_y)
        NoMove -> tail_location
      }
    False -> tail_location
  }

  new_coordinate
}

fn get_direction(
  head new_coordinate: Coordinate,
  tail old_coordinate: Coordinate,
) -> Direction {
  case True {
    _ if new_coordinate.0 > old_coordinate.0 && new_coordinate.1 > old_coordinate.1 ->
      UpRight
    _ if new_coordinate.0 < old_coordinate.0 && new_coordinate.1 > old_coordinate.1 ->
      UpLeft
    _ if new_coordinate.0 > old_coordinate.0 && new_coordinate.1 < old_coordinate.1 ->
      DownRight
    _ if new_coordinate.0 < old_coordinate.0 && new_coordinate.1 < old_coordinate.1 ->
      DownLeft
    _ if new_coordinate.0 == old_coordinate.0 && new_coordinate.1 > old_coordinate.1 ->
      Up
    _ if new_coordinate.0 == old_coordinate.0 && new_coordinate.1 < old_coordinate.1 ->
      Down
    _ if new_coordinate.0 > old_coordinate.0 && new_coordinate.1 == old_coordinate.1 ->
      Right
    _ if new_coordinate.0 < old_coordinate.0 && new_coordinate.1 == old_coordinate.1 ->
      Left
    _ -> NoMove
  }
}

fn distance(head_coordinate: Coordinate, tail_coordinate: Coordinate) -> Float {
  let #(head_x, head_y) = head_coordinate
  let #(tail_x, tail_y) = tail_coordinate

  let same_coordinate = head_x == head_y && tail_x == tail_y

  case same_coordinate {
    True -> 0.0
    False -> {
      assert Ok(x_power) = float.power(int.to_float(tail_x - head_x), 2.0)
      assert Ok(y_power) = float.power(int.to_float(tail_y - head_y), 2.0)
      assert Ok(distance) = float.square_root(x_power +. y_power)
      float.floor(distance)
    }
  }
}

// PARSING --------------------------------------------------------------------

fn duplicate_moves(move: Move, moves: List(Move)) -> List(Move) {
  case move {
    #(_, 1) -> [move, ..moves]
    #(d, m) -> duplicate_moves(#(d, m - 1), [#(d, 1), ..moves])
  }
}

fn parse_input(input: String) -> List(Move) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let [direction, moves] = string.split(line, " ")
    let direction = case direction {
      "U" -> Up
      "D" -> Down
      "L" -> Left
      "R" -> Right
    }
    assert Ok(moves_int) = int.parse(moves)
    #(direction, moves_int)
  })
  |> list.flat_map(duplicate_moves(_, []))
}
