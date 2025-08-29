import streamlit as st
import streamlit.components.v1 as components

# Page configuration
st.set_page_config(
    page_title="FX Screener - MEP & CCL",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS to hide Streamlit elements and remove ALL white spaces
st.markdown("""
<style>
    /* Hide Streamlit UI elements */
    #MainMenu {visibility: hidden !important;}
    footer {visibility: hidden !important;}
    header {visibility: hidden !important;}
    .stDeployButton {display: none !important;}
    
    /* Remove ALL margins and padding from Streamlit */
    .stApp {
        margin: 0 !important;
        padding: 0 !important;
        background: transparent !important;
        width: 100vw !important;
        min-height: 100vh !important;
        overflow-x: hidden !important;
    }
    
    /* Force full width and remove all spacing */
    .main .block-container {
        padding: 0 !important;
        margin: 0 !important;
        max-width: 100% !important;
        width: 100% !important;
        height: 100vh !important;
    }
    
    /* Remove any remaining Streamlit spacing */
    .stApp > div {
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
        height: 100% !important;
    }
    
    /* Make iframe fill entire space */
    .stApp iframe {
        border: none !important;
        margin: 0 !important;
        padding: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
    }
    
    /* Override any remaining Streamlit styles */
    .stApp > div:first-child {
        padding: 0 !important;
        margin: 0 !important;
        height: 100vh !important;
    }
    
    /* Force full viewport */
    html, body {
        margin: 0 !important;
        padding: 0 !important;
        width: 100vw !important;
        min-height: 100vh !important;
        overflow-x: hidden !important;
    }
    
    /* Additional overrides for Streamlit's default spacing */
    .stApp > .main > .block-container {
        padding: 0 !important;
        margin: 0 !important;
        max-width: 100vw !important;
        width: 100vw !important;
        height: 100vh !important;
    }
    
    /* Remove any remaining white spaces */
    .stApp > * {
        margin: 0 !important;
        padding: 0 !important;
    }
    
    /* Force the main content to fill viewport */
    .stApp .main {
        width: 100vw !important;
        height: 100vh !important;
        padding: 0 !important;
        margin: 0 !important;
    }
</style>
""", unsafe_allow_html=True)

# Read and display the HTML file
try:
    with open('FX.html', 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # Display the HTML content with full viewport and scrolling enabled
    components.html(html_content, height=1200, scrolling=True)
    
except FileNotFoundError:
    st.error("FX.html file not found. Please make sure the HTML file is in the same directory as this app.")
except Exception as e:
    st.error(f"Error loading the HTML file: {e}")

