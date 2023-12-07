use std::collections::HashMap;

#[derive(Debug)]
struct AlmanacEntry {
	destination_range_start: u64,
	source_range_start: u64,
	range_length: u64,
}

type Almanac = HashMap<String, (String, Vec<AlmanacEntry>)>;

pub fn solve(mut lines: impl Iterator<Item = String>) -> u64 {
	// strip `seeds: ` label
	let seeds = parse_seeds(&lines.next().unwrap()[7..]);

	let almanac = parse_alamanac(lines);

	let mut cache = HashMap::new();
	return seeds
		.iter()
		.map(|seed| get_location(&almanac, &mut cache, seed))
		.min()
		.unwrap();
}

fn parse_seeds(input: &str) -> Vec<u64> {
	let mut seed_configs = input.split(" ").map(|s| s.parse::<u64>().unwrap());
	let mut seeds = Vec::<u64>::new();
	while let Some(start_range) = seed_configs.next() {
		let length = seed_configs.next().unwrap();
		seeds.append(&mut (start_range..start_range + length).collect::<Vec<u64>>());
	}
	return seeds;
}

fn get_location(almanac: &Almanac, cache: &mut HashMap<(String, u64), u64>, seed: &u64) -> u64 {
	return get_until_location(almanac, cache, "seed", seed);
}

fn get_until_location(
	almanac: &Almanac,
	cache: &mut HashMap<(String, u64), u64>,
	source: &str,
	id: &u64,
) -> u64 {
	if source == "location" {
		return *id;
	}

	if let Some(cached) = cache.get(&(source.to_string(), *id)) {
		return *cached;
	}

	let (destination, entries) = almanac.get(source).unwrap();

	let next_id = entries.iter().find_map(|entry| {
		if *id >= entry.source_range_start && *id < entry.source_range_start + entry.range_length {
			return Some(entry.destination_range_start + *id - entry.source_range_start);
		}
		return None;
	});

	let next_id = &next_id.unwrap_or(*id);

	cache.insert((source.to_string(), *id), *next_id);

	// TODO: Unnecessary copy of `id`
	return get_until_location(almanac, cache, destination, next_id);
}

fn parse_alamanac(mut lines: impl Iterator<Item = String>) -> Almanac {
	let mut almanac = Almanac::new();

	// these should be `Option<String>` with inital value `None` but idc
	let mut current_source = String::new();
	let mut current_destination = String::new();

	while let Some(line) = lines.next() {
		if line.is_empty() {
			(current_source, current_destination) = parse_category(&lines.next().unwrap());
			continue;
		}

		let entries = match almanac.get_mut(&current_source) {
			Some((_, entries)) => entries,
			None => {
				almanac.insert(
					current_source.clone(),
					(current_destination.clone(), Vec::new()),
				);
				&mut almanac.get_mut(&current_source).unwrap().1
			}
		};

		entries.push(parse_entry(&line));
	}

	return almanac;
}

fn parse_entry(input: &str) -> AlmanacEntry {
	let mut numbers = input.split(" ").map(|s| s.parse().unwrap());

	return AlmanacEntry {
		destination_range_start: numbers.next().unwrap(),
		source_range_start: numbers.next().unwrap(),
		range_length: numbers.next().unwrap(),
	};
}

fn parse_category(input: &str) -> (String, String) {
	let (source, destination) = input.split_once(" ").unwrap().0.split_once("-to-").unwrap();
	return (source.to_string(), destination.to_string());
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_part_1() {
		let almanac = [
			"seeds: 79 14 55 13",
			"",
			"seed-to-soil map:",
			"50 98 2",
			"52 50 48",
			"",
			"soil-to-fertilizer map:",
			"0 15 37",
			"37 52 2",
			"39 0 15",
			"",
			"fertilizer-to-water map:",
			"49 53 8",
			"0 11 42",
			"42 0 7",
			"57 7 4",
			"",
			"water-to-light map:",
			"88 18 7",
			"18 25 70",
			"",
			"light-to-temperature map:",
			"45 77 23",
			"81 45 19",
			"68 64 13",
			"",
			"temperature-to-humidity map:",
			"0 69 1",
			"1 0 69",
			"",
			"humidity-to-location map:",
			"60 56 37",
			"56 93 4",
		];
		assert_eq!(solve(almanac.iter().map(|s| s.to_string())), 35);
	}
}
