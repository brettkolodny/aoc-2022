import gleam/list
import gleam/string
import gleam/int
import gleam/io

type Monkey {
  Monkey(
    items: List(Int),
    inspect: fn(Int) -> Int,
    decision: fn(Monkey, List(Monkey)) -> List(Monkey),
    worry_reduction: fn(Int) -> Int,
    num_inspections: Int,
  )
}

pub fn pt_1(input: String) {
  let monkeys =
    input
    |> parse_input()

  list.range(from: 1, to: 20)
  |> list.fold(
    monkeys,
    fn(monkeys, _) {
      list.index_fold(
        monkeys,
        monkeys,
        fn(monkeys_2, _, i) { monkey_toss_items(i, monkeys_2) },
      )
    },
  )
  |> list.map(fn(monkey) { monkey.num_inspections })
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(2)
  |> int.product()
}

pub fn pt_2(input: String) {
  let monkeys =
    input
    |> parse_input()

  // |> list.map(fn(monkey) { Monkey(..monkey, worry_reduction: fn(a) { a }) }) 
  list.range(from: 1, to: 10000)
  |> list.fold(
    monkeys,
    fn(monkeys, _) {
      list.index_fold(
        monkeys,
        monkeys,
        fn(monkeys_2, _, i) { monkey_toss_items(i, monkeys_2) },
      )
    },
  )
  |> list.map(fn(monkey) { monkey.num_inspections })
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(2)
  |> int.product()
}

fn monkey_toss_items(monkey_index: Int, monkeys: List(Monkey)) -> List(Monkey) {
  assert Ok(monkey) = list.at(monkeys, monkey_index)

  case monkey.items {
    [] -> monkeys
    _ -> {
      let #(monkeys, _) =
        list.range(from: 1, to: list.length(monkey.items))
        |> list.map_fold(
          monkeys,
          fn(monkeys, _) {
            assert Ok(new_monkey) = list.at(monkeys, monkey_index)
            #(new_monkey.decision(new_monkey, monkeys), 0)
          },
        )
      monkeys
    }
  }
}

fn parse_monkey_items(input: String) -> List(Int) {
  let [_, items_input] = string.split(input, ":")

  items_input
  |> string.split(",")
  |> list.map(fn(item) {
    assert Ok(int) =
      item
      |> string.trim()
      |> int.parse()
    int
  })
}

fn parse_monkey_inspect(input: String) -> fn(Int) -> Int {
  let [_, inspect] = string.split(input, ":")

  let [_, _, _, operator, amount] =
    inspect
    |> string.trim()
    |> string.split(" ")

  let operator_fn = case operator {
    "+" -> fn(old, new) { old + new }
    "*" -> fn(old, new) { old * new }
  }

  let inspect_fn = case int.parse(amount) {
    Ok(a) -> fn(old) { operator_fn(old, a) }
    _ -> fn(old) { operator_fn(old, old) }
  }

  inspect_fn
}

fn parse_monkey_decision(
  input: List(String),
  monkey_index: Int,
) -> fn(Monkey, List(Monkey)) -> List(Monkey) {
  let [test, true_branch, false_branch] = input

  let [_, _, _, val] =
    test
    |> string.trim()
    |> string.split(" ")
  assert Ok(v) = int.parse(val)

  let [_, _, _, _, _, true_monkey] =
    true_branch
    |> string.trim()
    |> string.split(" ")

  assert Ok(true_monkey_index) = int.parse(true_monkey)

  let [_, _, _, _, _, false_monkey] =
    false_branch
    |> string.trim()
    |> string.split(" ")

  assert Ok(false_monkey_index) = int.parse(false_monkey)

  fn(monkey: Monkey, monkeys: List(Monkey)) {
    case list.at(monkey.items, 0) {
      Ok(item) -> {
        let worry_level =
          monkey.inspect(item)
          |> monkey.worry_reduction()
        case worry_level % v == 0 {
          True -> {
            assert Ok(monkey_to) = list.at(monkeys, true_monkey_index)
            assert Ok(monkey_from_items) = list.rest(monkey.items)
            let monkey_to_items = list.append(monkey_to.items, [worry_level])
            monkeys
            |> list.index_map(fn(index, monkey) {
              case index {
                _ if index == monkey_index ->
                  Monkey(
                    ..monkey,
                    items: monkey_from_items,
                    num_inspections: monkey.num_inspections + 1,
                  )
                _ if index == true_monkey_index ->
                  Monkey(..monkey_to, items: monkey_to_items)
                _ -> monkey
              }
            })
          }
          False -> {
            assert Ok(monkey_to) = list.at(monkeys, false_monkey_index)
            assert Ok(monkey_from_items) = list.rest(monkey.items)
            let monkey_to_items = list.append(monkey_to.items, [worry_level])
            monkeys
            |> list.index_map(fn(index, monkey) {
              case index {
                _ if index == monkey_index ->
                  Monkey(
                    ..monkey,
                    items: monkey_from_items,
                    num_inspections: monkey.num_inspections + 1,
                  )
                _ if index == false_monkey_index ->
                  Monkey(..monkey_to, items: monkey_to_items)
                _ -> monkey
              }
            })
          }
        }
      }
      _ -> monkeys
    }
  }
}

fn parse_monkey(input: String, monkey_index: Int) -> Monkey {
  let [_, items, inspect, ..decision] =
    input
    |> string.split("\n")

  let start_items = parse_monkey_items(items)
  let inspect_fn = parse_monkey_inspect(inspect)
  let decision_fn = parse_monkey_decision(decision, monkey_index)

  Monkey(
    items: start_items,
    inspect: inspect_fn,
    decision: decision_fn,
    num_inspections: 0,
    worry_reduction: fn(a) { a / 3 },
  )
}

fn parse_input(input: String) -> List(Monkey) {
  input
  |> string.split("\n\n")
  |> list.index_map(fn(i, x) { parse_monkey(x, i) })
}
