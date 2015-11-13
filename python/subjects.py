import plp_models
from analytics_setup import *

class Subject(Base):
    __tablename__ = 'subjects'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    core = Column(Boolean)

def delete_rows(analytics_session):
    print("Deleting analytics subjects rows")
    analytics_session.query(Subject).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP subjects rows")
    subjects = plp_session.query(plp_models.Subject).all()
    for subject in subjects:
         analytics_session.add(Subject(id = subject.id, name = subject.name, core = subject.core))
    analytics_session.commit()