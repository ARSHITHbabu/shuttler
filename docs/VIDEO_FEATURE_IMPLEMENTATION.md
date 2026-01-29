# Video Feature Implementation Plan

## Overview
Add a video upload/viewing feature for Owner and Student portals. Owners can upload training videos with remarks for specific students. Students can view and download their assigned videos.

---

## Backend Status (FastAPI)

**Current State**: Basic video API exists at `/videos/` but needs enhancement.

**Existing** ([main.py:293-299](../Backend/main.py#L293-L299)):
```python
class VideoResourceDB(Base):
    id, title, url, description, category  # Basic fields only
```

**Missing for our feature**:
- `student_id` field (to associate videos with students)
- `remarks` field (notes from owner)
- `uploaded_by` field (owner ID)
- `created_at` timestamp
- File upload endpoint (currently only stores URLs)

---

## Part 1: Backend Changes (FastAPI)

### File: `Backend/main.py`

#### 1.1 Update VideoResourceDB Model (~line 293)
Add student association and remarks:
```python
class VideoResourceDB(Base):
    __tablename__ = "video_resources"
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)  # NEW
    title = Column(String, nullable=True)
    url = Column(String, nullable=False)
    remarks = Column(Text, nullable=True)  # NEW
    uploaded_by = Column(Integer, nullable=True)  # NEW (owner_id)
    created_at = Column(DateTime, default=datetime.utcnow)  # NEW

    student = relationship("StudentDB", back_populates="videos")  # NEW
```

#### 1.2 Update Pydantic Models (~line 1219)
```python
class VideoResourceCreate(BaseModel):
    student_id: int
    title: Optional[str] = None
    remarks: Optional[str] = None

class VideoResource(BaseModel):
    id: int
    student_id: int
    student_name: Optional[str] = None
    title: Optional[str] = None
    url: str
    remarks: Optional[str] = None
    uploaded_by: Optional[int] = None
    created_at: datetime
```

#### 1.3 Add Video Upload Endpoint
Follow existing image upload pattern ([main.py:5059-5082](../Backend/main.py#L5059-L5082)):
```python
@app.post("/video-resources/upload")
async def upload_video(
    student_id: int = Form(...),
    remarks: Optional[str] = Form(None),
    title: Optional[str] = Form(None),
    video: UploadFile = File(...)
):
    # Validate video format (mp4, webm, mov)
    # Save to uploads/ directory
    # Create VideoResourceDB record
    # Return VideoResource
```

#### 1.4 Add Student-Filtered Endpoint
```python
@app.get("/video-resources/", response_model=List[VideoResource])
def get_videos_for_student(student_id: Optional[int] = None):
    # Filter by student_id if provided
```

#### 1.5 Fix URL Mismatch
Frontend expects `/video-resources/`, backend has `/videos/`. Update routes to use `/video-resources/`.

---

## Part 2: Frontend Changes (Flutter)

### Files to Create (7 files)

#### 2.1 Model: `lib/models/video_resource.dart`
```dart
class VideoResource {
  final int id;
  final int studentId;
  final String? studentName;
  final String videoUrl;
  final String? title;
  final String? remarks;
  final int? uploadedBy;
  final DateTime createdAt;
  // fromJson, toJson, copyWith methods
}
```

#### 2.2 Service: `lib/core/services/video_service.dart`
Pattern from [announcement_service.dart](../Flutter_Frontend/Badminton/lib/core/services/announcement_service.dart):
- `getVideosForStudent(int studentId)` - GET with query param
- `uploadVideo({studentId, videoFilePath, remarks, onProgress})` - POST multipart
- `deleteVideo(int id)` - DELETE

#### 2.3 Provider: `lib/providers/video_provider.dart`
- `videosByStudentProvider(studentId)` - Fetch videos
- `VideoManager` class with upload/delete

#### 2.4 Owner Screen: `lib/screens/owner/video_management_screen.dart`
Pattern from [performance_tracking_screen.dart](../Flutter_Frontend/Badminton/lib/screens/owner/performance_tracking_screen.dart):
- Batch dropdown selector
- Student dropdown (via `batchService.getBatchStudents()`)
- Video list for selected student
- FAB to add videos

#### 2.5 Upload Form: `lib/screens/owner/video_upload_form.dart`
- Student info (read-only)
- Video picker (multiple files via `image_picker`)
- Remarks text field
- Upload progress
- Submit button

#### 2.6 Student Screen: `lib/screens/student/student_videos_screen.dart`
Pattern from [student_announcements_screen.dart](../Flutter_Frontend/Badminton/lib/screens/student/student_announcements_screen.dart):
- Video list with cards
- Tap for details + play/download options

#### 2.7 Video Player: `lib/widgets/video/video_player_dialog.dart`
- Full-screen dialog with video_player package
- Play/pause controls

### Files to Modify (3 files)

#### 2.8 `lib/providers/service_providers.dart`
Add VideoService provider

#### 2.9 `lib/screens/owner/more_screen.dart` (~line 115)
Add Videos menu item after Performance Tracking

#### 2.10 `lib/screens/student/student_more_screen.dart` (~line 108)
Add Training Videos menu item + case in _buildSubScreen()

---

## Implementation Order

### Phase 1: Backend
1. Update VideoResourceDB model with new fields
2. Update Pydantic models
3. Add video upload endpoint
4. Add student-filtered GET endpoint
5. Fix URL routes (/videos/ -> /video-resources/)
6. Test with curl/Postman

### Phase 2: Frontend Foundation
1. Create video_resource.dart model
2. Create video_service.dart
3. Add to service_providers.dart
4. Create video_provider.dart
5. Run `flutter pub run build_runner build`

### Phase 3: Owner Features
1. Create video_management_screen.dart
2. Create video_upload_form.dart
3. Add menu item to more_screen.dart

### Phase 4: Student Features
1. Create video_player_dialog.dart
2. Create student_videos_screen.dart
3. Add menu item to student_more_screen.dart

---

## Dependencies

**Flutter** - May need to add:
```yaml
video_player: ^2.8.0
```

**Backend** - Already has:
- `python-multipart` for file uploads
- File upload pattern in place for images

---

## Verification Plan
1. **Backend**: Test video upload via curl/Postman
2. **Owner Flow**: More > Videos > Select batch > Select student > Upload video > Verify
3. **Student Flow**: Login as student > More > Training Videos > View > Play/Download
4. Run `flutter analyze`

---

## Created
Date: 2026-01-29
