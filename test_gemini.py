import os
from dotenv import load_dotenv
from google import genai
from google.genai.types import HttpOptions

load_dotenv()

# These env vars are read automatically by the google-genai SDK:
# GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, GOOGLE_GENAI_USE_VERTEXAI

client = genai.Client(http_options=HttpOptions(api_version="v1"))
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="How does AI work?",
)
print(response.text)
