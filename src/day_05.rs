use std::collections::HashMap;

struct AlmanacEntry {
	destination_range_start: u32,
	source_range_start: u32,
	range_length: u32,
}

type Almanac = HashMap<String, (String, Vec<AlmanacEntry>)>;
// oh boy premature optimization
// trying to predict part 2 :) let's see how it goes

pub fn solve(mut lines: impl Iterator<Item = String>) -> u32 {
	// remove `seeds: ` label
	let seeds = &lines.next().unwrap()[7..]
		.split(" ")
		.map(|s| s.parse::<u32>().unwrap())
		.collect::<Vec<u32>>();

	let almanac = parse_alamanac(lines);

	return 0;
	// return seeds.iter().map(|seed| get_locations(&almanac, seed)).sum();
}

fn get_locations(almanac: &Almanac, seed: &u32) -> Vec<u32> {
	return get_locations_recursive(almanac, "seed", seed);
}

fn get_locations_recursive(almanac: &Almanac, source: &str, id: &u32) -> Vec<u32> {
	let (destination, entries) = almanac.get(source).unwrap();

	let next_ids = entries.iter().filter_map(|entry| {
		if *id >= entry.source_range_start && *id < entry.source_range_start + entry.range_length {
			return Some(entry.destination_range_start + *id - entry.source_range_start);
		}
		return None;
	});

	let mut locations = Vec::new();
	next_ids.for_each(|next_id| {
		if destination == "location" {
			return locations.push(next_id);
		}
		locations.extend(get_locations_recursive(almanac, destination, &next_id));
	});
	return locations;
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
		assert_eq!(solve(almanac.iter().map(|s| s.to_string())), 13);
	}
}
