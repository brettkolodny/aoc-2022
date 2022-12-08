// IMPORTS --------------------------------------------------------------------

import gleam/string
import gleam/list
import gleam/int

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let trees =
    input
    |> parse_input()

  let trees_horizontal =
    trees
    |> list.map(fn(tree_line) {
      tree_line
      |> list.index_map(fn(i, _) { tree_visible(i, tree_line) })
    })

  let trees_vertical =
    trees
    |> rotate_trees()
    |> list.map(fn(tree_line) {
      tree_line
      |> list.index_map(fn(i, _) { tree_visible(i, tree_line) })
    })
    |> rotate_trees()
    |> rotate_trees()
    |> rotate_trees()

  list.zip(trees_horizontal, trees_vertical)
  |> list.map(fn(tree_lines) {
    let #(trees, more_trees) = tree_lines
    list.zip(trees, more_trees)
    |> list.map(fn(tree) {
      let #(visible_h, visible_y) = tree
      visible_h || visible_y
    })
  })
  |> list.flatten()
  |> list.fold(
    0,
    fn(acc, is_visible) {
      case is_visible {
        True -> acc + 1
        _ -> acc
      }
    },
  )
}

pub fn pt_2(input: String) {
  let trees =
    input
    |> parse_input()

  let trees_horizontal =
    trees
    |> list.map(fn(tree_line) {
      tree_line
      |> list.index_map(fn(i, _) { num_trees_visible(i, tree_line) })
    })

  let trees_vertical =
    trees
    |> rotate_trees()
    |> list.map(fn(tree_line) {
      tree_line
      |> list.index_map(fn(i, _) { num_trees_visible(i, tree_line) })
    })
    |> rotate_trees()
    |> rotate_trees()
    |> rotate_trees()

  assert Ok(scenic_score) =
    list.zip(trees_horizontal, trees_vertical)
    |> list.map(fn(tree_lines) {
      let #(trees, more_trees) = tree_lines
      list.zip(trees, more_trees)
      |> list.map(fn(tree) {
        let #(#(w, x), #(y, z)) = tree
        w * x * y * z
      })
    })
    |> list.flatten()
    |> list.sort(fn(a, b) { int.compare(b, a) })
    |> list.at(0)

  scenic_score
}

// HELPERS --------------------------------------------------------------------

fn tree_visible(tree_index: Int, trees: List(Int)) -> Bool {
  let #(before, after) = list.split(trees, tree_index)
  assert Ok(#(tree_height, after)) = list.pop(after, fn(_) { True })

  let visible_back =
    before
    |> list.reverse()
    |> is_visible(tree_height)

  let visible_font =
    after
    |> is_visible(tree_height)

  visible_back || visible_font
}

fn is_visible(other_trees: List(Int), tree_height: Int) -> Bool {
  case other_trees {
    [] -> True
    _ ->
      other_trees
      |> list.fold(
        True,
        fn(is_visible, other_tree_height) {
          case is_visible {
            False -> False
            _ -> tree_height > other_tree_height
          }
        },
      )
  }
}

fn num_trees_visible(tree_index: Int, trees: List(Int)) -> #(Int, Int) {
  let #(before, after) = list.split(trees, tree_index)
  assert Ok(#(tree_height, after)) = list.pop(after, fn(_) { True })

  let visible_back =
    before
    |> list.reverse()
    |> trees_visible(tree_height)

  let visible_font =
    after
    |> trees_visible(tree_height)

  #(visible_back, visible_font)
}

fn trees_visible(other_trees: List(Int), tree_height: Int) -> Int {
  case other_trees {
    [] -> 0
    _ -> {
      let #(_, num_trees) =
        other_trees
        |> list.fold(
          #(True, 0),
          fn(is_visible, other_tree_height) {
            let #(is_visible, num_trees) = is_visible
            case is_visible {
              False -> #(False, num_trees)
              _ ->
                case tree_height > other_tree_height {
                  True -> #(True, num_trees + 1)
                  _ -> #(False, num_trees + 1)
                }
            }
          },
        )
      num_trees
    }
  }
}

fn rotate_trees(trees: List(List(a))) -> List(List(a)) {
  list.transpose(trees)
}

// PARSE INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(trees) {
    trees
    |> string.split("")
    |> list.map(fn(tree) {
      assert Ok(i) = int.parse(tree)
      i
    })
  })
}
