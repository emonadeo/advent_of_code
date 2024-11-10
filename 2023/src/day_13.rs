use std::ops::{Deref, DerefMut};

use anyhow::anyhow;

const INPUT: &'static str = include_str!("../../inputs/2023/day_13.txt");

pub fn main(part_two: bool) -> anyhow::Result<u32> {
	if part_two {
		todo!();
	}
	solve_part_1(INPUT.lines())
}

fn solve_part_1(lines: impl IntoIterator<Item = &'static str>) -> anyhow::Result<u32> {
	let regions = Region::parse_many(lines)?;
	regions
		.into_iter()
		.map(|region| region.find_reflection().ok_or(anyhow!("no reflection")))
		.map(|reflection| Ok(reflection?.score()?))
		.sum()
}

#[derive(Clone, Debug, PartialEq)]
struct Region(Vec<Vec<Terrain>>);

impl Region {
	fn find_reflection(mut self) -> Option<Reflection> {
		if let Some(reflection_before_index) = self.find_reflection_normalized() {
			return Some(Reflection {
				axis: Axis::Horizontal,
				before_index: reflection_before_index,
			});
		}

		self.reverse();

		if let Some(reflection_before_index) = self.find_reflection_normalized() {
			return Some(Reflection {
				axis: Axis::Horizontal,
				before_index: self.len() - reflection_before_index,
			});
		}

		let mut transposed = self.transpose();

		if let Some(reflection_before_index) = transposed.find_reflection_normalized() {
			return Some(Reflection {
				axis: Axis::Vertical,
				before_index: reflection_before_index,
			});
		}

		transposed.reverse();

		if let Some(reflection_before_index) = transposed.find_reflection_normalized() {
			return Some(Reflection {
				axis: Axis::Vertical,
				before_index: transposed.len() - reflection_before_index,
			});
		}

		None
	}

	fn find_reflection_normalized(&self) -> Option<usize> {
		let first_row = self.first()?;
		let mut first_row_matches = self
			.iter()
			.enumerate()
			.filter(|(i, _)| i % 2 == 1) // row matches from reflections can only occur on odd rows
			.filter(|(_, row)| row == &first_row)
			.map(|(i, _)| i);

		let reflection_end = first_row_matches.find(|&i| {
			let (half, mirrored_half) = self[1..i].split_at(i / 2);
			return half.iter().rev().zip(mirrored_half).all(|(a, b)| a == b);
		})?;

		Some(reflection_end / 2 + 1)
	}

	fn new() -> Self {
		Self(Vec::new())
	}

	fn parse_many(lines: impl IntoIterator<Item = &'static str>) -> anyhow::Result<Vec<Self>> {
		lines.into_iter().map(Self::parse_partial).try_fold(
			vec![Region(Vec::new())],
			|acc: Vec<Region>, region_row| {
				Ok(match region_row? {
					Some(region_row) => {
						let (last_region, regions) = acc.split_last().unwrap();
						let mut last_region = Region(last_region.to_vec());
						last_region.push(region_row);
						[regions, &[last_region]].concat()
					}
					None => [acc.as_slice(), &[Region(Vec::new())]].concat(),
				})
			},
		)
	}

	fn parse_partial(line: &str) -> anyhow::Result<Option<Vec<Terrain>>> {
		let partial_region = line
			.chars()
			.map(Terrain::try_from)
			.collect::<anyhow::Result<Vec<Terrain>>>()?;

		let partial_region = match partial_region.is_empty() {
			true => None,
			false => Some(partial_region),
		};

		Ok(partial_region)
	}

	fn transpose(self) -> Region {
		let Some(first_row) = self.first() else {
			return Region::new();
		};
		let columns = first_row.len();
		let mut partial_regions: Vec<_> = self.0.into_iter().map(Vec::into_iter).collect();
		(0..columns)
			.map(|_| {
				partial_regions
					.iter_mut()
					.map(|partial_region| partial_region.next().unwrap())
					.collect()
			})
			.collect()
	}
}

