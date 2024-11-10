// TODO: over-engineer even more using clap

use seq_macro::seq;
use std::{
	fs::File,
	io::{BufRead, BufReader},
};

seq!(N in 01..=24 {
	mod day_~N;
});

type Solve<TInput, TOutput> = fn(part_two: bool, input: TInput) -> anyhow::Result<TOutput>;

fn solve<TInput>(day: u8) -> Solve<TInput, String>
where
	TInput: Iterator<Item = String>,
{
	seq!(N in 01..=24 {
		return match day {
			#(N => |part_two, input| Ok(day_~N::solve(part_two, input)?.to_string()),)*
			_ => panic!("Day {} not implemented", day),
		}
	});
}

fn main() -> anyhow::Result<()> {
	let mut day_input = String::new();
	println!("Enter a day (1-24)");
	std::io::stdin().read_line(&mut day_input)?;
	let day: u8 = day_input.trim().parse()?;

	let mut part_input = String::new();
	println!("Enter a part (1)");
	std::io::stdin().read_line(&mut part_input)?;
	let part_input = part_input.trim();
	let part: u8 = if !part_input.is_empty() {
		part_input.parse()?
	} else {
		1
	};

	let input_lines = read_input(day)?;

	let output = solve(day)(part == 2, input_lines)?.to_string();
	println!("{}", output);

	return Ok(());
}

fn read_input(day: u8) -> anyhow::Result<impl Iterator<Item = String>> {
	let filename = format!("inputs/day_{:02}.txt", day);
	let file = File::open(filename)?;
	let reader = BufReader::new(file);
	return Ok(reader.lines().map(|l| l.unwrap()));
}
