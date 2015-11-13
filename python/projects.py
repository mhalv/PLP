import plp_models
from analytics_setup import *

class Project(Base):
    __tablename__ = 'projects'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)

def delete_rows(analytics_session):
    print("Deleting analytics project rows")
    analytics_session.query(Project).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP project rows")
    projects = plp_session.query(plp_models.Project).\
        filter(plp_models.Project.owner_type == 'District',
               plp_models.Project.owner_id == 1,
               plp_models.Project.academic_year == 2016).\
        all()

    for project in projects:
        analytics_session.add(Project(id = project.id, name = project.name))
    analytics_session.commit()