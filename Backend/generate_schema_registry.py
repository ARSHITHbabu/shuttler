"""
Auto-generate Database Schema Registry from SQLAlchemy models AND database introspection.

This script:
1. Extracts tables from main.py (code-defined models)
2. Queries the database to find ALL existing tables
3. Identifies orphaned tables (exist in DB but not in code)
4. Updates DATABASE_SCHEMA_REGISTRY.md with complete information

Run this script to update DATABASE_SCHEMA_REGISTRY.md based on:
- Current models in main.py
- Actual tables in the database
"""

import re
import os
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect

def get_database_tables():
    """Query the database to get all existing tables"""
    load_dotenv()
    
    SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")
    
    if not SQLALCHEMY_DATABASE_URL:
        print("WARNING: DATABASE_URL not found in .env file!")
        print("Cannot query database. Will only use code-defined tables.")
        return []
    
    try:
        if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
            engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
        else:
            engine = create_engine(SQLALCHEMY_DATABASE_URL, pool_pre_ping=True, echo=False)
        
        inspector = inspect(engine)
        table_names = inspector.get_table_names()
        
        # Filter out system tables (PostgreSQL)
        if not SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
            # PostgreSQL system tables start with pg_ or are in information_schema
            table_names = [t for t in table_names if not t.startswith('pg_') and t not in ['information_schema']]
        
        return sorted(table_names)
    except Exception as e:
        print(f"Error connecting to database: {e}")
        print("Will only use code-defined tables.")
        return []

