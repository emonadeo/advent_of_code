#[derive(Debug)]
struct Number {
	value: u32,
	row: usize,
	column_start: usize,
	column_end: usize,
}

pub fn sum_part_numbers(schematic: impl Iterator<Item = String>) -> u32 {
	let schematic = schematic
		.map(|s| s.chars().collect::<Vec<_>>())
		.collect::<Vec<_>>();

	let mut found_symbols: Vec<(usize, usize)> = Vec::new();
	let mut found_numbers: Vec<Number> = Vec::new();

	schematic.iter().enumerate().for_each(|(y, row)| {
		let mut number_matcher = String::new();

		row.iter().enumerate().for_each(|(x, char)| {
			if matches!(*char, '0'..='9') {
				dbg!(char);
				number_matcher.push(*char);
				return;
			}

			if !number_matcher.is_empty() {
				found_numbers.push(Number {
					value: number_matcher.parse::<u32>().unwrap(),
					row: y,
					column_start: x - number_matcher.len(),
					column_end: x,
				});
				number_matcher.clear();
			}

			if *char != '.' {
				found_symbols.push((x, y))
			}
		});
	});

	found_numbers.retain(|number| {
		found_symbols.iter().any(|(x, y)| {
			*x + 1 >= number.column_start
				&& *x <= number.column_end + 1
				&& *y + 1 >= number.row
				&& *y <= number.row + 1
		})
	});

	return found_numbers.iter().map(|number| number.value).sum();
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
		assert_eq!(
			sum_part_numbers(schematic.iter().map(|s| s.to_string())),
			4361
		);
	}

	#[test]
	fn test_adjacent_numbers() {
		let schematic = ["100...", ".100..."];
		assert_eq!(sum_part_numbers(schematic.iter().map(|s| s.to_string())), 0);
	}
}
