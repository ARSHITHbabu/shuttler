# Database Schema Registry - Automatic Discovery

This system automatically tracks all database tables (including orphaned ones) and updates the registry in real-time.

## Quick Start

### 1. Install Dependencies

```bash
pip install watchdog
```

Or install all requirements:
```bash
pip install -r requirements.txt
```

### 2. Set Up Automatic Discovery

Run the setup script:
```bash
python Backend/setup_auto_discovery.py
```

This will:
- Install git pre-commit hook (backup safety)
- Check if dependencies are installed

### 3. Start Real-Time File Watcher

For real-time warnings during development:

```bash
python Backend/watch_schema_changes.py
```

**Benefits:**
- ✅ Real-time warnings about orphaned tables
- ✅ Immediate feedback as you code
- ✅ Catches issues before committing
- ✅ Updates registry automatically when you modify `main.py` or SQL files

## How It Works

### File Watcher (Recommended for Development)

The file watcher (`watch_schema_changes.py`) monitors:
- `Backend/main.py` - Your SQLAlchemy models
- `Backend/*.sql` - SQL migration files

**When you make changes:**
1. Watcher detects the change
2. Runs `generate_schema_registry.py`
3. Updates `DATABASE_SCHEMA_REGISTRY.md`
4. Warns you if orphaned tables are found

**Example Output:**
```
============================================================
[Schema Watcher] Detected change in: main.py
============================================================

WARNING: Found 1 orphaned table(s):
   - requests (exists in DB but no model in code)

   -> Check Backend/DATABASE_SCHEMA_REGISTRY.md for details
   -> Consider reusing orphaned tables instead of creating new ones!

[Schema Watcher] Registry updated successfully!
```

### Git Pre-Commit Hook (Backup Safety)

The git hook runs automatically before every commit:
- Checks if schema files changed
- Updates registry if needed
- Adds registry to commit automatically

**No action needed** - it runs automatically!

## Manual Update

If you need to manually update the registry:

```bash
cd Backend
python generate_schema_registry.py
```

## What Gets Tracked

### Active Tables
- Tables defined in `main.py` with SQLAlchemy models
- Automatically categorized by purpose

### Orphaned Tables
- Tables that exist in the database but have no model in code
- These are highlighted with warnings
- You can reuse them instead of creating new tables!

### Archived Tables
- Tables that were temporarily disabled
- Manually documented in the registry

## Usage Tips

1. **During Development**: Run the file watcher for real-time feedback
2. **Before Commits**: Git hook ensures registry is updated
3. **When Creating Tables**: Check registry first to avoid duplicates
4. **For Orphaned Tables**: Either add a model or drop the table

## Files

- `generate_schema_registry.py` - Main generator script
- `watch_schema_changes.py` - Real-time file watcher
- `setup_auto_discovery.py` - Setup script
- `DATABASE_SCHEMA_REGISTRY.md` - Generated registry (auto-updated)

## Troubleshooting

### File watcher not working?
- Make sure `watchdog` is installed: `pip install watchdog`
- Check that you're running from the project root

### Git hook not running?
- Make sure you're in a git repository
- Check `.git/hooks/pre-commit` exists and is executable (Unix/Mac)

### Database connection errors?
- Check your `.env` file has `DATABASE_URL` set
- The watcher will still work with code-defined tables only
