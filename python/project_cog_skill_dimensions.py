import plp_models
from analytics_setup import *
from projects import Project
from cog_skill_dimensions import CogSkillDimension

class ProjectCogSkillDimension(Base):
    __tablename__ = 'project_cog_skill_dimensions'
    id = Column(Integer, primary_key=True)
    project_id = Column(Integer, ForeignKey('projects.id'), index=True)
    cog_skill_dimension_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'), index=True)

def delete_rows(analytics_session):
    print("Deleting analytics project_cog_skill_dimensions rows")
    analytics_session.query(ProjectCogSkillDimension).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP project_cog_skill_dimension rows")
    projects = analytics_session.query(Project).all()

    project_skills = plp_session.query(plp_models.ProjectCogSkillDimension).\
        filter(plp_models.ProjectCogSkillDimension.project_id.in_([p.id for p in projects])).\
        all()

    new_rows = []
    for project_skill in project_skills:
        new_rows.append(ProjectCogSkillDimension(
            project_id = project_skill.project_id,
            cog_skill_dimension_id = project_skill.cog_skill_dimension_id
        ))

    analytics_session.add_all(new_rows)
    analytics_session.commit()