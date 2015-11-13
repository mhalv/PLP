import plp_models
from analytics_setup import *
from projects import Project
from students import Student

class ProjectAssignment(Base):
    __tablename__ = 'project_assignments'
    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey('projects.id'), index=True)
    student_id = Column(Integer, ForeignKey('students.id'), index=True)
    status = Column(Integer, index=True)

    project = relationship('Project')
    student = relationship('Student')

def delete_rows(analytics_session):
    print("Deleting analytics project_assignment rows")
    analytics_session.query(ProjectAssignment).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP project_assignment rows")
    projects = analytics_session.query(Project).all()
    students = analytics_session.query(Student).all()

    project_assignments = plp_session.query(plp_models.ProjectAssignment).\
        filter(
            plp_models.ProjectAssignment.project_id.in_([p.id for p in projects]),
            plp_models.ProjectAssignment.student_id.in_([s.id for s in students])).\
        all()

    new_projects = []
    for pa in project_assignments:
        new_projects.append(ProjectAssignment(id = pa.id,
                                              status = pa.state,
                                              project_id = pa.project_id,
                                              student_id = pa.student_id))
    analytics_session.add_all(new_projects)
    analytics_session.commit()