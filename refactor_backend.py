import os
import re

def update_backend():
    file_path = "Backend/main.py"
    with open(file_path, "r") as f:
        content = f.read()

    # 1. Add PerformanceSkillDB Model
    if "class PerformanceSkillDB" not in content:
        skill_model_code = """
class PerformanceSkillDB(Base):
    __tablename__ = "performance_skills"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False, unique=True)
    description = Column(String(255), nullable=True)
    is_active = Column(Boolean, default=True)

"""
        content = content.replace("class BMIDB(Base):", skill_model_code + "class BMIDB(Base):")

    # 2. Add Migration logic for skills
    if "'performance_skills'" not in content:
        migration_logic = """
        # Migrate performance_skills table
        if 'performance_skills' not in tables:
            try:
                PerformanceSkillDB.__table__.create(engine)
                from sqlalchemy.orm import Session
                with Session(engine) as session:
                    defaults = ["serve", "smash", "footwork", "defense", "stamina"]
                    for skill in defaults:
                        session.add(PerformanceSkillDB(name=skill))
                    session.commit()
            except Exception as e:
                print(f"Error creating performance_skills table: {e}")
"""
        content = content.replace("        # Migrate batches table", migration_logic + "        # Migrate batches table")

    # 3. Modify Pydantic Models for PerformanceFrontend
    frontend_models = """class PerformanceFrontend(BaseModel):
    id: int
    student_id: int
    student_name: Optional[str] = None
    batch_id: int
    batch_name: Optional[str] = None
    date: str
    skills: dict = {}
    comments: Optional[str] = None
    created_at: Optional[str] = None

class PerformanceFrontendCreate(BaseModel):
    student_id: int
    batch_id: int
    date: str
    skills: dict = {}
    comments: Optional[str] = None

class PerformanceFrontendUpdate(BaseModel):
    date: Optional[str] = None
    batch_id: Optional[int] = None
    skills: Optional[dict] = None
    comments: Optional[str] = None
"""
    # Replace from class PerformanceFrontend to end of Update model
    pattern = re.compile(r'class PerformanceFrontend\(BaseModel\):.*?class PerformanceFrontendUpdate\(BaseModel\):.*?(?=# BMI Models)', re.DOTALL)
    content = pattern.sub(frontend_models + '\n', content)

    # 4. Update transform_performance_to_frontend
    transform_logic = """def transform_performance_to_frontend(records, db):
    if not records:
        return None
        
    first = records[0]
    
    # Get names
    student = db.query(StudentDB).filter(StudentDB.id == first.student_id).first()
    batch = db.query(BatchDB).filter(BatchDB.id == first.batch_id).first()
    
    skills = {}
    for r in records:
        skills[r.skill.lower()] = r.rating
        
    comments = next((r.comments for r in records if r.comments), None)
    
    return {
        "id": first.id,  # Use first record's ID as representative
        "student_id": first.student_id,
        "student_name": student.name if student else None,
        "batch_id": first.batch_id,
        "batch_name": batch.batch_name if batch else None,
        "date": first.date,
        "skills": skills,
        "comments": comments,
        "created_at": first.timestamp if hasattr(first, 'timestamp') else None
    }"""
    pattern_transform = re.compile(r'def transform_performance_to_frontend\(records, db\):.*?(?=def get_performance_records)', re.DOTALL)
    content = pattern_transform.sub(transform_logic + '\n\n', content)
    
    # 5. Update create_performance_record_v2
    content = content.replace("""        skill_mappings = {
            "serve": performance_data.serve,
            "smash": performance_data.smash,
            "footwork": performance_data.footwork,
            "defense": performance_data.defense,
            "stamina": performance_data.stamina,
        }""", """        skill_mappings = performance_data.skills""")
    
    # Wait, the comment storage needs to be updated too
    content = content.replace('comments=performance_data.comments if skill == "serve" else None', 'comments=performance_data.comments if list(skill_mappings.keys()) and skill == list(skill_mappings.keys())[0] else None')

    # 6. Update update_performance_record
    content = content.replace("""        skill_mappings = {
            "serve": update_data.get('serve'),
            "smash": update_data.get('smash'),
            "footwork": update_data.get('footwork'),
            "defense": update_data.get('defense'),
            "stamina": update_data.get('stamina'),
        }""", """        skill_mappings = update_data.get('skills', {})""")
    content = content.replace("comments=update_data.get('comments') if skill == \"serve\" else None", 'comments=update_data.get(\'comments\') if list(skill_mappings.keys()) and skill == list(skill_mappings.keys())[0] else None')

    # Add API endpoints for owner to manage skills
    endpoints = """
# ==================== Performance Skills Endpoints ====================

class PerformanceSkillBase(BaseModel):
    name: str

class PerformanceSkillCreate(PerformanceSkillBase):
    pass

class PerformanceSkill(PerformanceSkillBase):
    id: int
    is_active: bool
    
    model_config = ConfigDict(from_attributes=True)

@app.get("/api/performance-skills", response_model=List[PerformanceSkill])
def get_performance_skills(active_only: bool = True):
    db = SessionLocal()
    try:
        query = db.query(PerformanceSkillDB)
        if active_only:
            query = query.filter(PerformanceSkillDB.is_active == True)
        return query.all()
    finally:
        db.close()

@app.post("/api/performance-skills", response_model=PerformanceSkill, dependencies=[Depends(require_owner)])
def create_performance_skill(skill: PerformanceSkillCreate):
    db = SessionLocal()
    try:
        db_skill = db.query(PerformanceSkillDB).filter(PerformanceSkillDB.name == skill.name.lower()).first()
        if db_skill:
            db_skill.is_active = True
            db.commit()
            db.refresh(db_skill)
            return db_skill
        
        new_skill = PerformanceSkillDB(name=skill.name.lower())
        db.add(new_skill)
        db.commit()
        db.refresh(new_skill)
        return new_skill
    finally:
        db.close()

@app.patch("/api/performance-skills/{skill_id}", response_model=PerformanceSkill, dependencies=[Depends(require_owner)])
def update_performance_skill(skill_id: int, skill: PerformanceSkillCreate):
    db = SessionLocal()
    try:
        db_skill = db.query(PerformanceSkillDB).filter(PerformanceSkillDB.id == skill_id).first()
        if not db_skill:
            raise HTTPException(status_code=404, detail="Skill not found")
        
        db_skill.name = skill.name.lower()
        db.commit()
        db.refresh(db_skill)
        return db_skill
    finally:
        db.close()

@app.delete("/api/performance-skills/{skill_id}", dependencies=[Depends(require_owner)])
def delete_performance_skill(skill_id: int):
    db = SessionLocal()
    try:
        db_skill = db.query(PerformanceSkillDB).filter(PerformanceSkillDB.id == skill_id).first()
        if not db_skill:
            raise HTTPException(status_code=404, detail="Skill not found")
        
        db_skill.is_active = False
        db.commit()
        return {"message": "Skill deactivated"}
    finally:
        db.close()

"""
    if "Performance Skills Endpoints" not in content:
        content += endpoints

    with open(file_path, "w") as f:
        f.write(content)

if __name__ == "__main__":
    update_backend()
