use std::collections::HashSet;

const INPUT: &'static str = include_str!("../../inputs/2023/day_11.txt");

pub fn main(part_two: bool) -> anyhow::Result<u64> {
	let expansion_factor = if !part_two { 2 } else { 1000000 };
	solve(INPUT.lines(), expansion_factor)
}

fn solve(
	lines: impl IntoIterator<Item = &'static str>,
	expansion_factor: u64,
) -> anyhow::Result<u64> {
	let universe = parse_universe(lines).expand(expansion_factor);
	let galaxies = universe.galaxies.iter();
	let distance_sum = galaxies
		.clone()
		.enumerate()
		.map(|(i, &a)| {
			galaxies
				.clone()
				.skip(i + 1)
				.map(|&b| universe.distance(a, b))
				.sum::<u64>()
		})
		.sum::<u64>();
	Ok(distance_sum)
}

#[derive(Debug, PartialEq)]
struct Universe {
	galaxies: HashSet<(u64, u64)>,
	width: u64,
	height: u64,
}

impl Universe {
	fn distance(&self, a: (u64, u64), b: (u64, u64)) -> u64 {
		(a.0 as u64).abs_diff(b.0 as u64) + (a.1 as u64).abs_diff(b.1 as u64)
	}

	fn empty_rows_columns(&self) -> (HashSet<u64>, HashSet<u64>) {
		let mut empty_rows = (0..self.height).collect::<HashSet<u64>>();
		let mut empty_columns = (0..self.width).collect::<HashSet<u64>>();
		for (row, column) in &self.galaxies {
			empty_rows.remove(&row);
			empty_columns.remove(&column);
		}
		(empty_rows, empty_columns)
	}

	fn expand(&self, factor: u64) -> Universe {
		let factor = factor - 1;
		let (empty_rows, empty_columns) = self.empty_rows_columns();
		let expanded_galaxies = self
			.galaxies
			.iter()
			.map(|(row, column)| {
				(
					row + factor
						* empty_rows
							.iter()
							.filter(|&empty_row| empty_row < row)
							.count() as u64,
					column
						+ factor
							* empty_columns
								.iter()
								.filter(|&empty_column| empty_column < column)
								.count() as u64,
				)
			})
			.collect::<HashSet<(u64, u64)>>();

		Universe {
			galaxies: expanded_galaxies,
			width: self.width + empty_columns.len() as u64 * factor,
			height: self.height + empty_rows.len() as u64 * factor,
		}
	}
}

fn parse_universe(lines: impl IntoIterator<Item = &'static str>) -> Universe {
	let mut lines = lines.into_iter().peekable();

	let width = lines.peek().unwrap().len() as u64;
	let mut height = 0;

	let galaxies = lines
		.inspect(|_| height += 1)
		.enumerate()
		.flat_map(|(row, line)| {
			let chars = line.chars();
			chars
				.enumerate()
				.filter(|(_, char)| *char == '#')
				.map(|(column, _)| (row as u64, column as u64))
				.collect::<HashSet<(u64, u64)>>()
		})
		.collect::<HashSet<(u64, u64)>>();

	Universe {
		width,
		height,
		galaxies,
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	const EXAMPLE_LINES: [&str; 10] = [
		"...#......",
		".......#..",
		"#.........",
		"..........",
		"......#...",
		".#........",
		".........#",
		"..........",
		".......#..",
		"#...#.....",
	];

	#[test]
	fn test_parse_universe() {
		assert_eq!(
			parse_universe(EXAMPLE_LINES),
			Universe {
				width: 10,
				height: 10,
				galaxies: HashSet::from([
					(0, 3),
					(1, 7),
					(2, 0),
					(4, 6),
					(5, 1),
					(6, 9),
					(8, 7),
					(9, 0),
					(9, 4)
				])
			}
		)
	}

	#[test]
	fn test_expand() {
		let universe = Universe {
			width: 10,
			height: 10,
			galaxies: HashSet::from([
				(0, 3),
				(1, 7),
				(2, 0),
				(4, 6),
				(5, 1),
				(6, 9),
				(8, 7),
				(9, 0),
				(9, 4),
			]),
		};

		assert_eq!(
			universe.expand(2),
			Universe {
				width: 13,
				height: 12,
				galaxies: HashSet::from([
					(0, 4),
					(1, 9),
					(2, 0),
					(5, 8),
					(6, 1),
					(7, 12),
					(10, 9),
					(11, 0),
					(11, 5)
				])
			}
		);
	}

	#[test]
	fn test_empty_rows_columns() {
		let universe = Universe {
			width: 10,
			height: 10,
			galaxies: HashSet::from([
				(0, 3),
				(1, 7),
				(2, 0),
				(4, 6),
				(5, 1),
				(6, 9),
				(8, 7),
				(9, 0),
				(9, 4),
			]),
		};
		assert_eq!(
			universe.empty_rows_columns(),
			(HashSet::from([3, 7]), HashSet::from([2, 5, 8]))
		)
	}

	mod part_1 {
		use super::*;

		#[test]
		fn test_example() {
			assert_eq!(solve(EXAMPLE_LINES, 2).unwrap(), 374);
		}
	}
	mod part_2 {
		use super::*;

		#[test]
		fn test_example() {
			assert_eq!(solve(EXAMPLE_LINES, 1000000).unwrap(), 82000210);
		}
	}
}
