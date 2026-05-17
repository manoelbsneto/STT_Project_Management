import os
from dotenv import load_dotenv
from anthropic import AnthropicVertex

load_dotenv()

client = AnthropicVertex(
    region=os.getenv("ANTHROPIC_VERTEX_REGION", "global"),
    project_id=os.getenv("ANTHROPIC_VERTEX_PROJECT_ID"),
)

message = client.messages.create(
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello! Can you help me?"}],
    model="claude-opus-4-7",
)

print(message.content[0].text)
