// IMPORTS --------------------------------------------------------------------

import gleam/list
import gleam/string
import gleam/int

// TYPES ----------------------------------------------------------------------

type FileSystem {
  FileSystem(path: String, total_size: Int)
}

// SOLUTIONS ------------------------------------------------------------------

pub fn pt_1(input) {
  let dirs =
    input
    |> parse_input()
    |> get_dirs([""], [])

  dirs
  |> list.map(add_children_to_parent(dirs, _))
  |> list.filter(fn(dir) { dir.total_size <= 100000 })
  |> list.fold(0, fn(acc, dir) { dir.total_size + acc })
}

pub fn pt_2(input) {
  let dirs =
    input
    |> parse_input()
    |> get_dirs([""], [])

  let dirs =
    dirs
    |> list.map(add_children_to_parent(dirs, _))

  let total =
    dirs
    |> list.fold(
      0,
      fn(acc, dir) {
        case dir.total_size > acc {
          True -> dir.total_size
          _ -> acc
        }
      },
    )

  assert Ok(#(v, _)) =
    dirs
    |> list.filter(fn(dir) { 30000000 + total - dir.total_size < 70000000 })
    |> list.map(fn(dir) { dir.total_size })
    |> list.sort(int.compare)
    |> list.pop(fn(_) { True })

  v
}

// HELPERS --------------------------------------------------------------------

fn get_dirs(
  commands: List(List(String)),
  path: List(String),
  dirs: List(FileSystem),
) -> List(FileSystem) {
  case commands {
    [] -> dirs
    [command, ..tl] ->
      case command {
        ["$", "cd", ".."] -> {
          assert Ok(new_path) = list.rest(path)
          get_dirs(tl, new_path, dirs)
        }
        ["$", "cd", dir_name] -> {
          assert Ok(#(_, commands)) = list.pop(tl, fn(_) { True })
          let new_path = [dir_name, ..path]
          let #(commands, dir) =
            ls(
              commands,
              FileSystem(
                path: string.join(list.reverse(new_path), "/"),
                total_size: 0,
              ),
            )
          get_dirs(commands, new_path, [dir, ..dirs])
        }
        ["$", "ls"] -> {
          let #(commands, dir) =
            ls(tl, FileSystem(path: string.join(path, "/"), total_size: 0))
          get_dirs(commands, path, [dir, ..dirs])
        }
      }
  }
}

fn ls(
  commands: List(List(String)),
  dir: FileSystem,
) -> #(List(List(String)), FileSystem) {
  let files =
    commands
    |> list.take_while(fn(command) {
      case command {
        ["$", ..] -> False
        _ -> True
      }
    })

  let total_size =
    files
    |> list.map(fn(file) {
      case file {
        ["dir", _] -> 0
        _ -> {
          let [number, _] = file
          assert Ok(size) = int.parse(number)
          size
        }
      }
    })
    |> int.sum()

  assert #(_, remaining_commands) = list.split(commands, list.length(files))

  #(remaining_commands, FileSystem(path: dir.path, total_size: total_size))
}

fn add_children_to_parent(
  dirs: List(FileSystem),
  parent: FileSystem,
) -> FileSystem {
  let children_total =
    dirs
    |> list.filter(fn(dir) {
      dir.path != parent.path && string.starts_with(dir.path, parent.path)
    })
    |> list.fold(0, fn(acc, child) { acc + child.total_size })

  FileSystem(..parent, total_size: parent.total_size + children_total)
}

// PARSE_INPUT ----------------------------------------------------------------

fn parse_input(input: String) -> List(List(String)) {
  input
  |> string.split("\n")
  |> list.map(string.split(_, " "))
}
