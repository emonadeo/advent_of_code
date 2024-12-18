import common
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}

pub fn part_01(lines: Yielder(String)) -> Int {
  let assert [reg_a, reg_b, reg_c, _, program] = lines |> yielder.to_list()
  let assert Ok(reg_a) = reg_a |> parse_register()
  let assert Ok(reg_b) = reg_b |> parse_register()
  let assert Ok(reg_c) = reg_c |> parse_register()

  program
  |> parse_program()
  |> common.assert_unwrap()
  |> execute(reg_a, reg_b, reg_c)
  |> common.assert_unwrap()
  |> list.map(int.to_string)
  |> string.join(",")
  |> io.println()

  0
}

pub fn part_02(lines: Yielder(String)) -> Int {
  todo
}

/// ## Examples
///
/// ```gleam
/// parse_register("Register A: 69")
/// // -> Ok(69)
/// parse_register("Register B: 420")
/// // -> Ok(420)
/// parse_register("Register C: 2024")
/// // -> Ok(2024)
/// ```
pub fn parse_register(input: String) -> Result(Opcode, Nil) {
  case input |> string.split(" ") {
    ["Register", _, register] -> register |> int.parse()
    _ -> Error(Nil)
  }
}

pub type Opcode =
  Int

/// ## Examples
///
/// ```gleam
/// parse_program("Program: 0,1,5,4,3,0")
/// // -> [0, 1, 5, 4, 3, 0]
/// ```
pub fn parse_program(input: String) -> Result(List(Opcode), Nil) {
  case input {
    "Program: " <> opcodes ->
      opcodes
      |> string.split(",")
      |> list.map(int.parse)
      |> result.all()
    _ -> Error(Nil)
  }
}