impl Deref for Region {
	type Target = Vec<Vec<Terrain>>;

	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl DerefMut for Region {
	fn deref_mut(&mut self) -> &mut Self::Target {
		&mut self.0
	}
}

impl From<Vec<Vec<Terrain>>> for Region {
	fn from(value: Vec<Vec<Terrain>>) -> Self {
		Region(value)
	}
}

impl FromIterator<Vec<Terrain>> for Region {
	fn from_iter<T: IntoIterator<Item = Vec<Terrain>>>(iter: T) -> Self {
		Region(iter.into_iter().collect())
	}
}

#[derive(Debug, PartialEq)]
enum Axis {
	Horizontal,
	Vertical,
}

#[derive(Debug, PartialEq)]
struct Reflection {
	axis: Axis,
	before_index: usize,
}

impl Reflection {
	fn score(&self) -> anyhow::Result<u32> {
		let before_index = u32::try_from(self.before_index)?;
		let score = match self.axis {
			Axis::Horizontal => before_index * 100,
			Axis::Vertical => before_index,
		};
		Ok(score)
	}
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Terrain {
	Ash,
	Rock,
}

impl TryFrom<char> for Terrain {
	type Error = anyhow::Error;

	fn try_from(value: char) -> Result<Self, Self::Error> {
		match value {
			'.' => Ok(Terrain::Ash),
			'#' => Ok(Terrain::Rock),
			_ => Err(anyhow::anyhow!("Invalid terrain")),
		}
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use Terrain::*;

	fn example_1() -> Region {
		Region(vec![
			vec![Rock, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Ash],
			vec![Ash, Ash, Rock, Ash, Rock, Rock, Ash, Rock, Ash],
			vec![Rock, Rock, Ash, Ash, Ash, Ash, Ash, Ash, Rock],
			vec![Rock, Rock, Ash, Ash, Ash, Ash, Ash, Ash, Rock],
			vec![Ash, Ash, Rock, Ash, Rock, Rock, Ash, Rock, Ash],
			vec![Ash, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Ash],
			vec![Rock, Ash, Rock, Ash, Rock, Rock, Ash, Rock, Ash],
		])
	}

	fn example_2() -> Region {
		Region(vec![
			vec![Rock, Ash, Ash, Ash, Rock, Rock, Ash, Ash, Rock],
			vec![Rock, Ash, Ash, Ash, Ash, Rock, Ash, Ash, Rock],
			vec![Ash, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Rock],
			vec![Rock, Rock, Rock, Rock, Rock, Ash, Rock, Rock, Ash],
			vec![Rock, Rock, Rock, Rock, Rock, Ash, Rock, Rock, Ash],
			vec![Ash, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Rock],
			vec![Rock, Ash, Ash, Ash, Ash, Rock, Ash, Ash, Rock],
		])
	}

	mod part_1 {
		use super::*;

		#[test]
		fn test_example_1_parse() {
			let terrain = [
				"#.##..##.",
				"..#.##.#.",
				"##......#",
				"##......#",
				"..#.##.#.",
				"..##..##.",
				"#.#.##.#.",
			];
			assert_eq!(
				Region::parse_many(terrain).unwrap().first().unwrap(),
				&example_1()
			)
		}

		#[test]
		fn test_example_1_find_reflection() {
			assert_eq!(
				example_1().find_reflection(),
				Some(Reflection {
					axis: Axis::Vertical,
					before_index: 5,
				})
			);
		}

		#[test]
		fn test_example_2_parse() {
			let terrain = [
				"#...##..#",
				"#....#..#",
				"..##..###",
				"#####.##.",
				"#####.##.",
				"..##..###",
				"#....#..#",
			];
			assert_eq!(
				Region::parse_many(terrain).unwrap().first().unwrap(),
				&example_2()
			)
		}

		#[test]
		fn test_example_2_find_reflection() {
			assert_eq!(
				example_2().find_reflection(),
				Some(Reflection {
					axis: Axis::Horizontal,
					before_index: 4,
				})
			);
		}
	}
}
