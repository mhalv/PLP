from analytics_setup import *

class SkillScore(Base):
    __tablename__ = 'skill_scores'
    id = Column(Integer, primary_key=True)
    school_id = Column(Integer, index=True)
    course_id = Column(Integer, ForeignKey('courses.id'), index=True)
    project_id = Column(Integer, ForeignKey('projects.id'), index=True)
    cog_skill_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'), index=True)
    score = Column(Float)
    goal = Column(Float)
    score_updated_on = Column(DateTime)

def delete_rows(analytics_session):
    print("Deleting analytics skill_score rows")
    analytics_session.query(SkillScore).delete()
    analytics_session.commit()

def compute(analytics_session):
    print("Scraping PLP skill_scores rows")
    conn = create_connection()
    results = conn.execute(
        "SELECT "\
            "students.school_id,"\
            "courses.id AS course_id,"\
            "project_courses.project_id,"\
            "cog_skill_dimensions.id AS cog_skill_id,"\
            "project_assignment_dimension_scores.score,"\
            "project_assignment_skill_goals.score AS goal,"\
            "project_assignment_dimension_scores.updated_at AS score_updated_on "\
        "FROM students "\
            "JOIN course_assignments ON course_assignments.student_id = students.id "\
            "JOIN courses ON course_assignments.course_id = courses.id "\
            "JOIN project_courses ON project_courses.course_id = course_assignments.course_id "\
            "JOIN project_assignments ON project_assignments.project_id = project_courses.project_id AND project_assignments.student_id = students.id "\
            "JOIN project_assignment_dimension_scores ON project_assignment_dimension_scores.project_assignment_id = project_assignments.id "\
            "JOIN cog_skill_dimensions ON project_assignment_dimension_scores.cog_skill_dimension_id = cog_skill_dimensions.id "\
            "LEFT JOIN project_assignment_skill_goals ON project_assignment_skill_goals.project_assignment_id = project_assignments.id AND "\
                "project_assignment_skill_goals.cog_skill_dimension_id = cog_skill_dimensions.id "\
        "WHERE project_assignments.status = 4"
    )

    new_rows = []
    for result in results:
        new_rows.append(
            SkillScore(
                school_id=result[0],
                course_id=result[1],
                project_id= result[2],
                cog_skill_id=result[3],
                score=result[4],
                goal=result[5],
                score_updated_on=result[6]
        ))

    conn.close()
    analytics_session.add_all(new_rows)
    analytics_session.commit()