// TODO: over-engineer even more using clap

use seq_macro::seq;

seq!(N in 01..=15 {
	mod day_~N;
});

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
	let part_two = part == 2;

	let output = seq!(N in 01..=15 {
		match day {
			#(N => day_~N::main(part_two)?.to_string(),)*
			_ => panic!("Day {} not implemented", day),
		}
	});

	println!("{}", output);

	Ok(())
}
