use core::panic;

#[derive(Debug, PartialEq)]
struct Game {
	id: u32,
	reds: u32,
	greens: u32,
	blues: u32,
}

pub fn sum_valid_game_ids(lines: impl Iterator<Item = String>) -> u32 {
	valid_game_ids(lines).sum()
}

fn valid_game_ids(lines: impl Iterator<Item = String>) -> impl Iterator<Item = u32> {
	lines
		.map(|lines| parse_game(&lines))
		.filter(|game| is_valid_game(&game))
		.map(|game| game.id)
}

fn parse_game(input: &String) -> Game {
	let input_without_game = &input[5..]; // strip "Game "
	let (id, payload) = input_without_game.split_once(": ").unwrap();
	let id = id.parse::<u32>().unwrap();

	let sets_iter = payload.split("; ");
	let (reds, greens, blues) = sets_iter
		.map(|set| parse_set(set))
		.fold((0, 0, 0), sum_colors);

	return Game {
		id,
		reds,
		greens,
		blues,
	};
}

fn parse_set(input: &str) -> (u32, u32, u32) {
	let mut reds = 0;
	let mut greens = 0;
	let mut blues = 0;

	let colors = input.split(", ");
	colors.for_each(|color| match color.split_once(" ") {
		Some((n, "red")) => reds = n.parse().unwrap(),
		Some((n, "green")) => greens = n.parse().unwrap(),
		Some((n, "blue")) => blues = n.parse().unwrap(),
		_ => panic!(),
	});

	return (reds, greens, blues);
}

fn sum_colors((r1, g1, b1): (u32, u32, u32), (r2, g2, b2): (u32, u32, u32)) -> (u32, u32, u32) {
	(r1 + r2, g1 + g2, b1 + b2)
}

fn is_valid_game(game: &Game) -> bool {
	return game.reds <= 12 && game.greens <= 13 && game.blues <= 14;
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
		assert_eq!(sum_valid_game_ids(games.iter().map(|s| s.to_string())), 8);
	}

	#[test]
	fn test_parse_game() {
		let game = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green";
		assert_eq!(
			parse_game(&game.to_string()),
			Game {
				id: 1,
				reds: 5,
				greens: 4,
				blues: 9,
			}
		);
	}
}
