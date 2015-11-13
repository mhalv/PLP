import plp_models
from analytics_setup import *

class Teacher(Base):
    __tablename__ = 'teachers'
    id = Column(Integer, primary_key=True)
    site_id = Column(Integer, ForeignKey('sites.id'))
    first_name = Column(String)
    last_name = Column(String)

    site = relationship('Site')

def delete_rows(analytics_session):
    print("Deleting analytics teacher rows")
    analytics_session.query(Teacher).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP teacher rows")
    teachers = plp_session.query(plp_models.User).\
        join(plp_models.Site, plp_models.Site.id == plp_models.User.default_site_id).\
        filter(plp_models.User.type == 'Teacher',
               plp_models.Site.district_id == 1).\
        all()

    for teacher in teachers:
        analytics_session.add(Teacher(site_id = teacher.default_site_id,
                                      first_name = teacher.first_name,
                                      last_name = teacher.last_name)
        )
    analytics_session.commit()