from fastapi import FastAPI

app = FastAPI(title="Simple Web App")

@app.get("/")
def read_root():
    return {
        "message": "Welcome to your FastAPI web application!",
        "status": "running"
    }

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "query": q}
