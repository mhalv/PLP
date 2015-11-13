from analytics_setup import *

class AssessmentsRemaining(Base):
    __tablename__ = 'assessments_remaining'
    id = Column(Integer, primary_key=True)
    school_id = Column(Integer, index=True)
    course_id = Column(Integer, ForeignKey('courses.id'), index=True)
    cog_skill_id = Column(Integer, ForeignKey('cog_skill_dimensions.id'), index=True)
    num = Column(Integer)

def delete_rows(analytics_session):
    print("Deleting analytics assessments_remaining rows")
    analytics_session.query(AssessmentsRemaining).delete()
    analytics_session.commit()

def compute(analytics_session):
    print("Scraping PLP assessments_remaining rows")
    conn = create_connection()
    results = conn.execute("""\
        SELECT students.school_id,
            courses.id,
            cog_skill_dimensions.id,
            sum(CASE WHEN project_assignments.status IS NULL OR project_assignments.status <> 4 THEN 1
                ELSE 0
                END) AS num
        FROM students
            JOIN course_assignments ON course_assignments.student_id = students.id
            JOIN courses ON course_assignments.course_id = courses.id
            JOIN project_courses ON project_courses.course_id = course_assignments.course_id
            JOIN project_cog_skill_dimensions ON project_courses.project_id = project_cog_skill_dimensions.project_id
            JOIN cog_skill_dimensions ON project_cog_skill_dimensions.cog_skill_dimension_id = cog_skill_dimensions.id
            LEFT JOIN project_assignments ON project_assignments.project_id = project_courses.project_id AND project_assignments.student_id = students.id
        GROUP BY students.school_id, courses.id, cog_skill_dimensions.id
    """)

    new_rows = []
    for result in results:
        new_rows.append(
            AssessmentsRemaining(
                school_id=result[0],
                course_id=result[1],
                cog_skill_id= result[2],
                num=result[3]
        ))

    conn.close()
    analytics_session.add_all(new_rows)
    analytics_session.commit()