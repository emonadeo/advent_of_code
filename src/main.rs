use std::{
	fs::File,
	io::{BufRead, BufReader},
};

mod day_01;
mod day_02;
mod day_03;
mod day_04;
mod day_05;

fn main() -> Result<(), Box<dyn std::error::Error>> {
	let mut input = String::new();
	println!("Enter a day (1-24)");
	std::io::stdin().read_line(&mut input)?;
	let day: u8 = input.trim().parse()?;
	let input_lines_iter = read_input(day)?;

	let output = match day {
		1 => day_01::solve(input_lines_iter).to_string(),
		2 => day_02::solve(input_lines_iter).to_string(),
		3 => day_03::solve(input_lines_iter).to_string(),
		4 => day_04::solve(input_lines_iter).to_string(),
		5 => day_05::solve(input_lines_iter).to_string(),
		_ => format!("Day {} not implemented yet.", day),
	};

	println!("{}", output);

	Ok(())
}

fn read_input(day: u8) -> Result<impl Iterator<Item = String>, Box<dyn std::error::Error>> {
	let filename = format!("input/day_{:02}.txt", day);
	let file = File::open(filename)?;
	let reader = BufReader::new(file);
	return Ok(reader.lines().map(|l| l.unwrap()));
}
