SELECT

  -- Student Info
  sites.name AS "Site",
  students.grade_level AS "Grade Level",
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

  -- Course & Teacher Info
  subjects.name AS "Subject",
  courses.grade_level AS "Course Grade Level",
  courses.name AS "Course Name",
  teachers.last_name AS "Teacher Last Name",
  teachers.first_name AS "Teacher First Name",
  teachers.email AS "Teacher Email",
  teachers.id AS "Teacher ID",
  sections.sis_id AS "Illuminate Section ID",
  sections.name AS "Period Name",


  -- Grades
  course_assignments.target_letter_grade AS "Grade Goal",
  course_assignments.letter_grade AS "Current Letter Grade",
  course_assignments.overall_score AS "Overall Course Score",
  course_assignments.power_expected_pcnt AS "Power FAs Expected %",


  -- Course-Level Cog Skill Info
  course_assignments.project_score AS "Cog Skill Percentage",
  ROUND(course_assignments.raw_cog_skill_score,5) AS "Cog Skill Score",


  -- Focus Areas: Power
  course_assignments.power_num_mastered AS "Power FAs Mastered",
  course_assignments.power_out_of AS "Total Power FAs in Course",
  course_assignments.power_out_of - course_assignments.power_num_mastered AS "Power FAs Left",
  course_assignments.power_num_behind AS "Power FAs Behind",
  ROUND(course_assignments.power_expected,3) AS "Power FAs Expected by End of Year",
  course_assignments.power_on_track AS "On Track to Pass All Power Focus Areas",


  -- Focus Areas: Additional
  course_assignments.addl_num_mastered AS "Additional FAs Mastered",
  course_assignments.addl_out_of AS "Total Additional FAs in Course",
  course_assignments.addl_out_of - course_assignments.addl_num_mastered AS "Additional FAs Left",
  ROUND(course_assignments.addl_expected,3) AS "Additional FAs Expected by End of Year",


  -- Projects
  course_assignments.num_projects_overdue AS "Number of Projects Overdue",
  course_assignments.num_projects_graded as "Number of Projects Graded",
  course_assignments.num_projects_ungraded as "Number of Projects Ungraded",
  course_assignments.num_projects_total AS "Total Number of Projects",
  COALESCE(course_assignments.num_projects_overdue, 0) = 0
    AND COALESCE(course_assignments.project_score, 100) >= 85 AS "On Track for Projects"


FROM users AS students
  LEFT OUTER JOIN sped_cases
    ON sped_cases.student_id = students.id
  LEFT OUTER JOIN users AS case_managers
    ON case_managers.id = sped_cases.teacher_id
  LEFT OUTER JOIN users AS mentors
    ON mentors.id = students.mentor_id
  INNER JOIN sites
    ON sites.id = students.site_id
  INNER JOIN districts
    ON districts.id = sites.district_id
  INNER JOIN course_assignments
    ON course_assignments.student_id = students.id
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


WHERE
  districts.id = 1 AND
  courses.academic_year = 2016 AND
  sites.name NOT IN ('Unknown Summit', 'SPS Demo') AND
  students.last_leave_on > CURRENT_DATE AND
  subjects.core = TRUE AND
  course_assignments.visibility = 0 AND
  section_teachers.visibility = 0 AND
  courses.visibility = 0 AND
  teachers.visibility = 0 AND
  students.visibility = 0

ORDER BY
  sites.name,
  students.grade_level,
  students.last_name,
  students.first_name
;
