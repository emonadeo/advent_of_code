use std::collections::{HashMap, HashSet};

const INPUT: &'static str = include_str!("../../inputs/2023/day_10.txt");

pub fn main(part_two: bool) -> anyhow::Result<u32> {
	if part_two {
		todo!();
	}
	Ok(solve_part_1(INPUT.lines()))
}

fn solve_part_1(lines: impl IntoIterator<Item = &'static str>) -> u32 {
	Maze::parse(lines).unwrap().max_distance_from_start()
}

#[derive(Debug, PartialEq, Eq, Clone)]
enum Direction {
	Up,
	Down,
	Left,
	Right,
}

#[derive(PartialEq, Eq, Hash, Clone)]
struct Position(usize, usize);

struct Pipe([Direction; 2]);

struct Maze {
	start_position: Position,
	pipes: HashMap<Position, Pipe>,
}

struct MazeIterator<'a> {
	maze: &'a Maze,
	position: Position,
	entered_from: Direction,
}

impl Direction {
	fn all() -> [Self; 4] {
		[Self::Up, Self::Down, Self::Left, Self::Right]
	}

	fn opposite(&self) -> Self {
		match self {
			Self::Up => Self::Down,
			Self::Down => Self::Up,
			Self::Left => Self::Right,
			Self::Right => Self::Left,
		}
	}
}

impl Position {
	fn next(&self, direction: &Direction) -> Option<Self> {
		match direction {
			Direction::Up => Some(Self(self.0, self.1.checked_sub(1)?)),
			Direction::Down => Some(Self(self.0, self.1 + 1)),
			Direction::Left => Some(Self(self.0.checked_sub(1)?, self.1)),
			Direction::Right => Some(Self(self.0 + 1, self.1)),
		}
	}
}

impl Pipe {
	fn exclude(&self, direction: &Direction) -> anyhow::Result<&Direction> {
		match &self.0 {
			[this, other] if this == direction => Ok(other),
			[other, this] if this == direction => Ok(other),
			_ => Err(anyhow::anyhow!("Direction is not one of pipe's directions")),
		}
	}

	fn infer_from_neighbors(
		pipes: &HashMap<Position, Pipe>,
		position: &Position,
	) -> anyhow::Result<Pipe> {
		let connections = Direction::all().into_iter().filter(|direction| {
			let Some(next) = &position.next(direction) else {
				return false;
			};
			pipes
				.get(next)
				.is_some_and(|pipe| pipe.0.contains(&direction.opposite()))
		});

		let connections: [Direction; 2] = connections
			.collect::<Vec<Direction>>()
			.try_into()
			.or(Err(anyhow::anyhow!("Amount of connections is not 2")))?;

		Ok(Pipe(connections))
	}
}

impl TryFrom<char> for Pipe {
	type Error = anyhow::Error;

	fn try_from(value: char) -> Result<Self, Self::Error> {
		match value {
			'|' => Ok(Pipe([Direction::Up, Direction::Down])),
			'-' => Ok(Pipe([Direction::Left, Direction::Right])),
			'L' => Ok(Pipe([Direction::Up, Direction::Right])),
			'J' => Ok(Pipe([Direction::Up, Direction::Left])),
			'F' => Ok(Pipe([Direction::Down, Direction::Right])),
			'7' => Ok(Pipe([Direction::Down, Direction::Left])),
			_ => Err(anyhow::anyhow!("Unrecognized pipe character")),
		}
	}
}

impl Maze {
	fn bidirectional_iters(&self) -> [MazeIterator; 2] {
		let start_pipe = self.pipes.get(&self.start_position).unwrap();
		let [start_direction_forwards, start_direction_backwards] = &start_pipe.0;
		[
			MazeIterator {
				maze: self,
				position: self.start_position.clone(),
				entered_from: start_direction_forwards.clone(),
			},
			MazeIterator {
				maze: self,
				position: self.start_position.clone(),
				entered_from: start_direction_backwards.clone(),
			},
		]
	}

	fn parse(lines: impl IntoIterator<Item = &'static str>) -> anyhow::Result<Maze> {
		let mut start_position = None;
		let mut pipes = HashMap::new();

		lines.into_iter().enumerate().for_each(|(y, line)| {
			line.chars().enumerate().for_each(|(x, char)| match char {
				'.' => (),
				'S' => start_position = Some(Position(x, y)),
				_ => {
					pipes.insert(Position(x, y), Pipe::try_from(char).unwrap());
				}
			});
		});

		let start_position = start_position.ok_or(anyhow::anyhow!("No start position"))?;

		pipes.insert(
			start_position.clone(),
			Pipe::infer_from_neighbors(&pipes, &start_position)?,
		);

		Ok(Maze {
			start_position,
			pipes,
		})
	}

	fn max_distance_from_start(&self) -> u32 {
		let mut visited = HashSet::new();
		let mut count = 1;
		let [mut forwards, mut backwards] = self.bidirectional_iters();

		loop {
			let forwards_position = forwards.next().unwrap();
			let backwards_position = backwards.next().unwrap();

			if !visited.insert(forwards_position) || !visited.insert(backwards_position) {
				return count;
			}

			count += 1;
		}
	}
}

impl Iterator for MazeIterator<'_> {
	type Item = Position;

	fn next(&mut self) -> Option<Self::Item> {
		let pipe = self.maze.pipes.get(&self.position)?;
		let next_direction = pipe.exclude(&self.entered_from).unwrap();
		let next_position = self.position.next(next_direction)?;
		self.entered_from = next_direction.opposite();
		self.position = next_position.clone();
		Some(next_position)
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_example() {
		let graph = [".....", ".S-7.", ".|.|.", ".L-J.", "....."];
		assert_eq!(solve_part_1(graph), 4);
	}

	#[test]
	fn test_complex_example() {
		let graph = ["..F7.", ".FJ|.", "SJ.L7", "|F--J", "LJ..."];
		assert_eq!(solve_part_1(graph), 8);
	}
}
