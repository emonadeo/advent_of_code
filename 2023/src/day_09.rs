const INPUT: &'static str = include_str!("../../inputs/2023/day_09.txt");

pub fn main(part_two: bool) -> anyhow::Result<i64> {
	solve(INPUT.lines(), part_two)
}

fn solve(lines: impl IntoIterator<Item = &'static str>, suffix: bool) -> anyhow::Result<i64> {
	let result = lines
		.into_iter()
		.map(|line| parse_history(&line))
		.map(|history| Ok(extrapolate(&history?, !suffix)?))
		.sum::<anyhow::Result<_>>()?;

	Ok(result)
}

fn parse_history(input: &str) -> anyhow::Result<Vec<i64>> {
	let history = input
		.split_whitespace()
		.map(|s| s.parse::<i64>())
		.collect::<Result<Vec<_>, _>>()?;
	Ok(history)
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

	Ok(result)
}

#[cfg(test)]
mod tests {
	use super::*;

	mod part_1 {
		use super::*;

		#[test]
		fn test_example() {
			let network = ["0 3 6 9 12 15", "1 3 6 10 15 21", "10 13 16 21 30 45"];
			assert_eq!(solve(network, false).unwrap(), 114);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example() {
			let network = ["10 13 16 21 30 45"];
			assert_eq!(solve(network, true).unwrap(), 5);
		}
	}
}
