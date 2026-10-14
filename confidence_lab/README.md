# Confidence Lab

A Flutter app for practising confidence and communication, built around evidence from CBT for social
anxiety (Clark & Wells), inhibitory-learning exposure (Craske et al.) and self-compassion research (Neff).

**100% free and offline.** No paid APIs, no Firebase, no accounts, no servers. Everything is stored on the
phone with `shared_preferences`, and the practice partner runs on the device.

| Area | What it does |
|---|---|
| Onboarding | Difficulty self-rating (7 areas), triggers, goal, baseline check-in |
| Daily session | Micro-lesson → thought record (skippable) → plan a real-world challenge |
| Challenges | Behavioural experiments: write the fear's prediction and its likelihood, pick safety behaviours to drop, then review what actually happened and update the belief |
| Adaptive difficulty | 6 domains × 5 levels. Two successes → step up; feared outcome happened → repeat; two skips → step down. Capped by programme phase |
| Mindset | Thought journal and an ideas library of all lessons |
| Practise | 5 scripted conversations. The other person reacts to whether your reply was clear or vague; at the end you get rule-based feedback on apologies, hedging, put-downs, reasons and length, plus a more direct rewrite of your weakest line |
| Progress | "Fear forecast" chart (predicted vs. updated), weekly confidence index, levels per domain, history. No streaks |
| Profile | Goal, weekly check-in, support info, export all data (JSON to clipboard), delete all data |

## Run it

You need Flutter 3.27+ (Dart 3.6+). Nothing else to sign up for.

```bash
cd confidence_lab
flutter create . --org bw.yourname --platforms=android,ios   # generates android/ and ios/ folders
flutter pub get
flutter test
flutter run
```

To build an APK you can install on any Android phone: `flutter build apk --release`.

## Project layout

```
lib/
  content/      programme phases, 18 lessons, 40 challenges, assessment, check-in items
  logic/        adaptive.dart        personalisation rules (unit tested)
                practice_feedback.dart  offline conversation feedback (unit tested)
  models/       plain data classes with toMap/fromMap
  data/         LocalRepository (on-device), InMemoryRepository (tests),
                LocalPracticeService + scenario scripts
  state/        AppState (ChangeNotifier via provider)
  screens/      UI
  widgets/      shared widgets, dependency-free line chart
test/           adaptive logic, scoring, feedback and practice tests
```

## Trade-offs of staying offline

- **Data lives on one phone.** Uninstalling deletes it; there is no sync between devices. Profile → Export
  copies everything as JSON.
- **The practice partner is scripted**, not an AI. It branches on whether your reply was clear, so it
  rewards directness, but it will not understand the specific content of what you say. Add more
  scenarios or turns in `lib/data/practice_service.dart`.
- **Feedback is pattern-based.** It reliably catches apologies, hedges ("just", "maybe", "kind of"),
  put-downs ("this might be a stupid question") and over-long refusals. It tells users it is automatic.

## Safety and claims

- Messages are checked on-device for crisis language; if found, the role-play stops and shows a
  message pointing to emergency and crisis support.
- The weekly check-in uses original items, not a validated scale. Before reporting outcomes,
  license and add a validated measure (e.g. Brief Fear of Negative Evaluation, Mini-SPIN).
- A high score on the "gets in the way of my life" item shows a card suggesting professional support.
- The app makes no diagnostic or treatment claims.

## Next build (all free)

1. Voice studio: `record` + `just_audio`, recordings kept on the phone, explicit consent.
2. Safety-behaviour experiment in Practise: same scenario twice, with and without the habit, then compare.
3. Gentle daily reminders with `flutter_local_notifications`, no shame-based copy.
4. Import from a JSON export, so users can move to a new phone.
