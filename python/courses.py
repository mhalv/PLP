import plp_models
from analytics_setup import *

class Course(Base):
    __tablename__ = 'courses'
    id = Column(Integer, primary_key=True, index=True)
    subject_id = Column(Integer, ForeignKey('subjects.id'), index=True)
    name = Column(String)

def delete_rows(analytics_session):
    print("Deleting analytics course rows")
    analytics_session.query(Course).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP course rows")
    courses = plp_session.query(plp_models.Course).\
        filter(plp_models.Course.owner_type == 'District',
               plp_models.Course.owner_id == 1,
               plp_models.Course.academic_year == 2016).\
        all()

    for course in courses:
        analytics_session.add(Course(id = course.id, name = course.name, subject_id = course.subject_id))
    analytics_session.commit()