pub fn solve(part_two: bool, mut lines: impl Iterator<Item = String>) -> anyhow::Result<u64> {
	let line = lines.next().unwrap();
	let times = line[5..].split_whitespace();

	let line = lines.next().unwrap();
	let distances = line[9..].split_whitespace();

	return match part_two {
		false => solve_part_1(times, distances),
		true => solve_part_2(times, distances),
	};
}

fn solve_part_1<'a, 'b>(
	times: impl Iterator<Item = &'a str>,
	distances: impl Iterator<Item = &'b str>,
) -> anyhow::Result<u64> {
	let times = times.map(|s| s.parse::<u64>().unwrap());
	let distances = distances.map(|s| s.parse::<u64>().unwrap());

	let result = times
		.zip(distances)
		.map(|(time, distance)| calculate_possiblities(time, distance))
		.product::<u64>();

	return Ok(result);
}

fn solve_part_2<'a, 'b>(
	times: impl Iterator<Item = &'a str>,
	distances: impl Iterator<Item = &'b str>,
) -> anyhow::Result<u64> {
	let time = times
		.fold("".to_string(), |acc, time| acc + time)
		.parse::<u64>()?;

	let distance = distances
		.fold("".to_string(), |acc, time| acc + time)
		.parse::<u64>()?;

	return Ok(calculate_possiblities(time, distance));
}

fn calculate_possiblities(time: u64, distance_to_beat: u64) -> u64 {
	let time = time as f64;
	let distance_to_beat = distance_to_beat as f64;

	let constant_part = time / 2.0;
	let linear_part = (time.powi(2) / 4.0 - distance_to_beat).sqrt();

	let min_charge_time = constant_part - linear_part;
	let max_charge_time = constant_part + linear_part;

	return max_charge_time.ceil() as u64 - min_charge_time.floor() as u64 - 1;
}

#[cfg(test)]
mod tests {
	use super::*;

	const EXAMPLE_RECORDS: [&str; 2] = ["Time: 7 15 30", "Distance: 9 40 200"];

	mod part_1 {
		use super::*;

		#[test]
		fn test_example() {
			assert_eq!(
				solve(false, EXAMPLE_RECORDS.iter().map(|s| s.to_string())).unwrap(),
				288
			);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example_part_2() {
			assert_eq!(
				solve(true, EXAMPLE_RECORDS.iter().map(|s| s.to_string())).unwrap(),
				71503
			);
		}
	}

	#[test]
	fn test_calculate_possibilities_1() {
		assert_eq!(calculate_possiblities(7, 9), 4);
	}

	#[test]
	fn test_calculate_possibilities_2() {
		assert_eq!(calculate_possiblities(15, 40), 8);
	}

	#[test]
	fn test_calculate_possibilities_3() {
		assert_eq!(calculate_possiblities(30, 200), 9);
	}

	#[test]
	fn test_calculate_possibilities_4() {
		assert_eq!(calculate_possiblities(71530, 940200), 71503);
	}
}
