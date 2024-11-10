pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<i64> {
	let result = lines
		.map(|line| parse_history(&line))
		.map(|history| Ok(extrapolate(&history?, !part_two)?))
		.sum::<anyhow::Result<_>>()?;

	return Ok(result);
}

fn parse_history(input: &str) -> anyhow::Result<Vec<i64>> {
	let history = input
		.split_whitespace()
		.map(|s| s.parse::<i64>())
		.collect::<Result<Vec<_>, _>>()?;
	return Ok(history);
}

fn extrapolate(history: &Vec<i64>, suffix: bool) -> anyhow::Result<i64> {
	if history.iter().all(|&n| n == 0) {
		return Ok(0);
	}

	let diff = history
		.windows(2)
		.map(|w| w[1] - w[0])
		.collect::<Vec<i64>>();

	let result = if suffix {
		// this cannot panic because `history.iter().all(|&n| n == 0)` implies `history.len() > 1`
		history.last().unwrap() + extrapolate(&diff, true)?
	} else {
		// this cannot panic because `history.iter().all(|&n| n == 0)` implies `history.len() > 1`
		history.first().unwrap() - extrapolate(&diff, false)?
	};

	return Ok(result);
}

#[cfg(test)]
mod tests {
	use super::*;

	mod part_1 {
		use super::*;

		#[test]
		fn test_example() {
			let network = ["0 3 6 9 12 15", "1 3 6 10 15 21", "10 13 16 21 30 45"];
			assert_eq!(
				solve(false, network.iter().map(|s| s.to_string())).unwrap(),
				114
			);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example() {
			let network = ["10 13 16 21 30 45"];
			assert_eq!(
				solve(true, network.iter().map(|s| s.to_string())).unwrap(),
				5
			);
		}
	}
}
