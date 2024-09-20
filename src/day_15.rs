use std::collections::HashMap;

pub fn solve(part_two: bool, mut lines: impl Iterator<Item = String>) -> anyhow::Result<u32> {
	let line = lines.next().ok_or(anyhow::anyhow!("No input"))?;
	let steps = line.split(',');
	if !part_two {
		return Ok(steps.map(hash).map(|s| s as u32).sum());
	}
	return focusing_power(steps);
}

fn hash(input: &str) -> u8 {
	input.chars().fold(0u8, |acc, char| {
		let ascii_code: u8 = char.try_into().unwrap();
		acc.wrapping_add(ascii_code).wrapping_mul(17)
	})
}

fn focusing_power<'a>(steps: impl IntoIterator<Item = &'a str>) -> anyhow::Result<u32> {
	let mut boxes: HashMap<u8, Vec<Lens>> = HashMap::new();
	for step in steps {
		let i = step.find(['-', '=']).ok_or(anyhow::anyhow!(format!(
			"Step `{step}` does not contain an operation (`-` or `=`)"
		)))?;
		let label: &str = &step[..i];
		let operation: char = step.chars().nth(i).unwrap();

		let lens_box = boxes.entry(hash(label)).or_default();
		match operation {
			'-' => {
				lens_box
					.iter()
					.position(|lens| lens.label == label)
					.inspect(|&i| {
						lens_box.remove(i);
					});
			}
			'=' => {
				let focal_length: u8 = step[i + 1..].parse::<u8>()?;
				match lens_box.iter_mut().find(|lens| lens.label == label) {
					Some(lens) => lens.focal_length = focal_length,
					None => lens_box.push(Lens {
						label,
						focal_length,
					}),
				}
			}
			_ => unreachable!(),
		};
	}

	let focusing_power: u32 = boxes
		.iter()
		.flat_map(|(&box_number, lenses)| {
			lenses.iter().enumerate().map(move |(slot, lens)| {
				(box_number as u32 + 1) * (slot as u32 + 1) * lens.focal_length as u32
			})
		})
		.sum();

	Ok(focusing_power)
}

struct Lens<'a> {
	label: &'a str,
	focal_length: u8,
}

#[cfg(test)]
mod tests {
	use super::*;

	mod part_1 {
		use super::*;

		#[test]
		fn test_hash() {
			assert_eq!(hash("HASH"), 52);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_focusing_power() {
			assert_eq!(
				focusing_power([
					"rn=1", "cm-", "qp=3", "cm=2", "qp-", "pc=4", "ot=9", "ab=5", "pc-", "pc=6",
					"ot=7"
				])
				.unwrap(),
				145
			);
		}
	}
}
