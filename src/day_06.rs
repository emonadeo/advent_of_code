pub fn solve(mut lines: impl Iterator<Item = String>) -> u64 {
	let line = lines.next().unwrap();
	let times = line[5..]
		.split_whitespace()
		.map(|s| s.parse::<u64>().unwrap());

	let line = lines.next().unwrap();
	let distances = line[9..]
		.split_whitespace()
		.map(|s| s.parse::<u64>().unwrap());

	let times_and_distances = times.zip(distances);
	return times_and_distances
		.map(|(time, distance)| calculate_possiblities(time, distance))
		.product::<u64>();
}

pub fn solve_part_2(mut lines: impl Iterator<Item = String>) -> u64 {
	let line = lines.next().unwrap();
	let time = line[5..]
		.split_whitespace()
		.fold("".to_string(), |acc, time| acc + time)
		.parse::<u64>()
		.unwrap();

	let line = lines.next().unwrap();
	let distance = line[9..]
		.split_whitespace()
		.fold("".to_string(), |acc, time| acc + time)
		.parse::<u64>()
		.unwrap();

	return calculate_possiblities(time, distance);
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

	#[test]
	fn test_example() {
		assert_eq!(solve(EXAMPLE_RECORDS.iter().map(|s| s.to_string())), 288);
	}

	#[test]
	fn test_example_part_2() {
		assert_eq!(
			solve_part_2(EXAMPLE_RECORDS.iter().map(|s| s.to_string())),
			71503
		);
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
