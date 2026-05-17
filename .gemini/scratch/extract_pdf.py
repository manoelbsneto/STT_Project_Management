import PyPDF2
import sys
sys.stdout.reconfigure(encoding='utf-8')

pdf_path = r"C:\Users\dataops-lab\Downloads\dell-pro-14-pc14250-owners-manual-pt-br.pdf"
reader = PyPDF2.PdfReader(pdf_path)

print(f"Total pages: {len(reader.pages)}")
print(f"Title: {reader.metadata.get('/Title', 'N/A')}")
print(f"Author: {reader.metadata.get('/Author', 'N/A')}")
print(f"Subject: {reader.metadata.get('/Subject', 'N/A')}")

# Extract spec pages (pages 19-36 based on keyword scan)
print("\n" + "="*80)
print("SPECIFICATION PAGES (19-36)")
print("="*80)

for i in range(18, min(36, len(reader.pages))):
    text = reader.pages[i].extract_text()
    if text:
        print(f"\n{'='*40} PAGE {i+1} {'='*40}")
        print(text[:3000])
