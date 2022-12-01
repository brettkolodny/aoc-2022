import gleam/string
import gleam/list
import gleam/int

pub fn pt_1(input: String) -> Int {
  assert Ok(calories) =
    calories_in_order(input)
    |> list.take(1)
    |> list.at(0)

  calories
}

pub fn pt_2(input: String) -> Int {
  calories_in_order(input)
  |> list.take(3)
  |> int.sum()
}

fn calories_in_order(input: String) -> List(Int) {
  input
  |> string.split("\n\n")
  |> list.map(fn(l) {
    l
    |> string.split("\n")
    |> list.map(string_to_int)
    |> int.sum()
  })
  |> list.sort(fn(a, b) { int.compare(b, a) })
}

external fn string_to_int(string: String) -> Int =
  "erlang" "binary_to_integer"
