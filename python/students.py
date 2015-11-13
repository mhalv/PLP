import plp_models
from analytics_setup import *

class Student(Base):
    __tablename__ = 'students'
    id = Column(Integer, primary_key=True, index=True)
    school_id = Column(Integer, index=True)
    site_id = Column(Integer, ForeignKey('sites.id'), index=True)
    first_name = Column(String)
    last_name = Column(String)

    site = relationship('Site')

def delete_rows(analytics_session):
    print("Deleting analytics student rows")
    analytics_session.query(Student).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP student rows")
    students = plp_session.query(plp_models.User).\
        join(plp_models.Site).\
        filter(plp_models.User.type == 'Student',
               plp_models.Site.district_id == 1).\
        all()

    for student in students:
        analytics_session.add(Student(
            id = student.id,
            school_id = student.school_id,
            site_id = student.site_id,
            first_name = student.first_name,
            last_name = student.last_name
        ))
    analytics_session.commit()