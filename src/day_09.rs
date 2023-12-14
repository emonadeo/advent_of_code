pub fn solve(lines: impl Iterator<Item = String>) -> i64 {
	return lines
		.map(|line| parse_history(&line))
		.map(|history| extrapolate(&history))
		.sum();
}

fn parse_history(input: &str) -> Vec<i64> {
	return input
		.split_whitespace()
		.map(|s| s.parse::<i64>().unwrap())
		.collect();
}

fn extrapolate(history: &Vec<i64>) -> i64 {
	if history.iter().all(|&n| n == 0) {
		return 0;
	}

	let diff = history
		.windows(2)
		.map(|w| w[1] - w[0])
		.collect::<Vec<i64>>();

	return history.first().unwrap() - extrapolate(&diff);
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_example() {
		let network = ["10  13  16  21  30  45"];
		assert_eq!(solve(network.iter().map(|s| s.to_string())), 5);
	}
}