def extract_tables_from_main_py():
    """Extract table information from main.py"""
    main_py_path = Path(__file__).parent / "main.py"
    
    if not main_py_path.exists():
        print(f"ERROR: {main_py_path} not found")
        return {}
    
    with open(main_py_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all class definitions with __tablename__
    pattern = r'class\s+(\w+DB)\(Base\):.*?__tablename__\s*=\s*["\'](\w+)["\']'
    matches = re.finditer(pattern, content, re.DOTALL)
    
    tables = {}
    for match in matches:
        class_name = match.group(1)
        table_name = match.group(2)
        
        # Extract docstring if available - look for docstring right after class definition
        # Find the position of this class definition
        class_start = match.start()
        # Find the next class definition (if any)
        next_class_match = re.search(r'\nclass\s+\w+\(', content[class_start + 1:])
        if next_class_match:
            class_end = class_start + next_class_match.start() + 1
        else:
            class_end = len(content)
        
        # Extract docstring from this class's content only
        class_content = content[class_start:class_end]
        docstring_match = re.search(
            r'class\s+' + re.escape(class_name) + r'\([^)]+\):\s*"""([^"]*)"""',
            class_content,
            re.DOTALL
        )
        docstring = docstring_match.group(1).strip() if docstring_match else ""
        
        tables[table_name] = {
            'class': class_name,
            'description': docstring,
            'in_code': True
        }
    
    return tables

def generate_registry_markdown(code_tables, db_tables, orphaned_tables):
    """Generate markdown content for the registry"""
    today = datetime.now().strftime("%Y-%m-%d")
    
    markdown = f"""# Database Schema Registry

> **IMPORTANT**: This file tracks ALL database tables in the project, including those that may be temporarily commented out or archived. Before creating a new table, check this registry to see if a similar table already exists.

**Last Updated**: {today} (Auto-generated)  
**Database**: PostgreSQL (`badminton_academy`)  
**ORM**: SQLAlchemy (models in `Backend/main.py`)

---

## Orphaned Tables (Exist in DB but NOT in Code)

> **These tables exist in the database but have no corresponding model in `main.py`.**
> **They may have been created during development and then the code was reverted.**
> **Consider reusing these tables instead of creating new ones!**

"""
    
    if orphaned_tables:
        for table_name in orphaned_tables:
            markdown += f"- **`{table_name}`** - **ORPHANED**: Exists in database but no model in code\n"
        markdown += "\n**Action Required**: Either:\n"
        markdown += "1. Add a model for these tables in `main.py` if you want to use them\n"
        markdown += "2. Drop these tables if they're no longer needed\n"
        markdown += "3. Move them to 'Archived Tables' section if temporarily disabled\n\n"
    else:
        markdown += "*(No orphaned tables found - all database tables have corresponding models)*\n\n"
    
    markdown += "---\n\n## Active Tables (Defined in Code)\n\n### Core User Tables\n"
    
    # Group tables by category
    user_tables = ['coaches', 'owners', 'students']
    session_tables = ['sessions', 'batches', 'batch_students', 'batch_coaches']
    attendance_tables = ['attendance', 'coach_attendance', 'performance', 'bmi_records']
    financial_tables = ['fees', 'fee_payments']
    comm_tables = ['invitations', 'coach_invitations', 'announcements', 'notifications']
    calendar_tables = ['calendar_events', 'leave_requests']
    content_tables = ['schedules', 'tournaments', 'video_resources', 'enquiries']
    request_tables = ['student_registration_requests']
    
    categories = [
        ("Core User Tables", user_tables),
        ("Session & Batch Management", session_tables),
        ("Attendance & Performance", attendance_tables),
        ("Financial", financial_tables),
        ("Communication & Invitations", comm_tables),
        ("Calendar & Events", calendar_tables),
        ("Content & Resources", content_tables),
        ("Registration & Requests", request_tables),
    ]
    
    for category_name, table_list in categories:
        markdown += f"\n### {category_name}\n"
        for table_name in table_list:
            if table_name in code_tables:
                table_info = code_tables[table_name]
                desc = table_info['description'] or "No description"
                markdown += f"- **`{table_name}`** - {desc}\n"
    
    # Add any code tables that don't fit categories
    categorized = set()
    for _, table_list in categories:
        categorized.update(table_list)
    
    uncategorized = [t for t in code_tables.keys() if t not in categorized]
    if uncategorized:
        markdown += "\n### Other Tables\n"
        for table_name in sorted(uncategorized):
            table_info = code_tables[table_name]
            desc = table_info['description'] or "No description"
            markdown += f"- **`{table_name}`** - {desc}\n"
    
    markdown += """
---

## Archived/Temporary Tables

> Tables listed here were created during development but may be temporarily disabled or archived. They can be reused instead of creating new ones.

*(Manually add archived tables here when you temporarily disable them)*

**Example:**
- ~~`old_notifications`~~ - Archived 2026-01-15, replaced by `notifications` table

---

## Quick Reference

| Table Name | Purpose | Model Class | Status |
|-----------|---------|-------------|--------|
"""
    
    # Add code-defined tables
    for table_name in sorted(code_tables.keys()):
        table_info = code_tables[table_name]
        desc = table_info['description'] or "No description"
        if len(desc) > 50:
            desc = desc[:47] + "..."
        markdown += f"| `{table_name}` | {desc} | `{table_info['class']}` | Active |\n"
    
    # Add orphaned tables
    for table_name in sorted(orphaned_tables):
        markdown += f"| `{table_name}` | Orphaned (no model) | *None* | Orphaned |\n"
    
    markdown += """
---

## Usage Guidelines

1. **Before creating a new table**: 
   - Search this registry for similar tables
   - Check the "Orphaned Tables" section - you might be able to reuse one!

2. **When archiving a table**: 
   - Move it to the "Archived/Temporary Tables" section with a date
   - Comment out the model in `main.py` but keep the table in DB

3. **When re-enabling a table**: 
   - Move it back to "Active Tables" and update the date
   - Uncomment the model in `main.py`

4. **For orphaned tables**:
   - If you want to use them: Add a model in `main.py` and move to "Active Tables"
   - If not needed: Drop the table from database
   - If temporarily disabled: Move to "Archived Tables" section

5. **Keep this file updated**: 
   - Run `python generate_schema_registry.py` after schema changes
   - Or manually update when you create/modify tables

---

## Statistics

"""
    
    markdown += f"- **Total tables in database**: {len(db_tables)}\n"
    markdown += f"- **Tables with models in code**: {len(code_tables)}\n"
    markdown += f"- **Orphaned tables**: {len(orphaned_tables)}\n"
    
    if orphaned_tables:
        markdown += f"\n**WARNING**: {len(orphaned_tables)} table(s) exist in database but have no model in code!\n"
    
    return markdown

def main():
    print("Extracting tables from main.py...")
    code_tables = extract_tables_from_main_py()
    
    if not code_tables:
        print("ERROR: No tables found in main.py. Check for SQLAlchemy models.")
        return
    
    print(f"Found {len(code_tables)} tables defined in code")
    
    print("\nQuerying database for existing tables...")
    db_tables = get_database_tables()
    
    if db_tables:
        print(f"Found {len(db_tables)} tables in database")
        
        # Find orphaned tables (exist in DB but not in code)
        code_table_names = set(code_tables.keys())
        db_table_names = set(db_tables)
        orphaned_tables = sorted(db_table_names - code_table_names)
        
        if orphaned_tables:
            print(f"\nWARNING: Found {len(orphaned_tables)} orphaned table(s):")
            for table in orphaned_tables:
                print(f"   - {table} (exists in DB but no model in code)")
    else:
        orphaned_tables = []
        print("WARNING: Could not query database - will only track code-defined tables")
    
    print("\nGenerating registry markdown...")
    markdown = generate_registry_markdown(code_tables, db_tables, orphaned_tables)
    
    registry_path = Path(__file__).parent / "DATABASE_SCHEMA_REGISTRY.md"
    with open(registry_path, 'w', encoding='utf-8') as f:
        f.write(markdown)
    
    print(f"\nRegistry updated: {registry_path}")
    print(f"\nSummary:")
    print(f"   - Code-defined tables: {len(code_tables)}")
    if db_tables:
        print(f"   - Database tables: {len(db_tables)}")
        print(f"   - Orphaned tables: {len(orphaned_tables)}")
    
    if orphaned_tables:
        print(f"\nACTION REQUIRED: {len(orphaned_tables)} orphaned table(s) need attention!")

if __name__ == "__main__":
    main()
