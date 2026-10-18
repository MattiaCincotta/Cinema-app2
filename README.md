# CineTrack 🎬

A modern, high-performance Flutter application designed for movie enthusiasts. CineTrack allows users to explore trending movies, search for specific titles, manage a personal watchlist, and save favorite films directly on their device. 

Built with a focus on clean architecture and smooth user experience, this project serves as a comprehensive showcase of modern mobile development practices.

## ✨ Features

* **Discover & Search:** Browse popular, top-rated, and upcoming movies utilizing the powerful TMDB (The Movie Database) API.
* **Local Storage:** Save favorite movies and manage a custom watchlist persistently on the device without needing an active internet connection.
* **Clean Architecture:** Organized codebase separating presentation, business logic, and data layers for extreme scalability and maintainability.
* **Responsive UI:** Beautiful, dark-themed interface built with a mobile-first approach, featuring smooth animations and glassmorphism elements.

## 🛠 Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** Dart
* **API:** [TMDB API](https://www.themoviedb.org/documentation/api)
* **Local Database:** (e.g., Isar / Hive - *To be defined*)
* **State Management:** (e.g., Riverpod / BLoC - *To be defined*)

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* Flutter SDK (Version 3.10.0 or higher recommended)
* Dart SDK
* An active API Key from TMDB

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/cinetrack.git
   ```
2. Navigate into the project directory:
   ```bash
   cd cinetrack
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Setup your TMDB API Key:
   * Create a `.env` file in the root directory.
   * Add your key: `TMDB_API_KEY=your_api_key_here`
5. Run the app:
   ```bash
   flutter run
   ```

## 📁 Project Structure

The project follows a feature-driven folder structure inside the `lib/` directory:

* `core/`: Global configurations, theme data, constants, and network clients.
* `data/`: API services, local database configuration, and data models.
* `presentation/`: UI components, screens, widgets, and state management controllers.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.