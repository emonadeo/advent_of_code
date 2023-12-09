use std::collections::HashMap;

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
		return match direction {
			Direction::Left => &self.nodes.get(node).unwrap().0,
			Direction::Right => &self.nodes.get(node).unwrap().1,
		};
	}

	fn count_steps(&self, start_node: &str, target_node: &str) -> u64 {
		return self.count_steps_recursive(
			start_node,
			target_node,
			self.directions.iter().cloned().cycle(),
		);
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
		return 1 + self.count_steps_recursive(next_node, target_node, directions);
	}
}

pub fn solve(lines: impl Iterator<Item = String>) -> u64 {
	let network = parse_network(lines);
	return network.count_steps("AAA", "ZZZ");
}

fn parse_network(mut input: impl Iterator<Item = String>) -> Network {
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

	return Network { directions, nodes };
}

fn parse_network_entry(entry: &str) -> (String, (String, String)) {
	let (source_node, target_nodes) = entry.split_once(" = ").unwrap();
	let (left_node, right_node) = &target_nodes[1..target_nodes.len() - 1]
		.split_once(", ")
		.unwrap();
	return (
		source_node.to_string(),
		(left_node.to_string(), right_node.to_string()),
	);
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
		assert_eq!(solve(network.iter().map(|s| s.to_string())), 2);
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
		assert_eq!(solve(network.iter().map(|s| s.to_string())), 6);
	}
}
