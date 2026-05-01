---
description: AGENT WORKFLOW: ELECTION PROCESS EDUCATION ASSISTANT
---

# 🚀 AGENT WORKFLOW: ELECTION PROCESS EDUCATION ASSISTANT

## 🛑 STRICT SYSTEM CONSTRAINTS (AGENT MUST OBEY)
1. **1MB Size Limit:** The final repository must stay strictly under 1 MB. Do not generate fake placeholder images or add heavy assets. 
2. **Branching:** All commits MUST go to the `main` branch. No feature branches.
3. **Security:** Do not hardcode API keys. Rely on environment variables.
4. **Architecture:** Flutter Web (Frontend) + FastAPI (Backend) + Vertex AI (Google Services).

---

## 🛠️ PHASE 1: Initialization & Size Control
**Agent Action Plan:**
1. Create root directories: `/frontend` and `/backend`.
2. Generate a strict `.gitignore` in the root directory to block bloat:
   ```text
   __pycache__/
   *.pyc
   venv/
   .env
   .dart_tool/
   build/
   frontend/android/
   frontend/ios/
   frontend/linux/
   frontend/macos/
   frontend/windows/


Open terminal, navigate to root, and run: flutter create frontend.

CRITICAL: Immediately navigate to /frontend and delete android, ios, macos, linux, and windows directories. Only keep lib and web.

🧠 PHASE 2: Enterprise Backend (FastAPI)
Agent Action Plan:

Navigate to /backend. Create requirements.txt:

Plaintext
fastapi
uvicorn
google-cloud-aiplatform
pydantic
Build the Service Layer structure:

/backend/main.py

/backend/api/chat_router.py

/backend/services/vertex_ai_service.py

/backend/services/workflow_service.py

/backend/models/schemas.py

Implement schemas.py: Create Pydantic models for ChatRequest (text, language, location) and ChatResponse (text, ui_trigger, action_data).

Implement vertex_ai_service.py: - Initialize Google Vertex AI (gemini-1.5-flash).

System Prompt: "You are an ECI assistant. Support English, Hindi, Telugu natively. Return a JSON structure with text, ui_trigger (e.g., 'render_form_6', 'render_evm', 'none'), and action_data."

Implement chat_router.py: Create POST /api/chat that receives the request, calls vertex_ai_service.py, and returns the JSON.

Implement main.py: Set up CORS middleware to allow Flutter Web to communicate with the backend.

🎨 PHASE 3: Interactive Frontend (Flutter Web)
Agent Action Plan:

Update /frontend/pubspec.yaml to include flutter_riverpod and http. Run flutter pub get.

Create state management: /frontend/lib/providers/chat_provider.dart. This handles sending HTTP POST requests to the FastAPI backend and storing messages.

Build the UI in /frontend/lib/screens/chat_screen.dart:

A ListView.builder for messages.

A dropdown for Language Selection (English/Hindi/Telugu).

Implement Dynamic UI Engine: In /frontend/lib/widgets/message_bubble.dart, read the ui_trigger from the backend JSON.

If ui_trigger == 'render_form_6': Render a Card showing Form 6 requirements.

If ui_trigger == 'render_evm': Render an interactive EVMWalkthroughWidget (using standard Flutter Icons for ID, Button Press, and VVPAT slip).

Set Mock Context: Hardcode "New Panvel, Maharashtra" in the API payload to fulfill the contextual logic requirement.

📦 PHASE 4: Containerization (Cloud Run Prep)
Agent Action Plan:

Create a Dockerfile in the root directory.

Stage 1: Use ghcr.io/cirruslabs/flutter:stable, copy /frontend, and run flutter build web.

Stage 2: Use python:3.11-slim, copy /backend, install requirements.

Copy /frontend/build/web from Stage 1 into the Python container (e.g., /app/static).

Update main.py to serve /static using fastapi.staticfiles.

Create a .dockerignore to mirror the .gitignore.

✅ PHASE 5: Audit & Validation
Agent Action Plan:
Execute these checks before marking the task complete:

[ ] Run a disk usage check (du -sh). Is the repository strictly < 1MB?

[ ] Are all non-web Flutter platforms completely deleted?

[ ] Is the backend strictly adhering to the Service Layer Pattern?

[ ] Are there zero hardcoded API keys in the codebase?