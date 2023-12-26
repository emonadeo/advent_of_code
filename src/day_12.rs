pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u64> {
	let records = lines
		.map(|line| Record::try_from(&line[..]))
		.map(|record| Ok(if part_two { record?.unfold() } else { record? }.count_arrangements()))
		.sum();

	return records;
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Condition {
	Operational,
	Damaged,
	Unknown,
}

impl TryFrom<char> for Condition {
	type Error = anyhow::Error;

	fn try_from(value: char) -> Result<Self, Self::Error> {
		return match value {
			'.' => Ok(Condition::Operational),
			'#' => Ok(Condition::Damaged),
			'?' => Ok(Condition::Unknown),
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
	fn count_arrangements(&self) -> u64 {
		return f(&self.conditions[..], &self.groups[..]);
	}

	fn unfold(&self) -> Self {
		return Record {
			conditions: vec![self.conditions.clone(); 5].join(&U),
			groups: self.groups.repeat(5),
		};
	}
}

const O: Condition = Condition::Operational;
const D: Condition = Condition::Damaged;
const U: Condition = Condition::Unknown;

/// recursive subroutine implementing `count_arrangements`
fn f(conditions: &[Condition], groups: &[u64]) -> u64 {
	return match (conditions, groups) {
		([], []) => 1,
		([], [_, ..]) => 0,
		([O, ..], [0, gs @ ..]) => f(&conditions[1..], gs),
		([O, ..], _) => f(&conditions[1..], groups),
		([D, _, ..], []) => 0,
		([D, O, ..], [1, ..]) => f(&conditions[1..], &groups[1..]),
		([D, O, ..], [_, ..]) => 0,
		([D, D, ..], [1, ..]) => 0,
		([D, D, ..], [g, gs @ ..]) => f(&conditions[1..], &[&[g - 1], gs].concat()),
		([D, U, cs @ ..], [1, ..]) => f(&[&[O], cs].concat(), &groups[1..]),
		([D, U, cs @ ..], [g, gs @ ..]) => f(&[&[D], cs].concat(), &[&[g - 1], gs].concat()),
		([D], [1]) => 1,
		([D], [_, ..]) => 0,
		([D], []) => 0,
		([U, cs @ ..], _) => {
			let as_operational = f(&[&[O], cs].concat(), groups);
			let as_damaged = f(&[&[D], cs].concat(), groups);
			return as_operational + as_damaged;
		}
	};
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
