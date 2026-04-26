---
title: "Shadow Hunt - The Half-Second Perception Test"
date: 2026-04-26
categories: [Games, Mobile]
tags: [flutter, perception, hyper-casual, android]
excerpt: "A silhouette flashes for less than a second. Pick the right shape from four. Easy at first. Brutal by round twenty."
featured_image: /assets/games/shadow-hunt-feature.png
---

## Eyes vs. Brain

**Shadow Hunt** is a pure perception test wrapped in arcade clothing. A black shape appears for a fraction of a second, then vanishes. Four shapes wait below. Tap the one that matched. Each correct pick shaves a few milliseconds off the next reveal.

Round one feels trivial. Round twenty the silhouette is gone before your conscious mind has named it. By round fifty you are guessing on instinct alone.

## The Curve That Eats You

Reveal time starts at 700ms and drops by 12ms per correct answer. Around round 35 you hit the floor at 280ms - which is roughly the limit of conscious shape identification for most adults. Past that, only practiced pattern-priming carries you.

The result is a deeply personal skill curve. Where you stop tracks how well your visual cortex has been trained. Two people side by side will diverge sharply after round twenty.

## Built In Flutter

Each shape is rendered with a tiny `CustomPainter`. The full shape library - circle, square, triangle, diamond, hexagon, star, plus, heart - is drawn from primitives. No image assets required. The reveal/hide cycle is a single `AnimatedOpacity` with a 120ms transition driven by a `Timer`.

The game state is six fields. The whole logic loop fits in twenty lines.

## Try It

Source, custom icon, sound effect, release APK on GitHub. Sideload, find your floor, then come back when your eyes are warmed up.
