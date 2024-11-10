const INPUT: &'static str = include_str!("../../inputs/2023/day_02.txt");

pub fn main(part_two: bool) -> anyhow::Result<u32> {
	if part_two {
		todo!();
	}
	Ok(solve_part_1(INPUT.lines()))
}

fn solve_part_1(lines: impl IntoIterator<Item = &'static str>) -> u32 {
	lines.into_iter().filter_map(parse_game).sum()
}

fn parse_game(input: &str) -> Option<u32> {
	let input_without_game = &input[5..]; // strip "Game "
	let (id, payload) = input_without_game.split_once(": ").unwrap();

	if payload.split("; ").any(|set| !is_valid_set(set)) {
		None
	} else {
		Some(id.parse::<u32>().unwrap())
	}
}

fn is_valid_set(input: &str) -> bool {
	let color_counts = input.split(", ").map(parse_color_count);
	for color_count in color_counts {
		match color_count {
			(..=12, "red") => continue,
			(..=13, "green") => continue,
			(..=14, "blue") => continue,
			_ => return false,
		}
	}
	true
}

fn parse_color_count(input: &str) -> (u32, &str) {
	let (amount, color) = input.split_once(" ").unwrap();
	(amount.parse::<u32>().unwrap(), color)
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_part_1() {
		let games = [
			"Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
			"Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
			"Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
			"Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
			"Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
		];
		assert_eq!(solve_part_1(games), 8);
	}
}
