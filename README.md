# FoodSnap 🍕

> AI-powered food nutrition analyzer.
> Snap a meal, get instant nutrition facts.

---

## 📱 Screenshots

| Home – Light | Home – Dark | Detail – Light | Detail – Dark |
|---|---|---|---|
| <img src="https://github.com/user-attachments/assets/c6103ff9-28ad-47a2-81c9-534454cfc8c6" width="200"/> | <img src="https://github.com/user-attachments/assets/3e2fb7f4-f946-4788-a79e-62c8361f9301" width="200"/> | <img src="https://github.com/user-attachments/assets/cc62f7b3-cba7-45c1-b2a4-914f57376db2" width="200"/> | <img src="https://github.com/user-attachments/assets/5c4c286e-7b72-47b7-b427-f8317c3cd87b" width="200"/> |

---

## ✨ Features

- 📷 Camera and gallery image capture
- 🤖 AI-powered nutrition analysis
- 🗂 Persistent history across app restarts
- 🌓 Light and Dark mode with persistence
- 🗑 Swipe to delete history items
- 🔄 Pull to refresh history
- ⚡ Skeleton loading states
- 🚨 Full error handling with retry

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart |
| State Management | flutter_bloc (BLoC + Cubit) |
| Navigation | go_router |
| Local Storage | sqflite (SQLite) |
| AI Provider | Google Gemini 2.5 Flash |
| Architecture | Clean Architecture, Feature-first |

---

## 🏗 Architecture

Clean Architecture with Feature-first 
folder structure.

```
lib/
├── core/              # Theme, navigation, DI, utils
├── data/              # SQLite, AI providers, repositories
│   ├── ai/            # Gemini, Claude, OpenAI providers
│   ├── database/      # SQLite helper
│   └── repositories/  # Repository implementations
├── domain/            # Entities, use cases, contracts
└── presentation/
    ├── home/          # Screen 1 — bloc, screen, widgets
    └── result_detail/ # Screen 2 — bloc, screen, widgets
```

### AI Provider — SOLID Design

Switch between Gemini, Claude, or OpenAI 
with a single `.env` change. No code changes needed.

```
AiProvider (abstract)
├── GeminiProvider   ← active
├── ClaudeProvider   ← ready
└── OpenAiProvider   ← ready
```

```env
AI_PROVIDER=gemini   # or claude / openai
```

---

## 🚀 Setup

### Prerequisites
- Flutter SDK >= 3.0.0
- A Gemini API key — [aistudio.google.com](https://aistudio.google.com)

### Steps

```bash
# 1. Clone
git clone https://github.com/moaz126/foodsnap.git
cd foodsnap

# 2. Install dependencies
flutter pub get

# 3. Setup environment
cp .env.example .env
# Add your API key to .env

# 4. Generate dependency injection code
dart run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

### Environment Variables

```env
AI_PROVIDER=gemini
GEMINI_API_KEY=your_key_here
ANTHROPIC_API_KEY=optional
OPENAI_API_KEY=optional
```

Get a free Gemini key at 
[aistudio.google.com](https://aistudio.google.com)

---

## 📱 Permissions

| Platform | Permission | Reason |
|---|---|---|
| iOS | Camera | Food photo capture |
| iOS | Photo Library | Gallery selection |
| Android | CAMERA | Food photo capture |
| Android | READ_MEDIA_IMAGES | Gallery selection |
| Android | INTERNET | AI API calls |

---

## 🗄 Database Schema

```sql
CREATE TABLE food_records (
  id                 TEXT PRIMARY KEY,
  image_uri          TEXT NOT NULL,
  detected_food_name TEXT NOT NULL,
  cuisine_tags       TEXT NOT NULL,
  confidence_percent REAL NOT NULL,
  calories           REAL NOT NULL,
  protein            REAL NOT NULL,
  carbs              REAL NOT NULL,
  fat                REAL NOT NULL,
  fiber              REAL,
  sugar              REAL,
  sodium             REAL,
  serving_size       TEXT,
  raw_api_summary    TEXT NOT NULL,
  created_at         TEXT NOT NULL
);
```

Images are saved to 
`getApplicationDocumentsDirectory()` 
before the path is stored — ensures 
persistence across app restarts.

---

## ⚖️ Trade-offs & Decisions

**BLoC over Riverpod/Provider**

Explicit event→state flow makes async 
operations like API calls easy to trace 
and test.

**sqflite over Hive/Isar**

Structured relational data fits SQL 
naturally. No code generation required.

**go_router over Navigator 2.0**

Declarative routing with type-safe 
extras. Deep link support ready out of 
the box.

**Direct HTTP over SDK packages**

All AI providers use raw http calls — 
consistent pattern, full control, 
no extra packages.

**Feature-first over Layer-first**

Each feature folder is self-contained. 
Easy to add, remove, or move features 
as app grows.

---

## 🔧 With More Time

- Image compression with 
  flutter_image_compress
- UI enhancement 
- Animations — hero transitions, 
  Lottie empty states, micro-interactions
- CI/CD with GitHub Actions — 
  auto test, build, and deploy on merge
- Integration and golden tests
- Pagination for large history lists
- Offline queue for failed API calls
- Theme control on Splash Screen
- Crash reporting with Firebase Crashlytics 
  or Sentry for production error monitoring

---

## 🧪 Tests

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
```

**26 tests** across:
- Model serialization
- BLoC state transitions
- Cubit state transitions  
- Widget rendering

---

## 👨‍💻 Author

**Muhammad Moaz**
Senior Flutter Developer
[muhammadmoaz.dev](https://muhammadmoaz.dev) ·
[GitHub @moaz126](https://github.com/moaz126)

---

> ⚠️ Nutrition values are AI estimates only
> — not a substitute for medical advice.
