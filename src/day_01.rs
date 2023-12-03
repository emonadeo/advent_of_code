const NUMBER_PATTERNS: &[(&str, u32)] = &[
	("one", 1),
	("two", 2),
	("three", 3),
	("four", 4),
	("five", 5),
	("six", 6),
	("seven", 7),
	("eight", 8),
	("nine", 9),
];

pub fn calibration_value(calibration_strings: impl Iterator<Item = String>) -> u32 {
	let numbers = calibration_strings.map(|s| {
		let first = find_number(&s, false).unwrap_or(0);
		let last = find_number(&s, true).unwrap_or(0);
		return first * 10 + last;
	});
	return numbers.sum();
}

fn find_number(string: &String, backwards: bool) -> Option<u32> {
	let mut pointers: [usize; NUMBER_PATTERNS.len()] = if backwards {
		NUMBER_PATTERNS
			.iter()
			.map(|p| p.0.len() - 1)
			.collect::<Vec<usize>>()
			.try_into()
			.unwrap()
	} else {
		[0usize; NUMBER_PATTERNS.len()]
	};
	// TODO: ewww
	let chars: Box<dyn Iterator<Item = char>> = if backwards {
		Box::new(string.chars().rev())
	} else {
		Box::new(string.chars())
	};
	for c in chars {
		match c {
			'0'..='9' => return Some(c.to_digit(10).unwrap()),
			_ => {
				let matched_number = match_next_step(&mut pointers, c, backwards);
				if matched_number.is_some() {
					return matched_number;
				}
			}
		}
	}
	return None;
}

// TODO: clean up this function
fn match_next_step(
	pointers: &mut [usize; NUMBER_PATTERNS.len()],
	next: char,
	backwards: bool,
) -> Option<u32> {
	for (pointers_key, pattern) in NUMBER_PATTERNS.iter().enumerate() {
		let pointer = pointers[pointers_key];
		let expected_char = pattern.0.chars().nth(pointer).unwrap();

		if expected_char != next {
			pointers[pointers_key] = if backwards { pattern.0.len() - 1 } else { 0 };
			continue;
		}

		if backwards {
			if pointers[pointers_key] == 0 {
				return Some(pattern.1);
			}

			pointers[pointers_key] -= 1;
			continue;
		}

		if pointers[pointers_key] == pattern.0.len() - 1 {
			return Some(pattern.1);
		}

		pointers[pointers_key] += 1;
		continue;
	}
	return None;
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_part_1() {
		let calibration_strings = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"];
		assert_eq!(
			calibration_value(calibration_strings.iter().map(|s| s.to_string())),
			142
		);
	}

	#[test]
	fn test_part_2() {
		let calibration_strings = [
			"two1nine",
			"eightwothree",
			"abcone2threexyz",
			"xtwone3four",
			"4nineeightseven2",
			"zoneight234",
			"7pqrstsixteen",
		];
		assert_eq!(
			calibration_value(calibration_strings.iter().map(|s| s.to_string())),
			281
		);
	}

	#[test]
	fn test_prefix() {
		let calibration_strings = ["ssseven"];
		assert_eq!(
			calibration_value(calibration_strings.iter().map(|s| s.to_string())),
			77
		);
	}

	#[test]
	fn test_suffix() {
		let calibration_strings = ["threee"];
		assert_eq!(
			calibration_value(calibration_strings.iter().map(|s| s.to_string())),
			33
		);
	}
}
