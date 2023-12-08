use std::cmp::Ordering::{self, Equal};
use std::collections::{HashMap, HashSet};

const STRENGTHS: [char; 13] = [
	'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A',
];

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
enum HandType {
	HighCard,
	OnePair,
	TwoPair,
	ThreeOfAKind,
	FullHouse,
	FourOfAKind,
	FiveOfAKind,
}

#[derive(Debug, PartialEq, Eq)]
struct Hand {
	cards: String,
	bid: u64,
}

impl Hand {
	fn hand_type(&self) -> HandType {
		let without_jokers = self.cards.chars().filter(|&c| c != 'J');
		let joker_count = self.cards.chars().filter(|&c| c == 'J').count() as u64;
		let uniques = HashSet::<char>::from_iter(without_jokers.clone()).len();
		return match uniques {
			0 | 1 => HandType::FiveOfAKind, // this is 0 when there are 5 jokers
			2 => four_pair_or_full_house(without_jokers, joker_count),
			3 => three_pair_or_two_pair(without_jokers, joker_count),
			4 => HandType::OnePair,
			5 => HandType::HighCard,
			_ => panic!("Invalid hand"),
		};
	}
}

impl PartialOrd for Hand {
	fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
		Some(self.cmp(other))
	}
}

impl Ord for Hand {
	fn cmp(&self, other: &Self) -> Ordering {
		match self.hand_type().cmp(&other.hand_type()) {
			Equal => (&self.cards[..]).cmp_card_strength(&&other.cards[..]),
			ordering => ordering,
		}
	}
}

trait Card {
	fn cmp_card_strength(&self, other: &Self) -> Ordering;
}

impl Card for &str {
	fn cmp_card_strength(&self, other: &&str) -> Ordering {
		let self_first_char = self.chars().next().unwrap();
		let other_first_char = other.chars().next().unwrap();
		if self_first_char != other_first_char {
			let self_strength = STRENGTHS
				.iter()
				.position(|&char| char == self_first_char)
				.unwrap();
			let other_strength = STRENGTHS
				.iter()
				.position(|&char| char == other_first_char)
				.unwrap();
			return self_strength.cmp(&other_strength);
		}
		return (&self[1..]).cmp_card_strength(&&other[1..]);
	}
}

pub fn solve(lines: impl Iterator<Item = String>) -> u64 {
	let mut hands = lines.map(|s| parse_hand(&s)).collect::<Vec<Hand>>();
	hands.sort_unstable();
	return hands
		.iter()
		.enumerate()
		.map(|(i, hand)| (i as u64 + 1) * hand.bid)
		.sum();
}

fn parse_hand(input: &str) -> Hand {
	let (cards, bid) = input.split_once(" ").unwrap();

	return Hand {
		cards: cards.to_string(),
		bid: bid.parse::<u64>().unwrap(),
	};
}

fn four_pair_or_full_house(
	without_jokers: impl Iterator<Item = char>,
	joker_count: u64,
) -> HandType {
	let mut counts = HashMap::<char, u64>::with_capacity(2);
	without_jokers.for_each(|char| {
		counts
			.entry(char)
			.and_modify(|count| *count += 1)
			.or_insert(1);
	});
	let max_count = counts.iter().map(|(_, count)| count).max().unwrap();
	return match max_count + joker_count {
		4 => HandType::FourOfAKind,
		3 => HandType::FullHouse,
		_ => panic!("Invalid hand"),
	};
}

fn three_pair_or_two_pair(
	without_jokers: impl Iterator<Item = char>,
	joker_count: u64,
) -> HandType {
	let mut counts = HashMap::<char, u64>::with_capacity(3);
	without_jokers.for_each(|char| {
		counts
			.entry(char)
			.and_modify(|count| *count += 1)
			.or_insert(1);
	});
	let max_count = counts.iter().map(|(_, count)| count).max().unwrap();
	return match max_count + joker_count {
		3 => HandType::ThreeOfAKind,
		2 => HandType::TwoPair,
		_ => panic!("Invalid hand"),
	};
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_example() {
		let hands = [
			"32T3K 765",
			"T55J5 684",
			"KK677 28",
			"KTJJT 220",
			"QQQJA 483",
		];
		assert_eq!(solve(hands.iter().map(|s| s.to_string())), 5905);
	}
}
