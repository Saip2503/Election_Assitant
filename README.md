# Election Dost (Civic Pulse) 🗳️🇮🇳

**Election Dost** is a premium, AI-powered civic engagement platform designed to empower Indian voters with real-time election intelligence, interactive education, and simplified voter assistance.

## 🌟 Vertical: Election Education & Civic Engagement
In a democracy as vast as India's, access to accurate, timely, and understandable election data is a critical challenge. **Election Dost** bridges this gap by transforming raw election datasets into actionable insights through a modern, "AI-First" user experience.

## 🎯 Challenge: Election Process Education
Create an assistant that helps users understand the election process, timelines, and steps in an interactive and easy-to-follow way.

---

## 🚀 Core Features

*   **Dost AI (Civic Chat):** A sophisticated RAG-based assistant that explains election processes, eligibility, and forms in multiple languages.
*   **Election Insights:** Interactive results dashboard using a high-fidelity internal dataset of 2024 Lok Sabha results for key constituencies.

---

## 🧠 Approach and Logic

### 1. The "Data-Aware" AI Engine
Unlike standard chatbots, **Election Dost** uses a Retrieval-Augmented Generation (RAG) style approach. The backend dynamically injects real-world data from the **2024 India Lok Sabha Election Results** into the AI's context window (Google Vertex AI). This ensures that when a user asks about their constituency, the answer is grounded in verified results, not just LLM hallucinations.

### 2. Service Layer Architecture
The backend is built with **FastAPI** following a strict **Service Layer Pattern**.
- **Data Service:** Programmatically manages the Kaggle dataset lifecycle using `kagglehub` and `pandas`.
- **Vertex AI Service:** Handles complex prompt engineering and multilingual LLM orchestration.
- **API Layer:** Clean RESTful endpoints that decouple business logic from the frontend.

### 3. Reactive Frontend
Built with **Flutter Web**, the frontend prioritizes "Interactivity over Text":
- **Riverpod State Management:** Ensures the UI reacts instantly to authentication changes and data fetches.
- **GoRouter Security:** Implements a sequential `Login → Onboarding → Dashboard` flow with global authentication guards.

---

## 🛠️ How the Solution Works

### 🗳️ Real-Time Results Dashboard
Users can search through all **543+ Parliamentary Constituencies**. The system fetches candidate-level metrics including:
- Leading vs. Trailing candidates.
- Party-wise seat distribution.
- Precise winning margins and counting status.

### 🤖 Ask Dost (AI Assistant)
A conversational interface powered by **Gemini 1.5 Flash**. It handles:
- **Eligibility Checks:** Interactive logic to determine voter status.
- **Booth Finding:** Geolocation-aware guidance (Mocked to New Panvel, MH).
- **Process Guidance:** Step-by-step walkthroughs of Form 6 (Registration) and Form 8 (Correction).

### 🎮 Interactive Learning
- **EVM Simulator:** A visual, interactive widget that simulates the voting process to reduce voter anxiety and errors.
- **Civic Quiz:** A gamified experience to test knowledge of Indian democratic processes.

---

## 📝 Assumptions Made
1. **Dataset:** The 2024 Lok Sabha dataset provided via Kaggle is treated as the primary source of truth for election results.
2. **Geolocation:** For hackathon demonstration purposes, geographic logic and booth finding default to **New Panvel, Maharashtra**.
3. **Deployment:** The application is architected for **Web-Only** deployment to ensure a lightweight footprint (<10MB repo size).
4. **Data Latency:** Initial dataset loading happens on backend cold start; subsequent queries are cached in-memory for high performance.

---

## 🚀 Quick Start
1. **Backend:** Run `python main.py` (ensure `.env` is configured with Vertex AI credentials).
2. **Frontend:** Run `flutter run -d chrome` from the `/frontend` directory.

**Built for the future of Indian Democracy. Jai Hind!** 🇮🇳
