import json, time
from pathlib import Path
from typing import Any, Dict
from flask import Flask, jsonify, request
from flask_cors import CORS
import xlwings as xw

app = Flask(__name__)
# Configure CORS to allow requests from Streamlit
CORS(app, origins=[
    "https://fx-screener-mep-ccl.streamlit.app",
    "https://argyfx.com",
    "http://127.0.0.1:5001",
    "http://localhost:5001"
], supports_credentials=True)

# Load config
CONFIG = json.loads(Path("config.json").read_text(encoding="utf-8"))
WB_PATH = Path(CONFIG["workbook"])         # e.g. C:\Users\rmonaco\OneDrive\Source.xlsx
WB_NAME = WB_PATH.name
SHEET = CONFIG["sheet"]                    # e.g. "Hoja1"
MAP = CONFIG["mapping"]                    # keys match data-field in FX.html

def fmt_currency(n: float) -> str:
    try:
        return ("$ " + f"{float(n):,.1f}").replace(",", "X").replace(".", ",").replace("X", ".")
    except Exception:
        return str(n)

def fmt_percent(n: float) -> str:
    try:
        # if Excel stores 1% as 0.01, multiply by 100 for fallback formatting
        return (f"{float(n)*100:.2f}%").replace(".", ",")
    except Exception:
        return str(n)

def format_value(key: str, v: Any) -> str:
    if v is None:
        return ""
    if isinstance(v, str):
        return v.strip()
    return fmt_percent(v) if key.startswith("canje-") else fmt_currency(v)

def get_book():
    # Attach to an already-open workbook if possible
    for app_ in xw.apps:
        for book in app_.books:
            try:
                if book.name.lower() == WB_NAME.lower() or Path(book.fullname) == WB_PATH:
                    return book
            except Exception:
                pass
    # Fallback: open from disk
    return xw.Book(str(WB_PATH))

def read_cell_text(sht, addr: str):
    # Exact displayed text from Excel (respects cell formatting)
    try:
        return sht.range(addr).api.Text
    except Exception:
        return None

@app.get("/api/fx")
def api_fx():
    book = get_book()
    sht = book.sheets[SHEET]
    out: Dict[str, str] = {}
    
    # Get CI mode from query parameter, default to 'ci'
    ci_mode = request.args.get('ci_mode', 'ci')
    
    # Select mapping based on CI mode
    if ci_mode == '24hs':
        mapping = CONFIG.get("mapping_24hs", MAP)  # fallback to default if not configured
    else:
        mapping = MAP
    
    for key, addr in mapping.items():
        try:
            txt = read_cell_text(sht, addr)
            if txt is not None and txt != "":
                out[key] = txt.strip()
            else:
                val = sht.range(addr).value
                out[key] = format_value(key, val)
        except Exception:
            out[key] = ""
    return jsonify(out), 200, {"Cache-Control": "no-store"}

@app.get("/health")
def health():
    return {"ok": True, "ts": time.time()}

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5001, debug=False)