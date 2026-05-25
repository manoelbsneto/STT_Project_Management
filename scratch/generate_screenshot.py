import sys
import os
from PIL import Image, ImageDraw, ImageFont

def generate_screenshot(text, output_path, title="VS Code"):
    # Create a dark mode window
    width = 1000
    line_height = 20
    padding = 20
    header_height = 40
    
    lines = text.split('\n')
    height = max(400, len(lines) * line_height + padding * 2 + header_height)
    
    # Create image
    img = Image.new('RGB', (width, height), color='#1e1e1e')
    draw = ImageDraw.Draw(img)
    
    # Draw header bar
    draw.rectangle([(0, 0), (width, header_height)], fill='#2d2d2d')
    
    # Draw window controls (macOS style dots for premium feel)
    draw.ellipse([(15, 12), (27, 24)], fill='#ff5f56')
    draw.ellipse([(35, 12), (47, 24)], fill='#ffbd2e')
    draw.ellipse([(55, 12), (67, 24)], fill='#27c93f')
    
    # Draw title
    # Try to load a font, fallback if not possible
    font_path = "C:\\Windows\\Fonts\\consola.ttf"
    if not os.path.exists(font_path):
        font_path = "C:\\Windows\\Fonts\\arial.ttf"
        
    try:
        title_font = ImageFont.truetype(font_path, 14)
        text_font = ImageFont.truetype(font_path, 13)
    except Exception:
        title_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        
    draw.text((width // 2, 20), title, fill='#cccccc', font=title_font, anchor="mm")
    
    # Draw text lines
    y = header_height + padding
    for line in lines:
        draw.text((padding, y), line, fill='#d4d4d4', font=text_font)
        y += line_height
        
    # Save the image
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Screenshot saved to {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_screenshot.py <text_file_or_string> <output_png_path> [title]")
        sys.exit(1)
        
    input_val = sys.argv[1]
    output_path = sys.argv[2]
    title = sys.argv[3] if len(sys.argv) > 3 else "VS Code"
    
    if os.path.exists(input_val):
        with open(input_val, 'r', encoding='utf-8', errors='ignore') as f:
            text = f.read()
    else:
        text = input_val
        
    generate_screenshot(text, output_path, title)
