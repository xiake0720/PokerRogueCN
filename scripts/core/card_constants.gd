class_name CardConstants
extends RefCounted

const SUITS = ["spades", "hearts", "diamonds", "clubs"]
const SUIT_CN = {
	"spades": "黑桃",
	"hearts": "红桃",
	"diamonds": "方片",
	"clubs": "梅花"
}
const SUIT_SYMBOL = {
	"spades": "♠",
	"hearts": "♥",
	"diamonds": "♦",
	"clubs": "♣"
}
const RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const RANK_VALUE = {
	"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
	"10": 10, "J": 10, "Q": 10, "K": 10, "A": 11
}
const RANK_ORDER = {
	"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
	"10": 10, "J": 11, "Q": 12, "K": 13, "A": 14
}
const FACE_RANKS = ["J", "Q", "K"]

static func card_title(card: Dictionary) -> String:
	var rank: String = str(card.get("rank", "?"))
	var suit: String = str(card.get("suit", ""))
	var title: String = str(SUIT_SYMBOL.get(suit, "?")) + rank
	var enhancement: String = str(card.get("enhancement", ""))
	if enhancement != "":
		title += "\n" + enhancement
	return title

static func card_chip_value(card: Dictionary) -> int:
	if card.get("enhancement", "") == "stone":
		return 50 + int(card.get("chip_bonus", 0))
	return int(RANK_VALUE.get(str(card.get("rank", "2")), 0)) + int(card.get("chip_bonus", 0))

static func rank_order(rank: String) -> int:
	return int(RANK_ORDER.get(rank, 0))

static func is_face(card: Dictionary, all_faces: bool = false) -> bool:
	if all_faces:
		return true
	return FACE_RANKS.has(str(card.get("rank", "")))
