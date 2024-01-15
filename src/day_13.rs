use std::iter;

use anyhow::anyhow;

pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u32> {
	let regions = parse_regions(lines)?;
	return regions
		.iter()
		.map(find_reflection)
		.map(|reflection| reflection.ok_or(anyhow!("No reflection was found")))
		.map(|reflection| Ok(reflection?.score()?))
		.sum();
}

type Region = Vec<Vec<Terrain>>;

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
		return Ok(score);
	}
}

fn parse_regions(lines: impl Iterator<Item = String>) -> anyhow::Result<Vec<Region>> {
	return lines
		.map(parse_region_row)
		.try_fold(vec![Vec::new()], |acc, region_row| {
			return Ok(match region_row? {
				Some(region_row) => {
					let (last_region, regions) = acc.split_last().unwrap();
					let mut last_region = last_region.to_vec();
					last_region.push(region_row);
					[regions, &[last_region]].concat()
				}
				None => [acc.as_slice(), &[Vec::new()]].concat(),
			});
		});
}

fn parse_region_row(line: String) -> anyhow::Result<Option<Vec<Terrain>>> {
	let partial_region = line
		.chars()
		.map(Terrain::try_from)
		.collect::<anyhow::Result<Vec<Terrain>>>()?;

	let partial_region = match partial_region.is_empty() {
		true => None,
		false => Some(partial_region),
	};

	return Ok(partial_region);
}

fn find_reflection(region: &Region) -> Option<Reflection> {
	if let Some(reflection_before_index) = find_reflection_normalized(region) {
		return Some(Reflection {
			axis: Axis::Horizontal,
			before_index: reflection_before_index,
		});
	}

	let region_reversed = region.into_iter().cloned().rev().collect::<Vec<_>>();
	if let Some(reflection_before_index) = find_reflection_normalized(&region_reversed) {
		return Some(Reflection {
			axis: Axis::Horizontal,
			before_index: region.len() - reflection_before_index,
		});
	}

	let region_transposed = &transpose(region.to_vec());
	if let Some(reflection_before_index) = find_reflection_normalized(region_transposed) {
		return Some(Reflection {
			axis: Axis::Vertical,
			before_index: reflection_before_index,
		});
	}

	let region_transposed_reversed = region_transposed
		.into_iter()
		.cloned()
		.rev()
		.collect::<Vec<_>>();
	if let Some(reflection_before_index) = find_reflection_normalized(&region_transposed_reversed) {
		return Some(Reflection {
			axis: Axis::Vertical,
			before_index: region.first()?.len() - reflection_before_index,
		});
	}

	return None;
}

fn find_reflection_normalized(region_normalized: &Region) -> Option<usize> {
	let first_row = region_normalized.first()?;
	let mut first_row_matches = region_normalized
		.into_iter()
		.enumerate()
		.filter(|(i, _)| i % 2 == 1) // row matches from reflections can only occur on odd rows
		.filter(|(_, row)| row == &first_row)
		.map(|(i, _)| i);

	let reflection_end = first_row_matches.find(|&i| {
		let (half, mirrored_half) = region_normalized[1..i].split_at(i / 2);
		return half.iter().rev().zip(mirrored_half).all(|(a, b)| a == b);
	})?;

	return Some(reflection_end / 2 + 1);
}

// TODO: this is copied from stack overflow, come up with own solution
// https://stackoverflow.com/questions/64498617/how-to-transpose-a-vector-of-vectors-in-rust
fn transpose<T>(v: Vec<Vec<T>>) -> Vec<Vec<T>> {
	let len = v[0].len();
	let mut iters: Vec<_> = v.into_iter().map(|n| n.into_iter()).collect();
	(0..len)
		.map(|_| {
			iters
				.iter_mut()
				.map(|n| n.next().unwrap())
				.collect::<Vec<T>>()
		})
		.collect()
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
		return vec![
			vec![Rock, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Ash],
			vec![Ash, Ash, Rock, Ash, Rock, Rock, Ash, Rock, Ash],
			vec![Rock, Rock, Ash, Ash, Ash, Ash, Ash, Ash, Rock],
			vec![Rock, Rock, Ash, Ash, Ash, Ash, Ash, Ash, Rock],
			vec![Ash, Ash, Rock, Ash, Rock, Rock, Ash, Rock, Ash],
			vec![Ash, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Ash],
			vec![Rock, Ash, Rock, Ash, Rock, Rock, Ash, Rock, Ash],
		];
	}

	fn example_2() -> Region {
		return vec![
			vec![Rock, Ash, Ash, Ash, Rock, Rock, Ash, Ash, Rock],
			vec![Rock, Ash, Ash, Ash, Ash, Rock, Ash, Ash, Rock],
			vec![Ash, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Rock],
			vec![Rock, Rock, Rock, Rock, Rock, Ash, Rock, Rock, Ash],
			vec![Rock, Rock, Rock, Rock, Rock, Ash, Rock, Rock, Ash],
			vec![Ash, Ash, Rock, Rock, Ash, Ash, Rock, Rock, Rock],
			vec![Rock, Ash, Ash, Ash, Ash, Rock, Ash, Ash, Rock],
		];
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
				parse_regions(terrain.iter().map(|s| s.to_string()))
					.unwrap()
					.first()
					.unwrap(),
				&example_1()
			)
		}

		#[test]
		fn test_example_1_find_reflection() {
			assert_eq!(
				find_reflection(&example_1()),
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
				parse_regions(terrain.iter().map(|s| s.to_string()))
					.unwrap()
					.first()
					.unwrap(),
				&example_2()
			)
		}

		#[test]
		fn test_example_2_find_reflection() {
			assert_eq!(
				find_reflection(&example_2()),
				Some(Reflection {
					axis: Axis::Horizontal,
					before_index: 4,
				})
			);
		}
	}
}
