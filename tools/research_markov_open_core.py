#!/usr/bin/env python3
"""Research-only Markov/Farey experiments for LeanFrontier.

This file is deliberately not a Lean submission. It mirrors the accepted
OrientedNode/child recursion closely enough to test proposed bridges before
formalization.

Experiments:
1. verify-orientation: verify a six-state transducer carrying the planar
   Farey/Markov left-centre-right frame into LeanFrontier's coordinate-labelled
   oriented tree.
2. search-collisions: enumerate the planar Markov tree below a numerical bound
   and look for duplicate maximal Markov labels attached to distinct unordered
   triples.

The collision search is only a sanity check. Failure to find a collision is not
evidence for the open uniqueness conjecture.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from enum import IntEnum
from itertools import product


class Move(IntEnum):
    FIRST = 0
    SECOND = 1
    THIRD = 2


State = tuple[int, int, int]


@dataclass(frozen=True)
class Oriented:
    state: State
    back: Move


def jump(b: int, c: int, a: int) -> int:
    return 3 * b * c - a


def move(which: Move, state: State) -> State:
    x, y, z = state
    if which == Move.FIRST:
        return (jump(y, z, x), y, z)
    if which == Move.SECOND:
        return (x, jump(x, z, y), z)
    return (x, y, jump(x, y, z))


def forward_move(back: Move, direction: bool) -> Move:
    table = {
        Move.FIRST: (Move.SECOND, Move.THIRD),
        Move.SECOND: (Move.FIRST, Move.THIRD),
        Move.THIRD: (Move.FIRST, Move.SECOND),
    }
    return table[back][1 if direction else 0]


def child(node: Oriented, direction: bool) -> Oriented:
    changed = forward_move(node.back, direction)
    return Oriented(move(changed, node.state), changed)


ORIENTED_ROOT = Oriented((1, 1, 2), Move.THIRD)


def follow(bits: tuple[bool, ...]) -> Oriented:
    node = ORIENTED_ROOT
    for bit in bits:
        node = child(node, bit)
    return node


# A frame stores which physical coordinate currently means
# (left Farey boundary, centre/Markov number, right Farey boundary).
Frame = tuple[Move, Move, Move]

# At (1, 2, 1), put the left boundary in coordinate SECOND, the centre in
# coordinate THIRD, and the right boundary in coordinate FIRST. With this
# convention the first classical L/R step maps to Lean false/true.
ROOT_FRAME: Frame = (Move.SECOND, Move.THIRD, Move.FIRST)


def direction_for_changed_coordinate(back: Move, target: Move) -> bool:
    for direction in (False, True):
        if forward_move(back, direction) == target:
            return direction
    raise AssertionError("target must be one of the two non-back coordinates")


def frame_step(frame: Frame, planar_direction: str) -> tuple[bool, Frame]:
    left, centre, right = frame
    if planar_direction == "L":
        out = direction_for_changed_coordinate(centre, right)
        return out, (left, right, centre)
    if planar_direction == "R":
        out = direction_for_changed_coordinate(centre, left)
        return out, (centre, left, right)
    raise ValueError("planar path must contain only L/R")


def translate_planar_path(path: str) -> tuple[tuple[bool, ...], Frame]:
    frame = ROOT_FRAME
    bits: list[bool] = []
    for step in path:
        out, frame = frame_step(frame, step)
        bits.append(out)
    return tuple(bits), frame


@dataclass(frozen=True)
class PlanarNode:
    """Planar Farey/Markov frame (left label, centre label, right label)."""

    left: int
    centre: int
    right: int


PLANAR_ROOT = PlanarNode(1, 2, 1)


def planar_child(node: PlanarNode, direction: str) -> PlanarNode:
    l, m, r = node.left, node.centre, node.right
    if direction == "L":
        return PlanarNode(l, 3 * l * m - r, m)
    if direction == "R":
        return PlanarNode(m, 3 * m * r - l, r)
    raise ValueError("planar path must contain only L/R")


def planar_follow(path: str) -> PlanarNode:
    node = PLANAR_ROOT
    for step in path:
        node = planar_child(node, step)
    return node


def expected_lean_state(planar: PlanarNode, frame: Frame) -> State:
    values = {
        frame[0]: planar.left,
        frame[1]: planar.centre,
        frame[2]: planar.right,
    }
    return (values[Move.FIRST], values[Move.SECOND], values[Move.THIRD])


def all_paths(max_depth: int):
    yield ""
    for depth in range(1, max_depth + 1):
        for letters in product("LR", repeat=depth):
            yield "".join(letters)


def verify_orientation(max_depth: int) -> None:
    checked = 0
    for path in all_paths(max_depth):
        bits, frame = translate_planar_path(path)
        lean = follow(bits)
        planar = planar_follow(path)
        expected = expected_lean_state(planar, frame)
        if lean.state != expected or lean.back != frame[1]:
            raise AssertionError(
                f"orientation mismatch at {path!r}: "
                f"lean={lean}, planar={planar}, frame={frame}, expected={expected}"
            )
        checked += 1

    print(f"verified {checked} planar nodes through depth {max_depth}")
    print("six-state transition table (frame=L/M/R coordinate numbers):")
    reachable = set()
    frontier = [ROOT_FRAME]
    while frontier:
        frame = frontier.pop()
        if frame in reachable:
            continue
        reachable.add(frame)
        for step in "LR":
            _, nxt = frame_step(frame, step)
            frontier.append(nxt)

    def frame_name(frame: Frame) -> str:
        return "".join(str(int(x) + 1) for x in frame)

    for frame in sorted(reachable, key=lambda f: tuple(map(int, f))):
        pieces = []
        for step in "LR":
            bit, nxt = frame_step(frame, step)
            pieces.append(f"{step}->{int(bit)}:{frame_name(nxt)}")
        print(f"  {frame_name(frame)}  " + "  ".join(pieces))

    print("sample planar path -> direct Lean child bits -> sternNode path")
    for path in ("L", "R", "LL", "LR", "RL", "RR", "LLL", "LLR"):
        bits, _ = translate_planar_path(path)
        direct = "".join("R" if b else "L" for b in bits)
        stern = direct[::-1]  # sternNode follows path.reverse
        print(f"  {path:3} -> {direct:3} -> {stern:3}")


def search_collisions(max_label: int) -> None:
    stack: list[tuple[str, PlanarNode]] = [("", PLANAR_ROOT)]
    by_label: dict[int, tuple[str, tuple[int, int, int]]] = {}
    collisions: list[
        tuple[int, tuple[str, tuple[int, int, int]], tuple[str, tuple[int, int, int]]]
    ] = []
    visited = 0
    deepest = 0

    while stack:
        path, node = stack.pop()
        if node.centre > max_label:
            continue
        visited += 1
        deepest = max(deepest, len(path))
        triple = tuple(sorted((node.left, node.centre, node.right)))
        old = by_label.get(node.centre)
        if old is not None and old[1] != triple:
            collisions.append((node.centre, old, (path, triple)))
        else:
            by_label[node.centre] = (path, triple)

        left = planar_child(node, "L")
        right = planar_child(node, "R")
        if left.centre <= max_label:
            stack.append((path + "L", left))
        if right.centre <= max_label:
            stack.append((path + "R", right))

    print(
        f"visited={visited} max_label={max_label} deepest_path={deepest} "
        f"distinct_labels={len(by_label)} collisions={len(collisions)}"
    )
    for item in collisions[:20]:
        print("collision:", item)


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    verify = sub.add_parser("verify-orientation")
    verify.add_argument("--depth", type=int, default=12)

    search = sub.add_parser("search-collisions")
    search.add_argument(
        "--digits",
        type=int,
        default=100,
        help="search nodes with centre Markov label <= 10**digits",
    )

    args = parser.parse_args()
    if args.command == "verify-orientation":
        verify_orientation(args.depth)
    elif args.command == "search-collisions":
        search_collisions(10 ** args.digits)


if __name__ == "__main__":
    main()
