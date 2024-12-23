const INPUT: &'static str = include_str!("../../inputs/2023/day_03.txt");

pub fn main(part_two: bool) -> anyhow::Result<u32> {
	if part_two {
		todo!();
	}
	Ok(solve_part_1(INPUT.lines()))
}

fn solve_part_1(schematic: impl IntoIterator<Item = &'static str>) -> u32 {
	parse_part_numbers(schematic).sum()
}

fn parse_part_numbers(
	schematic: impl IntoIterator<Item = &'static str>,
) -> impl Iterator<Item = u32> {
	let mut found_symbols: Vec<(usize, usize)> = Vec::new();
	let mut found_numbers: Vec<PartNumber> = Vec::new();

	schematic.into_iter().enumerate().for_each(|(y, row)| {
		let mut number_matcher = String::new();
		row.chars().enumerate().for_each(|(x, char)| {
			if matches!(char, '0'..='9') {
				number_matcher.push(char);
				return;
			}

			if !number_matcher.is_empty() {
				found_numbers.push(PartNumber {
					value: number_matcher.parse::<u32>().unwrap(),
					row: y,
					column_start: x - number_matcher.len(),
					column_end: x - 1,
				});
				number_matcher.clear();
			}

			if char != '.' {
				found_symbols.push((x, y))
			}
		});

		if !number_matcher.is_empty() {
			found_numbers.push(PartNumber {
				value: number_matcher.parse::<u32>().unwrap(),
				row: y,
				column_start: row.len() - number_matcher.len(),
				column_end: row.len() - 1,
			});
		}
	});

	found_numbers
		.into_iter()
		.filter(move |number| number.is_adjacent_to_symbol(&found_symbols))
		.map(move |number| number.value)
}

#[derive(Debug)]
struct PartNumber {
	value: u32,
	row: usize,
	column_start: usize,
	column_end: usize,
}

impl PartNumber {
	fn is_adjacent_to_symbol(&self, symbol_positions: &[(usize, usize)]) -> bool {
		symbol_positions.iter().any(|(x, y)| {
			*x + 1 >= self.column_start
				&& *x <= self.column_end + 1
				&& *y + 1 >= self.row
				&& *y <= self.row + 1
		})
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_part_1() {
		let schematic = [
			"467..114..",
			"...*......",
			"..35..633.",
			"......#...",
			"617*......",
			".....+.58.",
			"..592.....",
			"......755.",
			"...$.*....",
			".664.598..",
		];
		assert_eq!(solve_part_1(schematic), 4361);
	}

	#[test]
	fn test_edge() {
		let schematic = ["....114", ".....*."];
		assert_eq!(solve_part_1(schematic), 114);
	}

	#[test]
	fn test_adjacent_numbers() {
		let schematic = ["100...", ".100..."];
		assert_eq!(solve_part_1(schematic), 0);
	}
}
