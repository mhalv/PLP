import sys

import plp_models
import analytics_setup
import sites
import cog_skill_dimensions
import projects
import courses
import project_courses
import teachers
import students
import project_assignments
import project_assignment_dimension_scores
import project_assignment_skill_goals
import course_assignments
import project_cog_skill_dimensions
import subjects

import skill_scores
import assessments_remaining
import times_assessed

def drop_all(models, analytics_session):
    in_order = models.copy()
    in_order.reverse()

    for model in in_order:
        model.delete_rows(analytics_session)

def scrape(models, plp_session, analytics_session):
    for model in models:
        model.scrape(plp_session, analytics_session)

def materialize(views, analytics_session):
    for view in views:
        view.compute(analytics_session)

if __name__ == '__main__':
    plp_session = plp_models.create_session()
    analytics_session = analytics_setup.create_session()

    dimensions = [
        sites,
        subjects,
        cog_skill_dimensions,
        projects,
        project_cog_skill_dimensions,
        courses,
        project_courses,
        teachers,
        students,
        course_assignments, 
        project_assignments,
        project_assignment_dimension_scores,
        project_assignment_skill_goals,
    ]

    views = [
        skill_scores,
        assessments_remaining,
        times_assessed
    ]

    drop_all(views, analytics_session)
    drop_all(dimensions, analytics_session)

    scrape(dimensions, plp_session, analytics_session)
    materialize(views, analytics_session)