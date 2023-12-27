use cached::proc_macro::cached;
use rayon::prelude::*;

pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u64> {
	let records = lines.collect::<Vec<_>>();
	return records
		.par_iter()
		.map(|line| Record::try_from(&line[..]))
		.map(|record| anyhow::Ok(if part_two { record?.unfold() } else { record? }))
		.map(|record| anyhow::Ok(record?.count_arrangements()))
		.sum();
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Condition {
	Operational,
	Damaged,
	Unknown,
}

const O: Condition = Condition::Operational;
const D: Condition = Condition::Damaged;
const U: Condition = Condition::Unknown;

impl TryFrom<char> for Condition {
	type Error = anyhow::Error;

	fn try_from(value: char) -> Result<Self, Self::Error> {
		return match value {
			'.' => Ok(O),
			'#' => Ok(D),
			'?' => Ok(U),
			_ => Err(anyhow::anyhow!(
				"expected one of '.', '#', '?', got {}",
				value
			)),
		};
	}
}

#[derive(Debug, PartialEq, Eq)]
struct Record {
	conditions: Vec<Condition>,
	groups: Vec<u64>,
}

impl Record {
	fn unfold(&self) -> Self {
		return Record {
			conditions: vec![self.conditions.clone(); 5].join(&U),
			groups: self.groups.repeat(5),
		};
	}

	fn count_arrangements(&self) -> u64 {
		let result = match self.conditions.first().copied() {
			Some(U) => {
				let as_operational = Checkpoint::new(
					O,
					self.conditions[1..].to_vec(),
					self.groups.first().unwrap_or(&0).to_owned(),
					self.groups[1..].to_vec(),
				);
				let as_damaged = Checkpoint::new(
					D,
					self.conditions[1..].to_vec(),
					self.groups.first().unwrap_or(&0).to_owned(),
					self.groups[1..].to_vec(),
				);
				count_arrangements(as_operational) + count_arrangements(as_damaged)
			}
			Some(first_condition @ (O | D)) => count_arrangements(Checkpoint::new(
				first_condition,
				self.conditions[1..].to_vec(),
				self.groups.first().unwrap_or(&0).to_owned(),
				self.groups[1..].to_vec(),
			)),
			None => 0,
		};
		return result;
	}
}

#[derive(Debug, PartialEq, Eq, Clone, Hash)]
struct Checkpoint {
	condition: Condition, // TODO: `Unknown` is not allowed here
	rest_conditions: Vec<Condition>,
	group: u64,
	rest_groups: Vec<u64>,
}

impl Checkpoint {
	fn new(
		condition: Condition,
		rest_conditions: Vec<Condition>,
		group: u64,
		rest_groups: Vec<u64>,
	) -> Self {
		return Checkpoint {
			condition,
			rest_conditions,
			group,
			rest_groups,
		};
	}
}

#[cached]
fn count_arrangements(checkpoint: Checkpoint) -> u64 {
	let mut is_after_damaged = false;
	let mut next_condition = Some(checkpoint.condition);
	let mut current_group = checkpoint.group;
	let mut rest_groups = checkpoint.rest_groups;
	let mut rest_conditions = checkpoint.rest_conditions;

	while let Some(current_condition) = next_condition {
		match (is_after_damaged, current_condition, current_group) {
			(false, O | U, 0) => (),
			(false, O, 1..) => (),
			(true, O | U, 0) => {
				let next_group = rest_groups.first().copied();
				if next_group.is_some() {
					rest_groups = rest_groups[1..].to_vec();
				}
				current_group = next_group.unwrap_or(0);
				is_after_damaged = false;
			}
			(true, O, 1..) => return 0,
			(false, D, 0) => return 0,
			(false, D, 1..) => {
				current_group -= 1;
				is_after_damaged = true;
			}
			(true, D, 0) => return 0,
			(true, D | U, 1..) => current_group -= 1,
			(false, U, 1..) => {
				let as_operational = Checkpoint::new(
					O,
					rest_conditions.clone(),
					current_group,
					rest_groups.clone(),
				);
				let as_damaged = Checkpoint::new(D, rest_conditions, current_group, rest_groups);
				return count_arrangements(as_operational) + count_arrangements(as_damaged);
			}
		}
		next_condition = rest_conditions.first().copied();
		if next_condition.is_some() {
			rest_conditions = rest_conditions[1..].to_vec();
		}
	}

	if current_group == 0 && rest_groups.is_empty() {
		return 1;
	}

	return 0;
}

impl TryFrom<&str> for Record {
	type Error = anyhow::Error;

	fn try_from(value: &str) -> Result<Self, Self::Error> {
		let (conditions, groups) = value.split_once(" ").ok_or(anyhow::anyhow!(
			"expected input to contain a space delimiting the spring conditions and groups, got {}",
			value
		))?;

		let conditions = conditions
			.chars()
			.map(|char| Condition::try_from(char))
			.collect::<Result<Vec<_>, _>>()?;

		let groups = groups
			.split(",")
			.map(|group| group.parse::<u64>())
			.collect::<Result<Vec<_>, _>>()?;

		return Ok(Record { conditions, groups });
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	fn example_1() -> Record {
		Record {
			conditions: vec![U, U, U, O, D, D, D],
			groups: vec![1, 1, 3],
		}
	}

	fn example_2() -> Record {
		Record {
			conditions: vec![O, U, U, O, O, U, U, O, O, O, U, D, D, O],
			groups: vec![1, 1, 3],
		}
	}

	fn example_3() -> Record {
		Record {
			conditions: vec![U, D, U, D, U, D, U, D, U, D, U, D, U, D, U],
			groups: vec![1, 3, 1, 6],
		}
	}

	fn example_4() -> Record {
		Record {
			conditions: vec![U, U, U, U, O, D, O, O, O, D, O, O, O],
			groups: vec![4, 1, 1],
		}
	}

	fn example_5() -> Record {
		Record {
			conditions: vec![U, U, U, U, O, D, D, D, D, D, D, O, O, D, D, D, D, D, O],
			groups: vec![1, 6, 5],
		}
	}

	fn example_6() -> Record {
		Record {
			conditions: vec![U, D, D, D, U, U, U, U, U, U, U, U],
			groups: vec![3, 2, 1],
		}
	}

	mod part_1 {
		use super::*;

		#[test]
		fn test_example_1_parse() {
			let record = "???.### 1,1,3";
			assert_eq!(Record::try_from(record).unwrap(), example_1());
		}

		#[test]
		fn test_example_1_count_arrangements() {
			assert_eq!(example_1().count_arrangements(), 1);
		}

		#[test]
		fn test_example_2_parse() {
			let record = ".??..??...?##. 1,1,3";
			assert_eq!(Record::try_from(record).unwrap(), example_2());
		}

		#[test]
		fn test_example_2_count_arrangements() {
			assert_eq!(example_2().count_arrangements(), 4);
		}

		#[test]
		fn test_example_3_parse() {
			let record = "?#?#?#?#?#?#?#? 1,3,1,6";
			assert_eq!(Record::try_from(record).unwrap(), example_3());
		}

		#[test]
		fn test_example_3_count_arrangements() {
			assert_eq!(example_3().count_arrangements(), 1);
		}

		#[test]
		fn test_example_4_parse() {
			let record = "????.#...#... 4,1,1";
			assert_eq!(Record::try_from(record).unwrap(), example_4());
		}

		#[test]
		fn test_example_4_count_arrangements() {
			assert_eq!(example_4().count_arrangements(), 1);
		}

		#[test]
		fn test_example_5_parse() {
			let record = "????.######..#####. 1,6,5";
			assert_eq!(Record::try_from(record).unwrap(), example_5());
		}

		#[test]
		fn test_example_5_count_arrangements() {
			assert_eq!(example_5().count_arrangements(), 4);
		}

		#[test]
		fn test_example_6_parse() {
			let record = "?###???????? 3,2,1";
			assert_eq!(Record::try_from(record).unwrap(), example_6());
		}

		#[test]
		fn test_example_6_count_arrangements() {
			assert_eq!(example_6().count_arrangements(), 10);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example_1_count_arrangements() {
			assert_eq!(example_1().unfold().count_arrangements(), 1);
		}

		#[test]
		fn test_example_2_count_arrangements() {
			assert_eq!(example_2().unfold().count_arrangements(), 16384);
		}

		#[test]
		fn test_example_3_count_arrangements() {
			assert_eq!(example_3().unfold().count_arrangements(), 1);
		}

		#[test]
		fn test_example_4_count_arrangements() {
			assert_eq!(example_4().unfold().count_arrangements(), 16);
		}

		#[test]
		fn test_example_5_count_arrangements() {
			assert_eq!(example_5().unfold().count_arrangements(), 2500);
		}

		#[test]
		fn test_example_6_count_arrangements() {
			assert_eq!(example_6().unfold().count_arrangements(), 506250);
		}
	}
}
