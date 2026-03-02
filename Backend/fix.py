file_path = "main.py"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("\\n\\n", "\n\n")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)
