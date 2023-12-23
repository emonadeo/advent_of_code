use std::{collections::HashSet, usize};

#[derive(Debug, PartialEq)]
struct Universe {
	galaxies: HashSet<(usize, usize)>,
	width: usize,
	height: usize,
}

impl Universe {
	fn distance(&self, a: (usize, usize), b: (usize, usize)) -> u32 {
		return (a.0 as u32).abs_diff(b.0 as u32) + (a.1 as u32).abs_diff(b.1 as u32);
	}

	fn empty_rows_columns(&self) -> (HashSet<usize>, HashSet<usize>) {
		let mut empty_rows = (0..self.height).collect::<HashSet<usize>>();
		let mut empty_columns = (0..self.width).collect::<HashSet<usize>>();
		for (row, column) in &self.galaxies {
			empty_rows.remove(&row);
			empty_columns.remove(&column);
		}
		return (empty_rows, empty_columns);
	}

	fn expand(&self) -> Universe {
		let (empty_rows, empty_columns) = self.empty_rows_columns();
		let expanded_galaxies = self
			.galaxies
			.iter()
			.map(|(row, column)| {
				(
					row + empty_rows
						.iter()
						.filter(|&empty_row| empty_row < row)
						.count(),
					column
						+ empty_columns
							.iter()
							.filter(|&empty_column| empty_column < column)
							.count(),
				)
			})
			.collect::<HashSet<(usize, usize)>>();

		return Universe {
			galaxies: expanded_galaxies,
			width: self.width + empty_columns.len(),
			height: self.height + empty_rows.len(),
		};
	}
}

pub fn solve(lines: impl Iterator<Item = String>) -> u32 {
	let universe = parse_universe(lines).expand();
	let galaxies = universe.galaxies.iter();
	let distance_sum = galaxies
		.clone()
		.map(|&a| {
			galaxies
				.clone()
				.map(|&b| universe.distance(a, b))
				.sum::<u32>()
		})
		.sum::<u32>();
	return distance_sum / 2;
}

fn parse_universe(lines: impl Iterator<Item = String>) -> Universe {
	let mut lines = lines.peekable();

	let width = lines.peek().unwrap().len();
	let mut height = 0;

	let galaxies = lines
		.inspect(|_| height += 1)
		.enumerate()
		.flat_map(|(row, line)| {
			let chars = line.chars();
			chars
				.enumerate()
				.filter(|(_, char)| *char == '#')
				.map(|(column, _)| (row, column))
				.collect::<HashSet<(usize, usize)>>()
		})
		.collect::<HashSet<(usize, usize)>>();

	return Universe {
		width,
		height,
		galaxies,
	};
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_example() {
		let image = [
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
		let image_lines = image.iter().map(|s| s.to_string());
		assert_eq!(solve(image_lines), 374);
	}

	#[test]
	fn test_parse_universe() {
		let image = [
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
		let image_lines = image.iter().map(|s| s.to_string());
		assert_eq!(
			parse_universe(image_lines),
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
	fn test_expand_universe() {
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
			universe.expand(),
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
}
