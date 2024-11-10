use std::{
	collections::{HashMap, VecDeque},
	fmt::Debug,
};

const INPUT: &'static str = include_str!("../../inputs/2023/day_14.txt");

pub fn main(part_two: bool) -> anyhow::Result<u32> {
	solve(INPUT.lines(), part_two)
}

fn solve(lines: impl IntoIterator<Item = &'static str>, cycle: bool) -> anyhow::Result<u32> {
	let mut plane: Plane = Plane::parse(lines)?;
	if cycle {
		plane.cycle(1000000000)
	} else {
		plane.tilt(Direction::North);
	}
	Ok(plane.total_load())
}

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
struct Point(i64, i64);

impl Point {
	fn new(x: u32, y: u32) -> Self {
		Point(x as i64, y as i64)
	}

	fn add(&self, direction: Direction, length: u32) -> Self {
		match direction {
			Direction::North => Self(self.0, self.1 - length as i64),
			Direction::South => Self(self.0, self.1 + length as i64),
			Direction::East => Self(self.0 + length as i64, self.1),
			Direction::West => Self(self.0 - length as i64, self.1),
		}
	}

	fn is_inside_plane(&self, plane: &Plane) -> bool {
		self.0 >= 0 && self.0 < plane.width as i64 && self.1 >= 0 && self.1 < plane.height as i64
	}
}

impl Debug for Point {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		write!(f, "({}, {})", self.0, self.1)
	}
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Rock {
	Cube,
	Sphere,
}

impl Rock {
	fn from_char(char: char) -> Option<Self> {
		match char {
			'.' => None,
			'#' => Some(Self::Cube),
			'O' => Some(Self::Sphere),
			_ => panic!(), // WARN: Should semantically be an error
		}
	}
}

impl Into<char> for &Rock {
	fn into(self) -> char {
		match self {
			Rock::Cube => '#',
			Rock::Sphere => 'O',
		}
	}
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
	North,
	East,
	South,
	West,
}

impl Direction {
	fn flip(&self) -> Direction {
		match self {
			Direction::North => Direction::South,
			Direction::South => Direction::North,
			Direction::East => Direction::West,
			Direction::West => Direction::East,
		}
	}
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct RockColumn {
	start: Point,
	direction: Direction,
	/// Amount of spherical rocks found
	spheres_count: u32,
	/// Total steps done before hitting a cube or the edge of the plane
	total_length: u32,
}

impl RockColumn {
	pub fn end(&self) -> Point {
		self.start.add(self.direction, self.total_length - 1)
	}
}

#[derive(Clone, PartialEq, Eq)]
struct Plane {
	width: u32,
	height: u32,
	rocks: HashMap<Point, Rock>,
}

impl Debug for Plane {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		writeln!(f, "")?;
		for y in 0..self.height {
			let line = (0..self.width)
				.map(|x| {
					self.rocks
						.get(&Point::new(x, y))
						.map_or('.', |rock| rock.into())
				})
				.collect::<String>();
			writeln!(f, "{}", line)?;
		}
		Ok(())
	}
}

impl Plane {
	pub fn parse(lines: impl IntoIterator<Item = &'static str>) -> anyhow::Result<Self> {
		let mut lines = lines.into_iter().peekable();

		let width = lines.peek().unwrap().len().try_into()?;
		let mut height = 0;
		let rocks: HashMap<Point, Rock> = lines
			.inspect(|_| height += 1)
			.enumerate()
			.flat_map(|(y, line)| {
				line.chars()
					.enumerate()
					.filter_map(move |(x, char)| {
						Some((
							Point(x.try_into().unwrap(), y.try_into().unwrap()),
							Rock::from_char(char)?,
						))
					})
					.collect::<HashMap<Point, Rock>>() // TODO: do not collect inbetween
			})
			.collect();

		Ok(Plane {
			width,
			height,
			rocks,
		})
	}

	fn cycle_once(&mut self) {
		self.tilt(Direction::North);
		self.tilt(Direction::West);
		self.tilt(Direction::South);
		self.tilt(Direction::East);
	}

