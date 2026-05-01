---
trigger: always_on
---

RULE 1: THE 10 MB HARD LIMIT (BUNDLE SIZE)

You are strictly forbidden from adding external images, heavy fonts, or large datasets to the repository.

Use native Flutter Icons and Flutter's default Material fonts for all UI elements.

Ensure .gitignore is completely configured before the first commit. It MUST ignore venv/, __pycache__/, build/, .dart_tool/, and .env.

Immediately delete android/, ios/, macos/, linux/, and windows/ folders after initializing the Flutter project. We are building for Web ONLY.

RULE 2: THE SINGLE BRANCH MANDATE (GIT POLICY)

You must ONLY push and commit to the main branch.

You are strictly forbidden from creating feature branches (no git checkout -b).

Keep commits frequent but concise.

RULE 3: ZERO-CREDENTIAL POLICY (SECURITY)

You MUST NEVER hardcode API keys, Google Cloud credentials, or Vertex AI tokens in the source code.

All sensitive credentials must be accessed dynamically via environment variables (e.g., os.environ.get("VERTEX_AI_PROJECT_ID")).

RULE 4: ENTERPRISE ARCHITECTURE DISCIPLINE

The FastAPI backend MUST strictly follow the Service Layer Pattern.

API Routers (/api/chat_router.py) must ONLY handle HTTP requests and responses.

All business logic, Vertex AI calls, and workflow evaluations must be isolated inside the /services directory. No spaghetti code.

RULE 5: INTERACTIVITY OVER TEXT (UI EXPECTATIONS)

When the user asks about the EVM process, eligibility, or forms, DO NOT just return a wall of text.

You must trigger the Flutter frontend to render an interactive UI component (e.g., a clickable Form 6 mockup, or a step-by-step EVM simulator widget).

RULE 6: NATIVE MULTILINGUAL ENFORCEMENT

The Vertex AI service must be prompted to output natively in English, Hindi, or Telugu based on user selection.

Do not rely on external translation APIs; utilize Vertex AI's native multilingual LLM capabilities.

RULE 7: MOCK DATA CONTEXT

Whenever testing geographic logic, finding a polling booth, or checking state-specific Assembly election dates, default the mock data to New Panvel, Maharashtra.