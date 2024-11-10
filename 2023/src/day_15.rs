use std::collections::HashMap;

const INPUT: &'static str = include_str!("../../inputs/2023/day_15.txt");

pub fn main(part_two: bool) -> anyhow::Result<u32> {
	let line = INPUT.lines().next().ok_or(anyhow::anyhow!("No input"))?;
	let steps = line.split(',');

	match part_two {
		false => solve_part_1(steps),
		true => solve_part_2(steps),
	}
}

pub fn solve_part_1(steps: impl IntoIterator<Item = &'static str>) -> anyhow::Result<u32> {
	let steps = steps.into_iter();
	steps.map(hash).map(|step| Ok(u32::from(step?))).sum()
}

pub fn solve_part_2(steps: impl IntoIterator<Item = &'static str>) -> anyhow::Result<u32> {
	let steps = steps.into_iter();
	let boxes: LensBoxes = steps.map(Step::try_from).collect::<anyhow::Result<_>>()?;
	boxes.total_focusing_power()
}

fn hash(input: &str) -> anyhow::Result<u8> {
	input.chars().fold(Ok(0u8), |acc, char| {
		let ascii_code: u8 = char.try_into()?;
		Ok(acc?.wrapping_add(ascii_code).wrapping_mul(17))
	})
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
struct Lens<'a> {
	label: &'a str,
	focal_length: u8,
}

impl<'l> Lens<'l> {
	fn new(label: &'l str, focal_length: u8) -> Self {
		Self {
			label,
			focal_length,
		}
	}
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
struct LensBox<'l>(Vec<Lens<'l>>);

impl<'l> LensBox<'l> {
	fn remove(&mut self, label: &str) {
		self.0
			.iter()
			.position(|lens| lens.label == label)
			.inspect(|&i| {
				self.0.remove(i);
			});
	}

	fn insert(&mut self, label: &'l str, focal_length: u8) {
		match self.0.iter_mut().find(|lens| lens.label == label) {
			Some(lens) => lens.focal_length = focal_length,
			None => self.0.push(Lens::new(label, focal_length)),
		}
	}

	fn focusing_power(&self, box_index: u8) -> anyhow::Result<u32> {
		self.0
			.iter()
			.enumerate()
			.map(|(slot_index, lens)| {
				Ok((u32::from(box_index) + 1)
					* (u32::try_from(slot_index)? + 1)
					* u32::from(lens.focal_length))
			})
			.sum()
	}
}

impl<'l, T> From<T> for LensBox<'l>
where
	T: Into<Vec<Lens<'l>>>,
{
	fn from(value: T) -> Self {
		LensBox(value.into())
	}
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
struct LensBoxes<'l>(HashMap<u8, LensBox<'l>>);

impl<'l> LensBoxes<'l> {
	fn new() -> Self {
		LensBoxes(HashMap::new())
	}

	fn total_focusing_power(&self) -> anyhow::Result<u32> {
		self.0
			.iter()
			.map(|(&box_index, lenses)| lenses.focusing_power(box_index))
			.sum()
	}
}

impl<'l, T> From<T> for LensBoxes<'l>
where
	T: Into<HashMap<u8, LensBox<'l>>>,
{
	fn from(value: T) -> Self {
		LensBoxes(value.into())
	}
}

impl<'l> FromIterator<Step<'l>> for LensBoxes<'l> {
	fn from_iter<T: IntoIterator<Item = Step<'l>>>(iter: T) -> Self {
		let mut boxes: LensBoxes<'l> = LensBoxes::new();
		for step in iter {
			let boxx: &mut LensBox<'l> = boxes.0.entry(step.label_hash).or_default();
			match step.operation {
				StepOperation::Remove => boxx.remove(step.label),
				StepOperation::Insert(focal_length) => boxx.insert(step.label, focal_length),
			}
		}
		boxes
	}
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct Step<'l> {
	label: &'l str,
	label_hash: u8,
	operation: StepOperation,
}

impl<'l> Step<'l> {
	fn new(label: &'l str, operation: StepOperation) -> anyhow::Result<Self> {
		Ok(Self {
			label,
			label_hash: hash(label)?,
			operation,
		})
	}
}

impl<'l> TryFrom<&'l str> for Step<'l> {
	type Error = anyhow::Error;

	fn try_from(value: &'l str) -> Result<Self, Self::Error> {
		let i = value.find(['-', '=']).ok_or(anyhow::anyhow!(format!(
			"Step `{value}` does not contain an operation (`-` or `=`)"
		)))?;
		Self::new(&value[..i], value[i..].try_into()?)
	}
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum StepOperation {
	Remove,
	Insert(u8),
}

impl TryFrom<&str> for StepOperation {
	type Error = anyhow::Error;

	fn try_from(s: &str) -> Result<Self, Self::Error> {
		let opcode = s.chars().next().ok_or(anyhow::anyhow!(
			"cannot parse `StepOperation` from empty string"
		))?;

		match (opcode, &s[1..]) {
			('-', "") => Ok(Self::Remove),
			('-', _) => Err(anyhow::anyhow!(
				"remove operation cannot have characters following the `-`"
			)),
			('=', "") => Err(anyhow::anyhow!(
				"insert operation is missing a focal length"
			)),
			('=', focal_length) => Ok(Self::Insert(focal_length.parse()?)),
			(opcode, _) => Err(anyhow::anyhow!(format!(
				"unknown operation `{opcode}`, expected `-` or `=`"
			))),
		}
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_hash() {
		assert_eq!(hash("HASH").unwrap(), 52);
	}

	#[test]
	fn test_step_try_from() {
		assert_eq!(
			Step::try_from("rn=1").unwrap(),
			Step::new("rn", StepOperation::Insert(1)).unwrap()
		);
		assert_eq!(
			Step::try_from("cm-").unwrap(),
			Step::new("cm", StepOperation::Remove).unwrap()
		);
		assert_eq!(
			Step::try_from("qp=3").unwrap(),
			Step::new("qp", StepOperation::Insert(3)).unwrap()
		);
	}

	#[test]
	fn test_total_focusing_power() {
		#[rustfmt::skip]
		let boxes = LensBoxes::from([
			(0, LensBox::from([Lens::new("rn", 1), Lens::new("cm", 2)])),
			(3, LensBox::from([Lens::new("ot", 7), Lens::new("ab", 5), Lens::new("pc", 6)])),
		]);
		assert_eq!(boxes.total_focusing_power().unwrap(), 145);
	}
}