	fn cycle(&mut self, times: u32) {
		let mut cycle_history = VecDeque::from([self.clone()]);
		for t in 0..times {
			self.cycle_once();
			if let Some(i) = cycle_history.iter().position(|plane| plane == self) {
				let remaining_cycles = (times - t - 1) % (i as u32 + 1);
				for _ in 0..remaining_cycles {
					self.cycle_once();
				}
				break;
			}
			cycle_history.push_front(self.clone());
		}
	}

	fn tilt(&mut self, direction: Direction) {
		let width = self.width;
		let height = self.height;
		let direction = direction.flip();
		let mut stack: Vec<Point> = match direction {
			Direction::South => (0..width).map(|x| Point::new(x, 0)).collect(),
			Direction::North => (0..width).map(|x| Point::new(x, height - 1)).collect(),
			Direction::East => (0..height).map(|y| Point::new(0, y)).collect(),
			Direction::West => (0..height).map(|y| Point::new(width - 1, y)).collect(),
		};

		while let Some(point) = stack.pop() {
			if self.rocks.get(&point) == Some(&Rock::Cube) {
				let next_point = point.add(direction, 1);
				if next_point.is_inside_plane(self) {
					stack.push(next_point);
				}
				continue;
			}

			let rock_column = self.crawl_rock_column(point, direction);
			self.collapse_rock_column(rock_column);

			let next_point = rock_column.end().add(direction, 2);
			if next_point.is_inside_plane(self) {
				stack.push(next_point);
			}
		}
	}

	fn collapse_rock_column(&mut self, rock_column: RockColumn) {
		(0..rock_column.total_length).for_each(|offset| {
			let point = rock_column.start.add(rock_column.direction, offset);
			if offset < rock_column.spheres_count {
				self.rocks.insert(point, Rock::Sphere);
			} else {
				self.rocks.remove(&point);
			}
		})
	}

	fn crawl_rock_column(&self, start: Point, direction: Direction) -> RockColumn {
		let mut spheres_count = 0;
		let mut offset: u32 = 0;
		loop {
			if match direction {
				Direction::North => start.1 - offset as i64 == -1,
				Direction::South => start.1 + offset as i64 == self.height.into(),
				Direction::West => start.0 - offset as i64 == -1,
				Direction::East => start.0 + offset as i64 == self.width.into(),
			} {
				break;
			}

			let point = start.add(direction, offset);
			match self.rocks.get(&point) {
				Some(Rock::Sphere) => spheres_count += 1,
				Some(Rock::Cube) => {
					break;
				}
				None => (),
			}

			offset += 1
		}
		RockColumn {
			start,
			direction,
			spheres_count,
			total_length: offset,
		}
	}

