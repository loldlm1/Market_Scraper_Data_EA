#!/usr/bin/env python3
import os
import sys

ROOT = os.path.abspath(os.path.dirname(__file__) + '/..')
EXTS = ('.mq5', '.mqh')

# Paths or directories to exclude from formatting (prevent touching .git, builds, etc.)
EXCLUDE_DIRS = ('/.git/', '/.idea/', '/build/', '/dist/')

changed = []
backups = []

for dirpath, dirnames, filenames in os.walk(ROOT):
    for fn in filenames:
        if fn.lower().endswith(EXTS):
            path = os.path.join(dirpath, fn)
            with open(path, 'rb') as f:
                raw = f.read()
            # Skip files in excluded directories
            if any(x in path for x in EXCLUDE_DIRS):
                # skip completely
                continue

            # Skip binary-like files (contain NUL) — don't attempt to modify
            if b'\x00' in raw:
                # binary file, skip
                # print(f"Skipping binary file: {path}")
                continue

            try:
                text = raw.decode('utf-8')
            except UnicodeDecodeError:
                try:
                    text = raw.decode('latin1')
                except Exception:
                    print(f"Skipping (cannot decode): {path}")
                    continue

            new_lines = []
            modified = False
            for line in text.splitlines():
                # Replace tabs anywhere with two spaces
                new_line = line.replace('\t', '  ')
                # Remove trailing spaces
                new_line = new_line.rstrip(' ')  # leave other whitespace like \n handled by join
                if new_line != line:
                    modified = True
                new_lines.append(new_line)

            new_text = '\n'.join(new_lines)
            # Ensure file ends with a newline
            if not new_text.endswith('\n'):
                new_text = new_text + '\n'

            if modified or new_text != text:
                # backup
                bak = path + '.bak'
                with open(bak, 'wb') as bf:
                    bf.write(raw)
                backups.append(bak)
                with open(path, 'wb') as f:
                    f.write(new_text.encode('utf-8'))
                changed.append(path)

if changed:
    print('Modified files:')
    for p in changed:
        print(p)
    print('\nBackups created:')
    for b in backups:
        print(b)
else:
    print('No changes needed.')

# exit with 0 even if nothing changed
sys.exit(0)
