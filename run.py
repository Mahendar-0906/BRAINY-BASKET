"""Brainy Basket Launcher Script.
Starts the FastAPI backend and web server, then opens the app in the browser.
"""
import sys
import os
import time
import webbrowser
import threading

def launch_server():
    import uvicorn
    # Change working directory to project root
    project_root = os.path.dirname(os.path.abspath(__file__))
    os.chdir(project_root)
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8082, log_level="info")

def open_browser():
    time.sleep(1.2)
    url = "http://localhost:8082"
    print(f"\n========================================================")
    print(f"  🧺 Brainy Basket is running at: {url}")
    print(f"  Opening your web browser...")
    print(f"========================================================\n")
    try:
        webbrowser.open(url)
    except Exception as e:
        print(f"Please open your browser manually at: {url}")

if __name__ == "__main__":
    t = threading.Thread(target=open_browser, daemon=True)
    t.start()
    launch_server()
