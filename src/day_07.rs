use std::cmp::Ordering::{self, Equal};
use std::collections::{HashMap, HashSet};

const STRENGTHS: [char; 13] = [
	'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A',
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
		let uniques = HashSet::<char>::from_iter(self.cards.chars()).len();
		return match uniques {
			1 => HandType::FiveOfAKind,
			2 => four_pair_or_full_house(&self.cards),
			3 => three_pair_or_two_pair(&self.cards),
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

fn four_pair_or_full_house(hand: &str) -> HandType {
	let mut counts = HashMap::<char, u64>::with_capacity(2);
	for char in hand.chars() {
		counts
			.entry(char)
			.and_modify(|count| *count += 1)
			.or_insert(1);
	}
	return match counts.iter().max_by(|(_, a), (_, b)| a.cmp(b)).unwrap().1 {
		4 => HandType::FourOfAKind,
		3 => HandType::FullHouse,
		_ => panic!("Invalid hand"),
	};
}

fn three_pair_or_two_pair(hand: &str) -> HandType {
	let mut counts = HashMap::<char, u64>::with_capacity(3);
	for char in hand.chars() {
		counts
			.entry(char)
			.and_modify(|count| *count += 1)
			.or_insert(1);
	}
	return match counts.iter().max_by(|(_, a), (_, b)| a.cmp(b)).unwrap().1 {
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
		assert_eq!(solve(hands.iter().map(|s| s.to_string())), 6440);
	}
}
