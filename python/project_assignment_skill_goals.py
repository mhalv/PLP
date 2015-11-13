import plp_models
from analytics_setup import *
from project_assignments import ProjectAssignment
from cog_skill_dimensions import CogSkillDimension

class ProjectAssignmentSkillGoal(Base):
    __tablename__ = 'project_assignment_skill_goals'
    id = Column(Integer, primary_key=True)
    project_assignment_id = Column(Integer, ForeignKey('project_assignments.id'), index=True)
    cog_skill_dimension_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'), index=True)
    score = Column(Float)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

def delete_rows(analytics_session):
    print("Deleting analytics skill goal rows")
    analytics_session.query(ProjectAssignmentSkillGoal).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP skill goal rows")
    project_assignments = analytics_session.query(ProjectAssignment).all()

    skill_goals = plp_session.query(plp_models.ProjectAssignmentSkillGoal).\
        filter(plp_models.ProjectAssignmentSkillGoal.\
            project_assignment_id.in_([pa.id for pa in project_assignments])).\
        all()

    new_goals = []
    for goal in skill_goals:
        new_goals.append(ProjectAssignmentSkillGoal(
            project_assignment_id = goal.project_assignment_id,
            cog_skill_dimension_id = goal.cog_skill_dimension_id,
            score = goal.score,
            created_at = goal.created_at,
            updated_at = goal.updated_at)
        )
    analytics_session.add_all(new_goals)
    analytics_session.commit()