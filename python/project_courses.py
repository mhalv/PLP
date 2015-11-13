import plp_models
from analytics_setup import *
from projects import Project
from courses import Course

class ProjectCourse(Base):
    __tablename__ = 'project_courses'
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey('projects.id'), index=True)
    course_id = Column(Integer, ForeignKey('courses.id'), index=True)

    project = relationship('Project')
    course = relationship('Course')

def delete_rows(analytics_session):
    print("Deleting analytics project_course rows")
    analytics_session.query(ProjectCourse).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP project_course rows")
    projects = analytics_session.query(Project).all()
    courses = analytics_session.query(Course).all()

    pcs = plp_session.query(plp_models.ProjectCourse).\
        filter(
            plp_models.ProjectCourse.project_id.in_([p.id for p in projects]),
            plp_models.ProjectCourse.course_id.in_([c.id for c in courses])).\
        all()

    for pc in pcs:
        analytics_session.add(ProjectCourse(
            id = pc.id,
            project_id = pc.project_id,
            course_id = pc.course_id)
        )
    analytics_session.commit()