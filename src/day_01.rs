pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u32> {
	let result = lines
		.map(|line| extract_numbers(&line))
		.map(|numbers| calibration_value(&numbers))
		.sum();
	return Ok(result);
}

struct NumberPattern {
	pattern: &'static str,
	value: u32,
}

const NUMBER_PATTERNS: [NumberPattern; 9] = [
	NumberPattern {
		pattern: "one",
		value: 1,
	},
	NumberPattern {
		pattern: "two",
		value: 2,
	},
	NumberPattern {
		pattern: "three",
		value: 3,
	},
	NumberPattern {
		pattern: "four",
		value: 4,
	},
	NumberPattern {
		pattern: "five",
		value: 5,
	},
	NumberPattern {
		pattern: "six",
		value: 6,
	},
	NumberPattern {
		pattern: "seven",
		value: 7,
	},
	NumberPattern {
		pattern: "eight",
		value: 8,
	},
	NumberPattern {
		pattern: "nine",
		value: 9,
	},
];

struct Matcher {
	pattern: &'static NumberPattern,
	pointer: usize,
}

fn calibration_value(numbers: &Vec<u32>) -> u32 {
	return numbers.first().unwrap() * 10 + numbers.last().unwrap();
}

fn extract_numbers(input: &str) -> Vec<u32> {
	let mut numbers = Vec::<u32>::new();
	let mut matchers = Vec::<Matcher>::new();
	for char in input.chars() {
		match char {
			'0'..='9' => numbers.push(char.to_digit(10).unwrap()),
			_ => {
				// remove invalid matchers
				matchers.retain(|matcher| {
					match matcher.pattern.pattern.chars().nth(matcher.pointer) {
						Some(c) => c == char,
						None => false,
					}
				});

				// advance remaining matchers
				matchers.iter_mut().for_each(|matcher| {
					matcher.pointer += 1;
					if matcher.pointer == matcher.pattern.pattern.len() {
						numbers.push(matcher.pattern.value);
					}
				});

				// add new matchers
				NUMBER_PATTERNS
					.iter()
					.filter(|np| np.pattern.starts_with(char))
					.for_each(|np| {
						matchers.push(Matcher {
							pattern: np,
							pointer: 1,
						})
					});
			}
		}
	}
	return numbers;
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_part_1() {
		let calibration_strings = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"];
		assert_eq!(
			solve(false, calibration_strings.iter().map(|s| (*s).to_owned())).unwrap(),
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
			solve(true, calibration_strings.iter().map(|s| (*s).to_owned())).unwrap(),
			281
		);
	}

	#[test]
	fn test_prefix() {
		let calibration_strings = ["ssseven"];
		assert_eq!(
			solve(true, calibration_strings.iter().map(|s| (*s).to_owned())).unwrap(),
			77
		);
	}

	#[test]
	fn test_suffix() {
		let calibration_strings = ["threee"];
		assert_eq!(
			solve(true, calibration_strings.iter().map(|s| (*s).to_owned())).unwrap(),
			33
		);
	}
}
