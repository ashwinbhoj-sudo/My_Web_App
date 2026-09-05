# Simple Python Web App

A lightweight, modern web application built using **FastAPI**.

## Getting Started

1. **Create and activate a virtual environment:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application:**
   ```bash
   uvicorn src.my_app.main:app --reload
   ```

4. **Access the API:**
   - App: [http://127.0.0.1:8000](http://127.0.0.1:8000)
   - Interactive Docs: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