	pub fn total_load(&self) -> u32 {
		self.rocks
			.iter()
			.filter(|(_, rock)| **rock == Rock::Sphere)
			.fold(0, |total_load, (point, _)| {
				// WARN: Converting from `i64` to `u32` can technically panic
				total_load + self.height - point.1 as u32
			})
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	fn example_1() -> Plane {
		Plane {
			width: 10,
			height: 10,
			rocks: [
				(Point(0, 0), Rock::Sphere),
				(Point(5, 0), Rock::Cube),
				(Point(0, 1), Rock::Sphere),
				(Point(2, 1), Rock::Sphere),
				(Point(3, 1), Rock::Sphere),
				(Point(4, 1), Rock::Cube),
				(Point(9, 1), Rock::Cube),
				(Point(5, 2), Rock::Cube),
				(Point(6, 2), Rock::Cube),
				(Point(0, 3), Rock::Sphere),
				(Point(1, 3), Rock::Sphere),
				(Point(3, 3), Rock::Cube),
				(Point(4, 3), Rock::Sphere),
				(Point(9, 3), Rock::Sphere),
				(Point(1, 4), Rock::Sphere),
				(Point(7, 4), Rock::Sphere),
				(Point(8, 4), Rock::Cube),
				(Point(0, 5), Rock::Sphere),
				(Point(2, 5), Rock::Cube),
				(Point(5, 5), Rock::Sphere),
				(Point(7, 5), Rock::Cube),
				(Point(9, 5), Rock::Cube),
				(Point(2, 6), Rock::Sphere),
				(Point(5, 6), Rock::Cube),
				(Point(6, 6), Rock::Sphere),
				(Point(9, 6), Rock::Sphere),
				(Point(7, 7), Rock::Sphere),
				(Point(0, 8), Rock::Cube),
				(Point(5, 8), Rock::Cube),
				(Point(6, 8), Rock::Cube),
				(Point(7, 8), Rock::Cube),
				(Point(0, 9), Rock::Cube),
				(Point(1, 9), Rock::Sphere),
				(Point(2, 9), Rock::Sphere),
				(Point(5, 9), Rock::Cube),
			]
			.into(),
		}
	}

	#[test]
	fn test_example_1_parse() {
		let input = [
			"O....#....",
			"O.OO#....#",
			".....##...",
			"OO.#O....O",
			".O.....O#.",
			"O.#..O.#.#",
			"..O..#O..O",
			".......O..",
			"#....###..",
			"#OO..#....",
		];
		assert_eq!(Plane::parse(input).unwrap(), example_1())
	}

	#[test]
	fn test_example_1_tilt_north() {
		let mut plane = example_1();
		plane.tilt(Direction::North);
		// WARN: this should use the constructor instead of `parse`
		let expected = Plane::parse([
			"OOOO.#.O..",
			"OO..#....#",
			"OO..O##..O",
			"O..#.OO...",
			"........#.",
			"..#....#.#",
			"..O..#.O.O",
			"..O.......",
			"#....###..",
			"#....#....",
		])
		.unwrap();
		assert_eq!(plane, expected);
	}

	#[test]
	fn test_example_1_tilt_south() {
		let mut plane = example_1();
		plane.tilt(Direction::South);
		// WARN: this should use the constructor instead of `parse`
		let expected = Plane::parse([
			".....#....",
			"....#....#",
			"...O.##...",
			"...#......",
			"O.O....O#O",
			"O.#..O.#.#",
			"O....#....",
			"OO....OO..",
			"#OO..###..",
			"#OO.O#...O",
		])
		.unwrap();
		assert_eq!(plane, expected);
	}

	#[test]
	fn test_example_1_cycle_once() {
		let mut plane = example_1();
		plane.cycle(1);
		// WARN: this should use the constructor instead of `parse`
		let expected = Plane::parse([
			".....#....",
			"....#...O#",
			"...OO##...",
			".OO#......",
			".....OOO#.",
			".O#...O#.#",
			"....O#....",
			"......OOOO",
			"#...O###..",
			"#..OO#....",
		])
		.unwrap();
		assert_eq!(plane, expected);
	}

	#[test]
	fn test_example_1_cycle_twice() {
		let mut plane = example_1();
		plane.cycle(2);
		// WARN: this should use the constructor instead of `parse`
		let expected = Plane::parse([
			".....#....",
			"....#...O#",
			".....##...",
			"..O#......",
			".....OOO#.",
			".O#...O#.#",
			"....O#...O",
			".......OOO",
			"#..OO###..",
			"#.OOO#...O",
		])
		.unwrap();
		assert_eq!(plane, expected);
	}

	#[test]
	fn test_example_1_cycle_thrice() {
		let mut plane = example_1();
		plane.cycle(3);
		// WARN: this should use the constructor instead of `parse`
		let expected = Plane::parse([
			".....#....",
			"....#...O#",
			".....##...",
			"..O#......",
			".....OOO#.",
			".O#...O#.#",
			"....O#...O",
			".......OOO",
			"#...O###.O",
			"#.OOO#...O",
		])
		.unwrap();
		assert_eq!(plane, expected);
	}

	mod part_1 {
		use super::*;
		#[test]
		fn test_example_1() {
			let mut plane = example_1();
			plane.tilt(Direction::North);
			assert_eq!(plane.total_load(), 136)
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example_1() {
			let mut plane = example_1();
			plane.cycle(1000000000);
			assert_eq!(plane.total_load(), 64)
		}
	}

	mod point {
		use super::*;

		#[test]
		fn test_add() {
			assert_eq!(Point(10, 10).add(Direction::North, 5), Point(10, 5));
			assert_eq!(Point(10, 10).add(Direction::South, 5), Point(10, 15));
			assert_eq!(Point(10, 10).add(Direction::East, 5), Point(15, 10));
			assert_eq!(Point(10, 10).add(Direction::West, 5), Point(5, 10));
		}
	}
}
