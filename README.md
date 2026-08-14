# 🌍 Travel Planner - Flutter Application

A comprehensive, clean, and intuitive Travel Planner application built with **Flutter** and **Provider**. Discover amazing destinations, stay updated with real-time weather information, and manage your travel itineraries effortlessly.

---

## 🚀 Features

- **📍 Destination Discovery**: Explore new places and find inspiration for your next trip.
- **☁️ Weather Integration**: Get real-time weather updates for your destinations using the OpenWeather API.
- **📅 Trip Management**: Create and organize your travel plans with ease.
- **✨ Premium UI/UX**: Designed with a focus on modern aesthetics, including shimmer animations and responsive layouts.
- **🔐 Secure Setup**: Environment-based configuration for API keys.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **API Integration**: [http](https://pub.dev/packages/http)
- **Local Storage**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Environment Config**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- **UI Enhancements**: [shimmer_animation](https://pub.dev/packages/shimmer_animation), [another_flushbar](https://pub.dev/packages/another_flushbar)

---

## ⚙️ Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- A valid API Key from [OpenWeatherMap](https://openweathermap.org/api) and [OpenTripMap](https://dev.opentripmap.org/)
and then go to the https://dev.opentripmap.org/examples and scrolle to Code short description there you will find the API key.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/krishna23810/Travel-planner.git
   cd Travel-planner
   ```

2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment**:
   Create a `.env` file in the `lib/` directory and add your API keys:
   ```env
   OPENWEATHER_API_KEY=your_openweather_key
   OPENTRIPMAP_API_KEY=your_opentripmap_key
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 📸 Screenshots

*(Add screenshots here relative to the `assets/` folder)*

---

## 📜 License

Created by **krishna**. Feel free to use and contribute!
