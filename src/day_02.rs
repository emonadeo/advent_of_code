#[derive(Debug, PartialEq)]
struct Game {
	id: u32,
	reds: u32,
	greens: u32,
	blues: u32,
}

pub fn solve(lines: impl Iterator<Item = String>) -> u32 {
	valid_game_ids(lines).sum()
}

fn valid_game_ids(lines: impl Iterator<Item = String>) -> impl Iterator<Item = u32> {
	return lines.filter_map(|line| parse_game(&line));
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
	return true;
}

fn parse_color_count(input: &str) -> (u32, &str) {
	let (amount, color) = input.split_once(" ").unwrap();
	return (amount.parse::<u32>().unwrap(), color);
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
		assert_eq!(solve(games.iter().map(|s| s.to_string())), 8);
	}
}
