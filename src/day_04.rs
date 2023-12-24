pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u32> {
	let result = lines
		.map(|line| parse_card(&line))
		.map(|card| calculate_points(card))
		.sum();
	return Ok(result);
}

fn calculate_points(card: (Vec<u32>, Vec<u32>)) -> u32 {
	let (our_numbers, their_numbers) = card;
	let win_amount = our_numbers
		.iter()
		.filter(|our_number| their_numbers.contains(our_number))
		.count();

	if win_amount != 0 {
		2u32.pow(u32::try_from(win_amount).unwrap() - 1)
	} else {
		0
	}
}

fn parse_card(input: &str) -> (Vec<u32>, Vec<u32>) {
	// we don't care about the card label
	let input = &input[(input.find(":").unwrap() + 2)..];

	let (our_input, their_input) = input.split_once(" | ").unwrap();

	let our_numbers = parse_numbers(our_input);
	let their_numbers = parse_numbers(their_input);

	return (our_numbers, their_numbers);
}

fn parse_numbers(input: &str) -> Vec<u32> {
	return input
		.split_whitespace()
		.map(|s| s.parse::<u32>().unwrap())
		.collect();
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_part_1() {
		let cards = [
			"Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53",
			"Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19",
			"Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1",
			"Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83",
			"Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36",
			"Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11",
		];
		assert_eq!(
			solve(false, cards.iter().map(|s| s.to_string())).unwrap(),
			13
		);
	}
}
