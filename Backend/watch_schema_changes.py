"""
File watcher that automatically updates the schema registry when main.py changes.
Provides real-time warnings about orphaned tables and schema issues.

Run: python Backend/watch_schema_changes.py
"""

import time
import subprocess
import sys
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class SchemaChangeHandler(FileSystemEventHandler):
    """Handler for file system events related to schema changes"""
    
    def __init__(self, project_root):
        self.project_root = project_root
        self.last_modified = {}
        self.debounce_seconds = 2
        self.last_orphaned_count = None
    
    def should_process(self, file_path):
        """Check if file is relevant to schema changes"""
        return any(pattern in file_path for pattern in ['main.py', '.sql', 'generate_schema_registry.py'])
    
    def check_for_orphaned_tables(self):
        """Check if there are orphaned tables and warn the user"""
        backend_dir = self.project_root / "Backend"
        registry_script = backend_dir / "generate_schema_registry.py"
        
        if not registry_script.exists():
            return False
        
        try:
            result = subprocess.run(
                ['python', str(registry_script)],
                cwd=str(backend_dir),
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                # Parse output to find orphaned tables
                output = result.stdout + result.stderr
                orphaned_found = False
                
                # Check for orphaned table warnings
                for line in output.split('\n'):
                    if 'orphaned table' in line.lower():
                        print(f"\nWARNING: {line.strip()}")
                        orphaned_found = True
                    elif 'ACTION REQUIRED' in line:
                        print(f"\n{line.strip()}")
                        orphaned_found = True
                
                if orphaned_found:
                    print("   -> Check Backend/DATABASE_SCHEMA_REGISTRY.md for details")
                    print("   -> Consider reusing orphaned tables instead of creating new ones!")
                    self.last_orphaned_count = 1
                else:
                    if self.last_orphaned_count and self.last_orphaned_count > 0:
                        print("✅ All orphaned tables resolved!")
                    self.last_orphaned_count = 0
                
                print("[Schema Watcher] Registry updated successfully!")
                return True
            else:
                print(f"[Schema Watcher] Error updating registry: {result.stderr}")
                return False
        except Exception as e:
            print(f"[Schema Watcher] Error: {e}")
            return False
    
    def on_modified(self, event):
        """Handle file modification events"""
        if event.is_directory or not self.should_process(event.src_path):
            return
        
        current_time = time.time()
        if event.src_path in self.last_modified:
            if current_time - self.last_modified[event.src_path] < self.debounce_seconds:
                return
        
        self.last_modified[event.src_path] = current_time
        
        file_name = Path(event.src_path).name
        print(f"\n{'='*60}")
        print(f"[Schema Watcher] Detected change in: {file_name}")
        print(f"{'='*60}")
        
        # Update registry and check for issues
        self.check_for_orphaned_tables()

def main():
    """Start the file watcher"""
    project_root = Path(__file__).parent.parent
    backend_dir = project_root / "Backend"
    
    if not backend_dir.exists():
        print(f"Error: Backend directory not found: {backend_dir}")
        return
    
    # Check if watchdog is installed
    try:
        from watchdog.observers import Observer
        from watchdog.events import FileSystemEventHandler
    except ImportError:
        print("Error: watchdog library is not installed!")
        print("Install it with: pip install watchdog")
        return
    
    print("=" * 60)
    print("Database Schema Registry Auto-Updater (Real-time)")
    print("=" * 60)
    print(f"Watching: {backend_dir}")
    print("Monitoring: main.py, *.sql files")
    print()
    print("Benefits:")
    print("  ✓ Real-time warnings about orphaned tables")
    print("  ✓ Immediate feedback as you code")
    print("  ✓ Catch issues before committing")
    print()
    print("Press Ctrl+C to stop")
    print("=" * 60)
    
    # Initial check
    print("\nRunning initial check...")
    handler = SchemaChangeHandler(project_root)
    handler.check_for_orphaned_tables()
    print("\nWatching for changes...\n")
    
    event_handler = handler
    observer = Observer()
    observer.schedule(event_handler, str(backend_dir), recursive=False)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n\nStopping schema watcher...")
        observer.stop()
    observer.join()
    print("Schema watcher stopped.")

if __name__ == "__main__":
    main()
