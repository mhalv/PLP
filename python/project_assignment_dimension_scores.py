import plp_models
from analytics_setup import *
from project_assignments import ProjectAssignment
from cog_skill_dimensions import CogSkillDimension

class ProjectAssignmentDimensionScore(Base):
    __tablename__ = 'project_assignment_dimension_scores'
    id = Column(Integer, primary_key=True)
    project_assignment_id = Column(Integer, ForeignKey('project_assignments.id'), index=True)
    cog_skill_dimension_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'), index=True)
    score = Column(Float)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

def delete_rows(analytics_session):
    print("Deleting analytics dimension score rows")
    analytics_session.query(ProjectAssignmentDimensionScore).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP dimension score rows")
    project_assignments = analytics_session.query(ProjectAssignment).all()

    pad_scores = plp_session.query(plp_models.ProjectAssignmentDimensionScore).\
        filter(plp_models.ProjectAssignmentDimensionScore.\
            project_assignment_id.in_([pa.id for pa in project_assignments])).\
        all()

    new_scores = []
    for pads in pad_scores:
        new_scores.append(ProjectAssignmentDimensionScore(
            project_assignment_id = pads.project_assignment_id,
            cog_skill_dimension_id = pads.cog_skill_dimension_id,
            score = pads.score,
            created_at = pads.created_at,
            updated_at = pads.updated_at)
        )
    analytics_session.add_all(new_scores)
    analytics_session.commit()