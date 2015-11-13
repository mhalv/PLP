from sqlalchemy import Table, Column, String, Integer, Date, ForeignKey, Boolean, Float, DateTime
from sqlalchemy.orm import relationship, backref
from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy import create_engine
from sqlalchemy.engine.url import URL
from sqlalchemy.orm import sessionmaker

import db_configs

Base = declarative_base()

class Site(Base):
    __tablename__ = 'sites'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    district_id = Column(Integer)
    school_start = Column(Date)
    school_end = Column(Date)

class Subject(Base):
    __tablename__ = 'subjects'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    core = Column(Boolean)

class CogSkillDimension(Base):
    __tablename__ = 'cog_skill_dimensions'
    id = Column(Integer, primary_key=True)
    name = Column(String)

class Course(Base):
    __tablename__ = 'courses'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    default_seventy_pcnt_score = Column(Float)
    grade_level = Column(Integer)
    academic_year = Column(Integer)
    subject_id = Column(Integer, ForeignKey('subjects.id'))
    default_seventy_pcnt_score = Column(Float)
    owner_id = Column(Integer)
    owner_type = Column(String)

    subject = relationship('Subject')

class Section(Base):
    __tablename__ = 'sections'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    site_id = Column(Integer, ForeignKey('sites.id'))

class Project(Base):
    __tablename__ = 'projects'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    academic_year = Column(Integer)
    owner_id = Column(Integer)
    owner_type = Column(String)

class ProjectCourse(Base):
    __tablename__ = 'project_courses'
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey('projects.id'))
    course_id = Column(Integer, ForeignKey('courses.id'))

    project = relationship('Project', backref='project_courses')
    course = relationship('Course', backref='project_courses')

class ProjectCogSkillDimension(Base):
    __tablename__ = 'project_cog_skill_dimensions'
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey('projects.id'))
    cog_skill_dimension_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'))

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    type = Column(String)
    school_id = Column(Integer)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String)
    grade_level = Column(Integer)
    mentor_id = Column(Integer)
    visibility = Column(Integer)
    last_leave_on = Column(Date)
    site_id = Column(Integer, ForeignKey('sites.id'))
    default_site_id = Column(Integer)

    site = relationship('Site')

    def name(self):
        return self.first_name + ' ' + self.last_name

class ProjectAssignment(Base):
    __tablename__ = 'project_assignments'
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey('projects.id'))
    student_id = Column(Integer, ForeignKey('users.id'))
    state = Column(Integer)
    due_on = Column(Date)

    student = relationship('User', backref=backref('project_assignments'))
    project = relationship('Project', backref=backref('project_assignments'))

class ProjectAssignmentDimensionScore(Base):
    __tablename__ = 'project_assignment_dimension_scores'
    id = Column(Integer, primary_key=True)
    project_assignment_id = Column(Integer, ForeignKey('project_assignments.id'))
    cog_skill_dimension_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'))
    score = Column(Float)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

class ProjectAssignmentSkillGoal(Base):
    __tablename__ = 'project_assignment_skill_goals'
    id = Column(Integer, primary_key=True)
    project_assignment_id = Column(Integer, ForeignKey('project_assignments.id'))
    cog_skill_dimension_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'))
    score = Column(Float)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

class CourseAssignment(Base):
    __tablename__ = 'course_assignments'
    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey('users.id'))
    course_id = Column(Integer, ForeignKey('courses.id'))
    raw_cog_skill_score = Column(Float)
    power_num_mastered = Column(Integer)
    power_out_of = Column(Integer)
    power_num_behind = Column(Integer)
    visibility = Column(Integer)

    student = relationship('User', backref=backref('course_assignments'))
    course = relationship('Course', backref=backref('course_assignments'))

class CourseAssignmentSection(Base):
    __tablename__ = 'course_assignment_sections'
    id = Column(Integer, primary_key=True)
    course_assignment_id = Column(Integer, ForeignKey('course_assignments.id'))
    section_id = Column(Integer, ForeignKey('sections.id'))

def create_session():
    engine = create_engine(URL(**db_configs.prod_config))
    factory = sessionmaker()
    factory.configure(bind=engine)
    Base.metadata.create_all(engine)
    conn = engine.connect()
    return factory()