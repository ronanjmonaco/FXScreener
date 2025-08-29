import streamlit as st
import streamlit.components.v1 as components

# Page configuration
st.set_page_config(
    page_title="FX Screener - MEP & CCL",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# Custom CSS to hide Streamlit elements
st.markdown("""
<style>
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    .stDeployButton {display: none;}
    .stApp > header {background-color: transparent;}
    .stApp > footer {background-color: transparent;}
    .stApp > .main {background-color: transparent;}
</style>
""", unsafe_allow_html=True)

# Read and display the HTML file
try:
    with open('FX.html', 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # Display the HTML content
    components.html(html_content, height=800, scrolling=True)
    
except FileNotFoundError:
    st.error("FX.html file not found. Please make sure the HTML file is in the same directory as this app.")
except Exception as e:
    st.error(f"Error loading the HTML file: {e}")

