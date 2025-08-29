import streamlit as st
import streamlit.components.v1 as components

# Page configuration
st.set_page_config(
    page_title="FX Screener - MEP & CCL",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS to hide Streamlit elements and remove white spaces
st.markdown("""
<style>
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    .stDeployButton {display: none;}
    .stApp > header {background-color: transparent;}
    .stApp > footer {background-color: transparent;}
    .stApp > .main {background-color: transparent;}
    
    /* Remove all white spaces and margins */
    .stApp {
        margin: 0 !important;
        padding: 0 !important;
        background: transparent !important;
    }
    
    .main .block-container {
        padding: 0 !important;
        margin: 0 !important;
        max-width: 100% !important;
    }
    
    .stApp > div:first-child {
        padding: 0 !important;
        margin: 0 !important;
    }
    
    /* Make the HTML component fill the entire space */
    .stApp iframe {
        border: none !important;
        margin: 0 !important;
        padding: 0 !important;
    }
    
    /* Remove any remaining Streamlit spacing */
    .stApp > div {
        padding: 0 !important;
        margin: 0 !important;
    }
</style>
""", unsafe_allow_html=True)

# Read and display the HTML file
try:
    with open('FX.html', 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # Display the HTML content with full height and no scrolling
    components.html(html_content, height=1000, scrolling=False)
    
except FileNotFoundError:
    st.error("FX.html file not found. Please make sure the HTML file is in the same directory as this app.")
except Exception as e:
    st.error(f"Error loading the HTML file: {e}")

