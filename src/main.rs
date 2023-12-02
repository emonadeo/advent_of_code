use std::{
	fs::File,
	io::{BufRead, BufReader},
};

mod day_01;

fn main() -> Result<(), Box<dyn std::error::Error>> {
	let mut input = String::new();
	println!("Enter a day (1-24)");
	std::io::stdin().read_line(&mut input)?;
	let day: u8 = input.trim().parse()?;

	println!(
		"{}",
		match day {
			1 => day_01::calibration_value(read_input(day)?).to_string(),
			_ => format!("Day {} not implemented yet.", day),
		}
	);

	Ok(())
}

fn read_input<'a>(day: u8) -> Result<impl Iterator<Item = String>, Box<dyn std::error::Error>> {
	let filename = format!("input/day_{:02}.txt", day);
	let file = File::open(filename)?;
	let reader = BufReader::new(file);
	return Ok(reader.lines().map(|l| l.unwrap()));
}