/// Evaluate the output of a program (i.e. a list of opcodes).
pub fn execute(
  program: List(Opcode),
  reg_a: Int,
  reg_b: Int,
  reg_c: Int,
) -> Result(List(Int), Nil) {
  let program =
    program
    |> list.index_map(fn(opcode, index) { #(index, opcode) })
    |> dict.from_list()
  let initial_state = new_state(reg_a, reg_b, reg_c)
  program
  |> to_yielder(initial_state)
  |> yielder.last()
  |> result.flatten()
  |> result.map(get_output)
}

pub type Instruction {
  Adv
  Bxl
  Bst
  Jnz
  Bxc
  Out
  Bdv
  Cdv
}

/// ## Examples
///
/// ```gleam
/// parse_instruction(0)
/// // -> Ok(Adv)
/// parse_instruction(1)
/// // -> Ok(Bxl)
/// parse_instruction(2)
/// // -> Ok(Bst)
/// parse_instruction(3)
/// // -> Ok(Jnz)
/// parse_instruction(4)
/// // -> Ok(Bxc)
/// parse_instruction(5)
/// // -> Ok(Out)
/// parse_instruction(6)
/// // -> Ok(Bdv)
/// parse_instruction(7)
/// // -> Ok(Cdv)
/// parse_instruction(8)
/// // -> Error(Nil)
/// parse_instruction(-1)
/// // -> Error(Nil)
/// ```
pub fn parse_instruction(opcode: Int) -> Result(Instruction, Nil) {
  case opcode {
    0 -> Ok(Adv)
    1 -> Ok(Bxl)
    2 -> Ok(Bst)
    3 -> Ok(Jnz)
    4 -> Ok(Bxc)
    5 -> Ok(Out)
    6 -> Ok(Bdv)
    7 -> Ok(Cdv)
    _ -> Error(Nil)
  }
}

pub type State {
  State(reg_a: Int, reg_b: Int, reg_c: Int, pointer: Int, output: List(Int))
}

pub fn new_state(reg_a: Int, reg_b: Int, reg_c) -> State {
  State(reg_a, reg_b, reg_c, 0, [])
}

/// Get the next instruction and opcode.
pub fn next(
  state: State,
  program: Dict(Int, Opcode),
) -> Result(#(Instruction, Opcode), Nil) {
  let pointer = state |> get_pointer()
  use instruction <- result.try(program |> dict.get(pointer))
  use instruction <- result.try(instruction |> parse_instruction())
  use operand <- result.try(program |> dict.get(pointer + 1))
  Ok(#(instruction, operand))
}

/// Execute an instruction and return the new state.
/// Errors if the state is invalid.
pub fn execute_instruction(
  state: State,
  instruction: Instruction,
  opcode: Opcode,
) -> Result(State, Nil) {
  let state = state |> map_pointer(fn(i) { i + 2 })
  case instruction {
    Adv -> {
      let a = state |> get_reg_a()
      use b <- result.try(opcode |> as_combo(state))
      let result = a |> dv(b)
      state |> set_reg_a(result) |> Ok()
    }
    Bdv -> {
      let a = state |> get_reg_a()
      use b <- result.try(opcode |> as_combo(state))
      let result = a |> dv(b)
      state |> set_reg_b(result) |> Ok()
    }
    Cdv -> {
      let a = state |> get_reg_a()
      use b <- result.try(opcode |> as_combo(state))
      let result = a |> dv(b)
      state |> set_reg_c(result) |> Ok()
    }
    Bxl -> {
      let result = state |> get_reg_b() |> int.bitwise_exclusive_or(opcode)
      state |> set_reg_b(result) |> Ok()
    }
    Bst -> {
      use result <- result.try(opcode |> as_combo(state))
      state |> set_reg_b(result % 8) |> Ok()
    }
    Jnz -> {
      case state |> get_reg_a() {
        0 -> state |> Ok()
        _ -> state |> set_pointer(opcode) |> Ok()
      }
    }
    Bxc -> {
      let result =
        state
        |> get_reg_b()
        |> int.bitwise_exclusive_or(state |> get_reg_c())
      state |> set_reg_b(result) |> Ok()
    }
    Out -> {
      use operand <- result.try(opcode |> as_combo(state))
      let state = state |> output(operand % 8)
      Ok(state)
    }
  }
}

/// Calculate `a / 2^b` (truncated).
/// (Operation used by `adv`, `bdv` and `cdv`)
fn dv(a: Int, b: Int) -> Int {
  // Cannot error, since the base is positive
  let assert Ok(denominator) = int.power(2, int.to_float(b))
  a / float.truncate(denominator)
}

/// Feel cute, use a yielder. :3
///
/// (Could have just done a simple recursion that goes straight to the final state,
/// but this way you can do individual steps and other cool shit with `gleam/yielder`)
fn to_yielder(
  program: Dict(Int, Opcode),
  state: State,
) -> Yielder(Result(State, Nil)) {
  case state |> next(program) {
    // No instructions left :)
    Error(Nil) -> yielder.empty()
    Ok(#(instruction, operand)) -> {
      case state |> execute_instruction(instruction, operand) {
        // Invalid state :(
        Error(Nil) -> yielder.single(Error(Nil))
        Ok(state) -> {
          use <- yielder.yield(Ok(state))
          to_yielder(program, state)
        }
      }
    }
  }
}

fn as_combo(operand: Int, state: State) -> Result(Int, Nil) {
  let State(reg_a, reg_b, reg_c, _, _) = state
  case operand {
    0 | 1 | 2 | 3 -> Ok(operand)
    4 -> Ok(reg_a)
    5 -> Ok(reg_b)
    6 -> Ok(reg_c)
    _ -> Error(Nil)
  }
}

pub fn get_reg_a(state: State) -> Int {
  let State(reg_a, _, _, _, _) = state
  reg_a
}

pub fn set_reg_a(state: State, value: Int) -> State {
  let State(_, reg_b, reg_c, pointer, output) = state
  State(value, reg_b, reg_c, pointer, output)
}

pub fn get_reg_b(state: State) -> Int {
  let State(_, reg_b, _, _, _) = state
  reg_b
}

pub fn set_reg_b(state: State, value: Int) -> State {
  let State(reg_a, _, reg_c, pointer, output) = state
  State(reg_a, value, reg_c, pointer, output)
}

pub fn get_reg_c(state: State) -> Int {
  let State(_, _, reg_c, _, _) = state
  reg_c
}

pub fn set_reg_c(state: State, value: Int) -> State {
  let State(reg_a, reg_b, _, pointer, output) = state
  State(reg_a, reg_b, value, pointer, output)
}

pub fn get_pointer(state: State) -> Int {
  let State(_, _, _, pointer, _) = state
  pointer
}

pub fn set_pointer(state: State, value: Int) -> State {
  let State(reg_a, reg_b, reg_c, _, output) = state
  State(reg_a, reg_b, reg_c, value, output)
}

pub fn map_pointer(state: State, fun: fn(Int) -> Int) -> State {
  state |> set_pointer(fun(state |> get_pointer()))
}

pub fn get_output(state: State) -> List(Int) {
  let State(_, _, _, _, output) = state
  output |> list.reverse()
}

pub fn output(state: State, value: Int) -> State {
  let State(reg_a, reg_b, reg_c, pointer, output) = state
  State(reg_a, reg_b, reg_c, pointer, [value, ..output])
}
