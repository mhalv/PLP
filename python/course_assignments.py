import plp_models
from analytics_setup import *
from courses import Course
from students import Student

class CourseAssignment(Base):
    __tablename__ = 'course_assignments'
    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey('courses.id'), index=True)
    student_id = Column(Integer, ForeignKey('students.id'), index=True)

def delete_rows(analytics_session):
    print("Deleting analytics course_assignment rows")
    analytics_session.query(CourseAssignment).delete()
    analytics_session.commit()

def scrape(plp_session, analytics_session):
    print("Scraping PLP course_assignment rows")
    courses = analytics_session.query(Course).all()
    students = analytics_session.query(Student).all()

    course_assignments = plp_session.query(plp_models.CourseAssignment).\
        filter(
            plp_models.CourseAssignment.course_id.in_([c.id for c in courses]),
            plp_models.CourseAssignment.student_id.in_([s.id for s in students]),
            plp_models.CourseAssignment.visibility == 0).\
        all()

    new_assignments = []
    for ca in course_assignments:
        new_assignments.append(CourseAssignment(id = ca.id,
                                                course_id = ca.course_id,
                                                student_id = ca.student_id))
    analytics_session.add_all(new_assignments)
    analytics_session.commit()