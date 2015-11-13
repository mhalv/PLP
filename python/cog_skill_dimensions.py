import plp_models
from analytics_setup import *

class CogSkillDimension(Base):
    __tablename__ = 'cog_skill_dimensions'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)


def delete_rows(analytics_session):
    print("Deleting analytics cog skills rows")
    analytics_session.query(CogSkillDimension).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP cog skill dimension rows")
    skills = plp_session.query(plp_models.CogSkillDimension).all()

    for skill in skills:
        analytics_session.add(CogSkillDimension(id = skill.id, name = skill.name))
    analytics_session.commit()