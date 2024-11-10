const INPUT: &'static str = include_str!("../../inputs/2023/day_06.txt");

pub fn main(part_two: bool) -> anyhow::Result<u64> {
	let mut lines = INPUT.lines();

	let line = lines.next().unwrap();
	let times = line[5..]
		.split_whitespace()
		.map(|s| s.parse::<u64>().unwrap());

	let line = lines.next().unwrap();
	let distances = line[9..]
		.split_whitespace()
		.map(|s| s.parse::<u64>().unwrap());

	let records = times.zip(distances);

	match part_two {
		false => Ok(solve_part_1(records)),
		true => solve_part_2(records),
	}
}

fn solve_part_1(records: impl IntoIterator<Item = (u64, u64)>) -> u64 {
	let records = records.into_iter();
	let result = records
		.map(|(time, distance)| calculate_possiblities(time, distance))
		.product::<u64>();

	result
}

fn solve_part_2(records: impl IntoIterator<Item = (u64, u64)>) -> anyhow::Result<u64> {
	let (time, distance) = records.into_iter().fold(
		("".to_string(), "".to_string()),
		|(time_acc, distance_acc), (time, distance)| {
			(
				time_acc + &time.to_string(),
				distance_acc + &distance.to_string(),
			)
		},
	);

	Ok(calculate_possiblities(
		time.parse::<u64>()?,
		distance.parse::<u64>()?,
	))
}

fn calculate_possiblities(time: u64, distance_to_beat: u64) -> u64 {
	let time = time as f64;
	let distance_to_beat = distance_to_beat as f64;

	let constant_part = time / 2.0;
	let linear_part = (time.powi(2) / 4.0 - distance_to_beat).sqrt();

	let min_charge_time = constant_part - linear_part;
	let max_charge_time = constant_part + linear_part;

	max_charge_time.ceil() as u64 - min_charge_time.floor() as u64 - 1
}

#[cfg(test)]
mod tests {
	use super::*;

	const EXAMPLE_RECORDS: [(u64, u64); 3] = [(7, 9), (15, 40), (30, 200)];

	mod part_1 {
		use super::*;

		#[test]
		fn test_example() {
			assert_eq!(solve_part_1(EXAMPLE_RECORDS), 288);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example_part_2() {
			assert_eq!(solve_part_2(EXAMPLE_RECORDS).unwrap(), 71503);
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
