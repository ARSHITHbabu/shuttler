import re

def remove_emojis(text):
    # Common emojis used in the file
    emojis = ["✅", "⚠️", "❌", "📹", "🚀", "📖", "📊", "📱", "⏰", "\u2705", "\u26a0", "\u274c", "\u1f4f9", "\u1f680", "\u1f4d6", "\u1f4ca", "\u1f4f1", "\u23f0"]
    for emoji in emojis:
        text = text.replace(emoji, "")
    # Also generic regex for some ranges if needed, but specific list is safer to avoid breaking valid unicode strings
    return text

with open("main.py", "r", encoding="utf-8") as f:
    content = f.read()

new_content = remove_emojis(content)

with open("main.py", "w", encoding="utf-8") as f:
    f.write(new_content)

print(f"Cleaned main.py")
