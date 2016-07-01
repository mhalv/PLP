/*

Summary:
Queries a list of unscored projects from SoS 2016

Level of Detail:
By course, by student, by project, by cog skill dimension

*/

SELECT

  sites.name AS "Site",
  students.grade_level AS "Grade Level",

  -- Course & Teacher Info
  subjects.name AS "Subject",
  courses.name AS "Course Name",
  teachers.last_name AS "Teacher Last Name",
  teachers.first_name AS "Teacher First Name",
  teachers.email AS "Teacher Email",
  sections.name AS "Period Name",
  sections.sis_id AS "Illuminate Section ID",

  -- Student Info
  students.school_id AS "Student ID",
  students.last_name AS "Student Last Name",
  students.first_name AS "Student First Name",
  students.email AS "Student Email",

  -- Mentor Info
  mentors.last_name AS "Mentor Last Name",
  mentors.first_name AS "Mentor First Name",
  mentors.email AS "Mentor Email",

  -- SPED Info
  sped_cases.id IS NOT NULL AS "Student Is Special Ed?",
  case_managers.first_name AS "Case Manager First Name",
  case_managers.last_name AS "Case Manager Last Name",

  -- Project Data
  projects.name AS "Project",
  project_assignments.due_on AS "Due Date",
  project_assignments.start_date AS "Start Date",
  project_assignments.submitted_on AS "Submitted Date",
  (
    CASE project_assignments.state
      WHEN 0 THEN 'Working'
      WHEN 1 THEN 'Submitted'
      WHEN 2 THEN 'Returned'
      WHEN 3 THEN 'Resubmitted'
      WHEN 4 THEN 'Scored'
      WHEN 5 THEN 'Exempt'
    END
  ) AS "Project State",
  csd.name AS "Cog Skill Dimension",
  pads.score AS "Cog Skill Dimension Score"


FROM users AS students
  LEFT OUTER JOIN sped_cases
    ON sped_cases.student_id = students.id
  LEFT OUTER JOIN users AS case_managers
    ON case_managers.id = sped_cases.teacher_id
  LEFT OUTER JOIN users AS mentors
    ON mentors.id = students.mentor_id
  INNER JOIN course_assignments
    ON course_assignments.student_id = students.id
  INNER JOIN sites
    ON sites.id = course_assignments.site_id
  INNER JOIN districts
    ON districts.id = sites.district_id
  INNER JOIN courses
    ON courses.id = course_assignments.course_id
  INNER JOIN course_assignment_sections
    ON course_assignment_sections.course_assignment_id = course_assignments.id
  INNER JOIN subjects
    ON subjects.id = courses.subject_id
  INNER JOIN sections
    ON sections.id = course_assignment_sections.section_id
  INNER JOIN section_teachers
    ON section_teachers.section_id = sections.id
  INNER JOIN users AS teachers
    ON teachers.id = section_teachers.teacher_id
  INNER JOIN project_courses
    ON project_courses.course_id = course_assignments.course_id
  INNER JOIN projects
    ON projects.id = project_courses.project_id
  INNER JOIN project_cog_skill_dimensions AS pcsd
    ON pcsd.project_id = projects.id
  INNER JOIN cog_skill_dimensions AS csd
    ON csd.id = pcsd.cog_skill_dimension_id
  INNER JOIN project_assignments
    ON (project_assignments.project_id = projects.id
    AND project_assignments.student_id = students.id)
  LEFT OUTER JOIN project_assignment_dimension_scores AS pads
    ON pads.project_assignment_id = project_assignments.id
    AND csd.id = pads.cog_skill_dimension_id


WHERE
  districts.id = 1 AND
  courses.academic_year = 2016 AND
  sites.name NOT IN ('Unknown Summit', 'SPS Demo') AND
  students.last_leave_on > '2016-06-01' AND -- Date selected near end of 2015-2016 school year
  subjects.name = 'Summer of Summit' AND
  course_assignments.visibility = 0 AND
  section_teachers.visibility = 0 AND
  courses.visibility = 0 AND
  teachers.visibility = 0 AND
  students.visibility = 0 AND
  project_assignments.visibility = 0 AND
  projects.visibility = 0 AND
  project_assignments.state NOT IN (4, 5)

  --QA Tests
  --AND students.school_id = '50001'
  --AND students.school_id = '50010'
  --AND students.school_id = '11655'


GROUP BY
  "Site",
  "Grade Level",
  "Student ID",
  "Student Last Name",
  "Student First Name",
  "Student Email",
  "Mentor Last Name",
  "Mentor First Name",
  "Mentor Email",
  "Student Is Special Ed?",
  "Case Manager First Name",
  "Case Manager Last Name",
  "Subject",
  "Course Name",
  "Teacher Last Name",
  "Teacher First Name",
  "Teacher Email",
  "Illuminate Section ID",
  "Period Name",
  "Project",
  "Due Date",
  "Start Date",
  "Submitted Date",
  project_assignments.state,
  "Cog Skill Dimension",
  "Cog Skill Dimension Score"


ORDER BY
  "Site",
  "Grade Level",
  "Subject",
  "Course Name",
  "Teacher Last Name",
  "Teacher First Name",
  "Period Name",
  "Student ID",
  "Project"
