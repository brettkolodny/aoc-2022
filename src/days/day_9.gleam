import gleam/list
import gleam/int
import gleam/string
import gleam/float
import gleam/io
import gleam/set.{Set}

type Coordinate =
  #(Int, Int)

type Direction {
  Up
  Down
  Left
  Right
  NoMove
}

type Move =
  #(Direction, Int)

const tail_init = #(
  #(0, 0),
  #(0, 0),
  #(0, 0),
  #(0, 0),
  #(0, 0),
  #(0, 0),
  #(0, 0),
  #(0, 0),
  #(0, 0),
)

pub fn pt_1(input: String) {
  input
  |> parse_input()
  |> process_moves(#(#(0, 0), #(0, 0)), set.new())
  |> set.size()
}

pub fn pt_2(input: String) {
  input
  |> parse_input()
  |> process_moves(#(#(0, 0), #(0, 0)), set.new())
  |> set.size()
}

fn process_moves(
  moves: List(Move),
  current_coordinates: #(Coordinate, Coordinate),
  all_tail_coordinates: Set(Coordinate),
) -> Set(Coordinate) {
  case moves {
    [] -> set.insert(all_tail_coordinates, #(0, 0))
    [move, ..moves] -> {
      let next_coordinates = get_next_coordinates(move, current_coordinates)
      let all_tail_coordinates =
        set.insert(all_tail_coordinates, next_coordinates.1)
      process_moves(moves, next_coordinates, all_tail_coordinates)
    }
  }
}

fn get_all_new_coordinates(
  old_coordinates: List(Coordinate),
  new_coordinates: List(Coordinate),
  move: Move,
) -> List(Coordinate) {
  case old_coordinates {
    [] -> new_coordinates
    [tail] -> [tail, ..new_coordinates]
    [head, tail] -> {
      let #(new_tail_coordinate, _) =
        get_next_tail_coordinate_and_direction(head, tail, move.0)
      [new_tail_coordinate, ..new_coordinates]
    }
    [head, tail, ..rest] -> {
      let #(new_tail_coordinate, direction) =
        get_next_tail_coordinate_and_direction(head, tail, move.0)
      [
        new_tail_coordinate,
        ..get_all_new_coordinates(
          [tail, ..rest],
          new_coordinates,
          #(direction, 1),
        )
      ]
    }
  }
}

fn get_next_coordinates(
  move: Move,
  head_tail: #(Coordinate, Coordinate),
) -> #(Coordinate, Coordinate) {
  let #(head_coord, tail_coord) = head_tail

  let #(new_head_coordinate, direction) =
    get_next_head_coordinate_and_direction(move, head_coord)
  let #(new_tail_coordinate, _) =
    get_next_tail_coordinate_and_direction(
      new_head_coordinate,
      tail_coord,
      direction,
    )

  #(new_head_coordinate, new_tail_coordinate)
}

fn get_next_head_coordinate_and_direction(
  move: Move,
  current_head: Coordinate,
) -> #(Coordinate, Direction) {
  let #(head_x, head_y) = current_head

  case move {
    #(Up, m) -> #(#(head_x, head_y + m), Up)
    #(Down, m) -> #(#(head_x, head_y - m), Down)
    #(Left, m) -> #(#(head_x - m, head_y), Left)
    #(Right, m) -> #(#(head_x + m, head_y), Right)
  }
}

fn get_next_tail_coordinate_and_direction(
  head_location: Coordinate,
  tail_location: Coordinate,
  direction: Direction,
) -> #(Coordinate, Direction) {
  let #(head_x, head_y) = head_location

  let new_coordinate = case distance(head_location, tail_location) >. 1.0 {
    True ->
      case direction {
        Up -> #(head_x, head_y - 1)
        Down -> #(head_x, head_y + 1)
        Left -> #(head_x + 1, head_y)
        Right -> #(head_x - 1, head_y)
        NoMove -> tail_location
      }
    False -> tail_location
  }

  let direction = get_direction(from: tail_location, to: new_coordinate)
  #(new_coordinate, direction)
}

fn get_direction(
  from old_coordinate: Coordinate,
  to new_coordinate: Coordinate,
) -> Direction {
  case new_coordinate, old_coordinate {
    _, _ if new_coordinate.1 > old_coordinate.1 -> Up
    _, _ if new_coordinate.1 < old_coordinate.1 -> Down
    _, _ if new_coordinate.0 > old_coordinate.0 -> Right
    _, _ if new_coordinate.0 < old_coordinate.0 -> Left
    _, _ -> NoMove
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
