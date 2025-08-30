# FX Screener - MEP & CCL Dashboard

A beautiful, real-time FX Screener dashboard that displays MEP and CCL rates from your local Excel file, accessible globally via Streamlit Cloud.

## 🌟 Features

- **Real-time data** - Updates every 5 seconds from your Excel file
- **Beautiful UI** - Modern, responsive design with dark theme
- **MEP & CCL rates** - AL30 and GD30 instruments
- **CI/24hs modes** - Switch between different time modes
- **Canje rates** - MEP to CCL and CCL to MEP conversions
- **FX Calculator** - Built-in calculator for currency conversions
- **Global access** - Available worldwide via Streamlit Cloud

## 🚀 Live Demo

Your dashboard is available at: `https://your-app-name.streamlit.app`

## 📊 Data Source

The dashboard reads data from your local Excel file (`Source.xlsx`) using:
- **Local API Server** - `excel_server.py` (runs on your computer)
- **Cloudflare Tunnel** - Makes your local API public
- **Bymada Data Add-in** - Updates Excel every 5 seconds

## 🛠️ Local Setup

### Prerequisites
- Python 3.8+
- Excel file with "Bymada Data Add-in"
- Cloudflare Tunnel (cloudflared)

### Running Locally

1. **Start the Excel API server:**
   ```bash
   python excel_server.py
   ```

2. **Start Cloudflare tunnel:**
   ```bash
   .\cloudflared.exe tunnel --url http://127.0.0.1:5001
   ```

3. **Open the dashboard:**
   - Local: Open `FX.html` in your browser
   - Global: Visit your Streamlit Cloud URL

## 📁 Files

### For Streamlit Cloud:
- `app.py` - Streamlit application
- `FX.html` - Dashboard HTML (with public API URL)
- `streamlit_requirements.txt` - Streamlit dependencies

### For Local API (your computer):
- `excel_server.py` - Local API server
- `config.json` - Excel file configuration
- `cloudflared.exe` - Tunnel tool

## 🔧 Configuration

Update `config.json` to point to your Excel file:
```json
{
  "workbook": "C:\\Users\\rmonaco\\Desktop\\Source.xlsx",
  "sheet": "Hoja1",
  "mapping": { ... }
}
```

## 🌐 Architecture

```
Your Excel File (local)
       ↓
Local API Server (excel_server.py)
       ↓
Cloudflare Tunnel (public URL)
       ↓
Streamlit Cloud (global access)
       ↓
Users worldwide
```

## 📈 Data Flow

1. **Excel updates** every 5 seconds via "Bymada Data Add-in"
2. **Local API** reads data using xlwings
3. **Cloudflare Tunnel** makes API public
4. **Streamlit app** fetches data and displays dashboard
5. **Users** see real-time FX rates globally

## 🎯 Use Cases

- **Traders** - Monitor MEP/CCL rates in real-time
- **Analysts** - Track currency spreads
- **Business** - Make informed FX decisions
- **Anyone** - Access FX data from anywhere

## 🔒 Security

- Local Excel file stays on your computer
- API only exposes specific data fields
- No sensitive information transmitted
- Secure HTTPS via Cloudflare

## 📞 Support

If you need help:
1. Check that your Excel file is open
2. Ensure the API server is running
3. Verify Cloudflare tunnel is active
4. Check Streamlit Cloud deployment status

---

**Built with ❤️ using Streamlit, Flask, and Cloudflare Tunnel**

