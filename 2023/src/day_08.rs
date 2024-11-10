use std::collections::HashMap;

const INPUT: &'static str = include_str!("../../inputs/2023/day_08.txt");

pub fn main(part_two: bool) -> anyhow::Result<u64> {
	if part_two {
		todo!();
	}
	Ok(solve_part_1(INPUT.lines()))
}

fn solve_part_1(lines: impl IntoIterator<Item = &'static str>) -> u64 {
	let network = parse_network(lines);
	network.count_steps("AAA", "ZZZ")
}

#[derive(Copy, Clone)]
enum Direction {
	Left,
	Right,
}

impl Direction {
	fn parse(input: char) -> Direction {
		match input {
			'L' => Direction::Left,
			'R' => Direction::Right,
			_ => panic!("Invalid direction"),
		}
	}
}

struct Network {
	directions: Vec<Direction>,
	nodes: HashMap<String, (String, String)>,
}

impl Network {
	fn next_node(&self, node: &str, direction: &Direction) -> &str {
		match direction {
			Direction::Left => &self.nodes.get(node).unwrap().0,
			Direction::Right => &self.nodes.get(node).unwrap().1,
		}
	}

	fn count_steps(&self, start_node: &str, target_node: &str) -> u64 {
		self.count_steps_recursive(
			start_node,
			target_node,
			self.directions.iter().cloned().cycle(),
		)
	}

	fn count_steps_recursive(
		&self,
		start_node: &str,
		target_node: &str,
		mut directions: impl Iterator<Item = Direction>,
	) -> u64 {
		if start_node == target_node {
			return 0;
		}

		let next_node = self.next_node(start_node, &directions.next().unwrap());
		1 + self.count_steps_recursive(next_node, target_node, directions)
	}
}

fn parse_network(input: impl IntoIterator<Item = &'static str>) -> Network {
	let mut input = input.into_iter();
	let directions = input
		.next()
		.unwrap()
		.chars()
		.map(Direction::parse)
		.collect();

	let _ = input.next(); // skip empty line

	let nodes = input
		.map(|entry| parse_network_entry(&entry))
		.collect::<HashMap<String, (String, String)>>();

	Network { directions, nodes }
}

fn parse_network_entry(entry: &str) -> (String, (String, String)) {
	let (source_node, target_nodes) = entry.split_once(" = ").unwrap();
	let (left_node, right_node) = &target_nodes[1..target_nodes.len() - 1]
		.split_once(", ")
		.unwrap();

	(
		source_node.to_string(),
		(left_node.to_string(), right_node.to_string()),
	)
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_example() {
		let network = [
			"RL",
			"",
			"AAA = (BBB, CCC)",
			"BBB = (DDD, EEE)",
			"CCC = (ZZZ, GGG)",
			"DDD = (DDD, DDD)",
			"EEE = (EEE, EEE)",
			"GGG = (GGG, GGG)",
			"ZZZ = (ZZZ, ZZZ)",
		];
		assert_eq!(solve_part_1(network), 2);
	}

	#[test]
	fn test_example_2() {
		let network = [
			"LLR",
			"",
			"AAA = (BBB, BBB)",
			"BBB = (AAA, ZZZ)",
			"ZZZ = (ZZZ, ZZZ)",
		];
		assert_eq!(solve_part_1(network), 6);
	}
}
