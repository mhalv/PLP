import plp_models
from analytics_setup import *

class Site(Base):
    __tablename__ = 'sites'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)

def delete_rows(analytics_session):
    print("Deleting analytics sites rows")
    analytics_session.query(Site).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP sites rows")
    sites = plp_session.query(plp_models.Site).filter(plp_models.Site.district_id == 1).all()
    for site in sites:
         analytics_session.add(Site(id = site.id, name = site.name))
    analytics_session.commit()