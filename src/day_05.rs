use std::collections::HashMap;

struct AlmanacEntry {
	destination_range_start: u64,
	source_range_start: u64,
	range_length: u64,
}

type Almanac = HashMap<String, (String, Vec<AlmanacEntry>)>;
// oh boy premature optimization
// trying to predict part 2 :) let's see how it goes

pub fn solve(mut lines: impl Iterator<Item = String>) -> u64 {
	// remove `seeds: ` label
	let seeds = &lines.next().unwrap()[7..]
		.split(" ")
		.map(|s| s.parse().unwrap())
		.collect::<Vec<u64>>();

	let almanac = parse_alamanac(lines);

	return seeds
		.iter()
		.map(|seed| get_location(&almanac, seed))
		.min()
		.unwrap();
}

fn get_location(almanac: &Almanac, seed: &u64) -> u64 {
	return get_until_location(almanac, "seed", seed).1;
}

fn get_until_location(almanac: &Almanac, source: &str, id: &u64) -> (String, u64) {
	if source == "location" {
		return (source.to_string(), *id);
	}

	let (destination, entries) = almanac.get(source).unwrap();

	let next_id = entries.iter().find_map(|entry| {
		if *id >= entry.source_range_start && *id < entry.source_range_start + entry.range_length {
			return Some(entry.destination_range_start + *id - entry.source_range_start);
		}
		return None;
	});

	// TODO: Unnecessary copy of `id`
	return get_until_location(almanac, destination, &next_id.unwrap_or(*id));
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
