with open('Backend/main.py', 'rb') as f:
    data = f.read()
data = data.replace(b'\r\n', b'\n').replace(b'\r', b'\n')
with open('Backend/main.py', 'wb') as f:
    f.write(data)
