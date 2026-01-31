# Database Schema Rules

## Before Creating Database Tables

**CRITICAL**: Before creating any new database table or model, you MUST:

1. **Check the Schema Registry**: Read `Backend/DATABASE_SCHEMA_REGISTRY.md` to see if a similar table already exists
2. **Search existing models**: Check `Backend/main.py` for existing SQLAlchemy models
3. **Check migration files**: Review SQL migration files in `Backend/` directory
4. **Check orphaned tables**: Look at the "Orphaned Tables" section in the registry - these exist in the database but have no model in code

## Reusing Existing Tables

If you find a table that was previously created but is now commented out or archived:

1. **DO NOT create a new table** - Instead, reuse the existing one
2. **Uncomment/restore the model** in `Backend/main.py` if needed
3. **Update the registry** - Move the table from "Archived" to "Active" in `DATABASE_SCHEMA_REGISTRY.md`
4. **Run migrations** if the table doesn't exist in the database yet

## Reusing Orphaned Tables

If you find an orphaned table (exists in DB but no model in code):

1. **DO NOT create a new table** - Instead, create a model for the existing orphaned table
2. **Add the model** to `Backend/main.py` matching the existing table structure
3. **Update the registry** - Move the table from "Orphaned Tables" to "Active Tables"
4. **Verify the schema** matches what's in the database

## When Creating New Tables

If you must create a new table (after confirming no similar table exists):

1. **Add the model** to `Backend/main.py`
2. **Update the registry** - Add it to `Backend/DATABASE_SCHEMA_REGISTRY.md` under "Active Tables"
3. **Create migration** - Add a SQL migration file if needed
4. **Document relationships** - Note any foreign keys in the registry
5. **Run the generator** - Run `python Backend/generate_schema_registry.py` to update the registry

## Table Naming Conventions

- Use plural nouns: `students`, `batches`, `coaches`
- Use snake_case: `batch_students`, `fee_payments`
- Junction tables: `{entity1}_{entity2}` (e.g., `batch_students`)

## Common Patterns

- User accounts: `coaches`, `owners`, `students`
- Many-to-many: `batch_students`, `batch_coaches`
- Audit fields: `created_at`, `updated_at`, `status`
- Soft deletes: Use `status` field instead of hard deletes

## Updating the Registry

After making schema changes:

1. **Run the generator**: `python Backend/generate_schema_registry.py`
2. **Or manually update**: Edit `Backend/DATABASE_SCHEMA_REGISTRY.md` directly
3. **Commit changes**: Include registry updates in your commits
