use std::cmp::Ordering::{self, Equal};
use std::collections::{HashMap, HashSet};

pub fn solve(part_two: bool, lines: impl Iterator<Item = String>) -> anyhow::Result<u64> {
	let mut hands = lines
		.map(|s| parse_hand(&s, part_two))
		.collect::<Result<Vec<_>, _>>()?;
	hands.sort_unstable();
	let result = hands
		.iter()
		.enumerate()
		.map(|(i, hand)| (i as u64 + 1) * hand.bid)
		.sum();
	return Ok(result);
}

#[derive(Debug, PartialEq, Eq)]
struct Hand {
	cards: [Card; 5],
	bid: u64,
}

impl Hand {
	fn joker_count(&self) -> u64 {
		self.cards.iter().filter(|&&c| c == Card::Joker).count() as u64
	}

	fn hand_type(&self) -> HandType {
		let without_jokers = self.cards.into_iter().filter(|&c| c != Card::Joker);
		let uniques = HashSet::<Card>::from_iter(without_jokers.clone()).len();
		return match uniques {
			0 | 1 => HandType::FiveOfAKind, // this is 0 when there are 5 jokers
			2 => four_pair_or_full_house(without_jokers, self.joker_count()),
			3 => three_pair_or_two_pair(without_jokers, self.joker_count()),
			4 => HandType::OnePair,
			5 => HandType::HighCard,
			_ => panic!("invalid hand"),
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
		if self.hand_type().cmp(&other.hand_type()) != Equal {
			return self.hand_type().cmp(&other.hand_type());
		}

		for i in 0..5 {
			match self.cards[i].cmp(&other.cards[i]) {
				Equal => continue,
				ordering => return ordering,
			}
		}
		return Ordering::Equal;
	}
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Clone, Copy)]
enum Card {
	Joker,
	Two,
	Three,
	Four,
	Five,
	Six,
	Seven,
	Eight,
	Nine,
	Ten,
	Jack,
	Queen,
	King,
	Ace,
}

impl Card {
	fn try_from_char(value: char, replace_jack_with_joker: bool) -> anyhow::Result<Self> {
		return match (value, replace_jack_with_joker) {
			('2', _) => Ok(Card::Two),
			('3', _) => Ok(Card::Three),
			('4', _) => Ok(Card::Four),
			('5', _) => Ok(Card::Five),
			('6', _) => Ok(Card::Six),
			('7', _) => Ok(Card::Seven),
			('8', _) => Ok(Card::Eight),
			('9', _) => Ok(Card::Nine),
			('T', _) => Ok(Card::Ten),
			('J', false) => Ok(Card::Jack),
			('J', true) => Ok(Card::Joker),
			('Q', _) => Ok(Card::Queen),
			('K', _) => Ok(Card::King),
			('A', _) => Ok(Card::Ace),
			_ => Err(anyhow::anyhow!("invalid card '{}'", value)),
		};
	}
}

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

fn parse_hand(input: &str, replace_jack_with_joker: bool) -> anyhow::Result<Hand> {
	let (cards, bid) = input.split_once(" ").ok_or(anyhow::anyhow!(
		"expected input to contain a space delimiting the cards and bid, got {}",
		input
	))?;

	let result = Hand {
		cards: cards
			.chars()
			.map(|char| Card::try_from_char(char, replace_jack_with_joker))
			.collect::<Result<Vec<_>, _>>()?
			.try_into()
			.or_else(|cards: Vec<_>| {
				Err(anyhow::anyhow!("expected 5 cards, got {}", cards.len()))
			})?,
		bid: bid.parse::<u64>()?,
	};

	return Ok(result);
}

fn four_pair_or_full_house(
	without_jokers: impl Iterator<Item = Card>,
	joker_count: u64,
) -> HandType {
	let mut counts = HashMap::<Card, u64>::with_capacity(2);
	without_jokers.for_each(|card| {
		counts
			.entry(card)
			.and_modify(|count| *count += 1)
			.or_insert(1);
	});
	let max_count = counts.iter().map(|(_, count)| count).max().unwrap();
	return match max_count + joker_count {
		4 => HandType::FourOfAKind,
		3 => HandType::FullHouse,
		_ => panic!("invalid hand"),
	};
}

fn three_pair_or_two_pair(
	without_jokers: impl Iterator<Item = Card>,
	joker_count: u64,
) -> HandType {
	let mut counts = HashMap::<Card, u64>::with_capacity(3);
	without_jokers.for_each(|card| {
		counts
			.entry(card)
			.and_modify(|count| *count += 1)
			.or_insert(1);
	});
	let max_count = counts.iter().map(|(_, count)| count).max().unwrap();
	return match max_count + joker_count {
		3 => HandType::ThreeOfAKind,
		2 => HandType::TwoPair,
		_ => panic!("invalid hand"),
	};
}

#[cfg(test)]
mod tests {
	use super::*;

	const EXAMPLE_LINES: [&str; 5] = [
		"32T3K 765",
		"T55J5 684",
		"KK677 28",
		"KTJJT 220",
		"QQQJA 483",
	];

	mod part_1 {
		use super::*;

		#[test]
		fn test_example() {
			assert_eq!(
				solve(false, EXAMPLE_LINES.iter().map(|s| s.to_string())).unwrap(),
				6440
			);
		}
	}

	mod part_2 {
		use super::*;

		#[test]
		fn test_example() {
			assert_eq!(
				solve(true, EXAMPLE_LINES.iter().map(|s| s.to_string())).unwrap(),
				5905
			);
		}
	}
}
