"""
Lightweight schema registry watcher that runs in background thread.
Automatically starts when main.py runs.
"""

import os
import threading
import subprocess
import time
from pathlib import Path


def start_schema_watcher():
    """Start schema registry watcher in background thread"""
    # Check if watcher is enabled (default: enabled)
    watch_schema = os.getenv("WATCH_SCHEMA", "true").lower() == "true"
    
    if not watch_schema:
        return
    
    def run_watcher():
        """Run the schema watcher in background"""
        try:
            # Try to import watchdog
            from watchdog.observers import Observer
            from watchdog.events import FileSystemEventHandler
            
            backend_dir = Path(__file__).parent
            registry_script = backend_dir / "generate_schema_registry.py"
            
            if not registry_script.exists():
                return
            
            class SchemaChangeHandler(FileSystemEventHandler):
                def __init__(self):
                    self.last_modified = {}
                    self.debounce_seconds = 2
                
                def should_process(self, file_path):
                    return any(pattern in file_path for pattern in ['main.py', '.sql', 'generate_schema_registry.py'])
                
                def on_modified(self, event):
                    if event.is_directory or not self.should_process(event.src_path):
                        return
                    
                    current_time = time.time()
                    if event.src_path in self.last_modified:
                        if current_time - self.last_modified[event.src_path] < self.debounce_seconds:
                            return
                    
                    self.last_modified[event.src_path] = current_time
                    
                    file_name = Path(event.src_path).name
                    print(f"\n[Schema Watcher] Detected change in: {file_name}")
                    
                    # Run registry generator
                    try:
                        result = subprocess.run(
                            ['python', str(registry_script)],
                            cwd=str(backend_dir),
                            capture_output=True,
                            text=True,
                            timeout=30
                        )
                        
                        if result.returncode == 0:
                            # Check for orphaned tables warning
                            output = result.stdout + result.stderr
                            orphaned_found = False
                            
                            for line in output.split('\n'):
                                if 'orphaned table' in line.lower():
                                    print(f"[Schema Watcher] WARNING: {line.strip()}")
                                    orphaned_found = True
                                elif 'ACTION REQUIRED' in line:
                                    print(f"[Schema Watcher] {line.strip()}")
                                    orphaned_found = True
                            
                            if orphaned_found:
                                print("[Schema Watcher] Check Backend/DATABASE_SCHEMA_REGISTRY.md for details")
                                print("[Schema Watcher] Consider reusing orphaned tables instead of creating new ones!")
                            else:
                                print("[Schema Watcher] Registry updated successfully")
                        else:
                            print(f"[Schema Watcher] Error: {result.stderr[:200]}")
                    except Exception as e:
                        print(f"[Schema Watcher] Error updating registry: {e}")
            
            handler = SchemaChangeHandler()
            observer = Observer()
            observer.schedule(handler, str(backend_dir), recursive=False)
            observer.start()
            
            print("[Schema Watcher] Started (monitoring schema changes)")
            
            # Keep watcher running
            while True:
                time.sleep(1)
                
        except ImportError:
            # Watchdog not installed - silently skip
            pass
        except Exception as e:
            # Don't crash the server if watcher fails
            print(f"[Schema Watcher] Failed to start: {e}")
    
    # Start watcher in background thread
    watcher_thread = threading.Thread(target=run_watcher, daemon=True)
    watcher_thread.start()
