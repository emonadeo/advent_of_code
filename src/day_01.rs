pub fn calibration_value(calibration_strings: impl Iterator<Item = String>) -> u32 {
	let numbers = calibration_strings.map(|s| {
		let mut digits_iterator = s.chars().filter(|c| c.is_digit(10));
		let first = digits_iterator.next().unwrap_or('0');
		let last = digits_iterator.last().unwrap_or(first);
		return format!("{}{}", first, last).parse::<u32>().unwrap_or(0);
	});
	return numbers.sum();
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_simple() {
		let calibration_strings = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"];
		assert_eq!(
			calibration_value(calibration_strings.iter().map(|s| s.to_string())),
			142
		);
	}
}
