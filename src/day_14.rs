use std::collections::HashMap;

pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u32> {
	let map: Plane = Plane::parse(lines)?;
	Ok(map.calculate_total_load())
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
struct Point(u32, u32);

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Rock {
	Cube,
	Sphere,
}

impl Rock {
	fn from_char(char: char) -> Option<Self> {
		return match char {
			'.' => None,
			'#' => Some(Self::Cube),
			'O' => Some(Self::Sphere),
			_ => None, // TODO: Should semantically be an error
		};
	}
}

#[derive(Clone, Debug, PartialEq)]
struct Plane {
	width: u32,
	height: u32,
	rocks: HashMap<Point, Rock>,
}

impl Plane {
	pub fn parse(lines: impl Iterator<Item = String>) -> anyhow::Result<Self> {
		let mut lines = lines.peekable();

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

	pub fn calculate_total_load(&self) -> u32 {
		let mut total_load: u32 = 0;
		let mut points_to_crawl: Vec<Point> = (0..self.width).map(|x| Point(x, 0)).collect();

		// Count all spherical rocks starting at a given position and advancing south
		// until it hits a cube or the edge of the plane.
		while let Some(point) = points_to_crawl.pop() {
			let mut spheres_count = 0;
			let mut y = point.1;
			loop {
				if y >= self.height {
					total_load += self.calculate_load(point, spheres_count); // TODO: merge duplicates
					break;
				}
				match self.rocks.get(&Point(point.0, y)) {
					Some(Rock::Sphere) => spheres_count += 1,
					Some(Rock::Cube) => {
						points_to_crawl.push(Point(point.0, y + 1));
						total_load += self.calculate_load(point, spheres_count); // TODO: merge duplicates
						break;
					}
					None => (),
				}
				y += 1;
			}
		}

		return total_load;
	}

	fn calculate_load(&self, point: Point, spheres_count: u32) -> u32 {
		(0..spheres_count).map(|n| self.height - point.1 - n).sum()
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	fn example_1() -> Plane {
		return Plane {
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
		};
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
		assert_eq!(
			Plane::parse(input.iter().map(|s| s.to_string())).unwrap(),
			example_1()
		)
	}

	#[test]
	fn test_example_1() {
		assert_eq!(example_1().calculate_total_load(), 136)
	}
}
