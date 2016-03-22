(SELECT
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

  -- Content Assessment Info
  course_know_dos.level AS "Power Level",
  know_dos.name AS "Focus Area Name",
  assessment_takes.is_content_assessment AS "Content Assessment?",
  assessments.type AS "Assessment Type",
  course_know_dos.sequence AS "Sequence",
  assessment_takes.taken_at::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'US/Pacific' AS "Date Taken", -- timestamp converted to Pacific time
  assessment_takes.num_correct AS "Num Correct",
  assessment_takes.num_possible AS "Num Possible",
  (assessment_takes.num_correct / CAST (assessment_takes.num_possible AS FLOAT)) >= know_dos.pcnt_to_pass AS "Mastered?",
  NULL AS "Reason"


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
  INNER JOIN course_know_dos
    ON course_know_dos.course_id = courses.id
  INNER JOIN know_dos
    ON know_dos.id = course_know_dos.know_do_id
  LEFT OUTER JOIN assessment_takes
    ON assessment_takes.student_id = students.id AND assessment_takes.know_do_id = know_dos.id
  LEFT OUTER JOIN assessments
    ON assessments.id = assessment_takes.assessment_id


WHERE

  districts.id = 1 AND
  courses.academic_year = 2016 AND
  sites.name NOT IN ('Unknown Summit', 'SPS Demo') AND
  students.last_leave_on > CURRENT_DATE AND     -- current students
  subjects.core = TRUE AND
  students.type = 'Student' AND
  course_assignments.visibility = 0 AND
  section_teachers.visibility = 0 AND
  courses.visibility = 0 AND
  teachers.visibility = 0 AND
  students.visibility = 0 AND
  assessment_takes.visibility = 0 AND
  know_dos.visibility = 0 AND
  -- assessment_takes.taken_at >= '2015-08-17' AND   -- Optional: include if only want takes done during this school year (first day of school 8/17/2015)
  assessment_takes.is_content_assessment = TRUE   -- Optional: remove to include Diagnostic and Content Assessments

)


UNION


(SELECT

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

  -- Content Assessment Info
  course_know_dos.level AS "Power Level",
  know_dos.name AS "Focus Area Name",
  NULL AS "Content Assessment?",
  NULL AS "Assessment Type",
  course_know_dos.sequence AS "Sequence",
  NULL AS "Date Taken",
  NULL AS "Num Correct",
  NULL AS "Num Possible",
  COALESCE (know_do_masteries.mastery = 'g', false) AS "Mastered?",
  know_do_masteries.reason AS "Reason"


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
  INNER JOIN course_know_dos
    ON course_know_dos.course_id = courses.id
  INNER JOIN know_dos
    ON know_dos.id = course_know_dos.know_do_id
  LEFT OUTER JOIN know_do_masteries
    ON know_do_masteries.know_do_id = know_dos.id AND know_do_masteries.student_id = students.id


WHERE

  districts.id = 1 AND
  courses.academic_year = 2016 AND
  sites.name NOT IN ('Unknown Summit', 'SPS Demo') AND
  students.last_leave_on > CURRENT_DATE AND
  subjects.core = TRUE AND
  students.type = 'Student' AND
  course_assignments.visibility = 0 AND
  section_teachers.visibility = 0 AND
  courses.visibility = 0 AND
  teachers.visibility = 0 AND
  students.visibility = 0 AND
  know_dos.visibility = 0 AND

  (know_do_masteries.reason IS NOT NULL AND know_do_masteries.reason != 'plp' AND know_do_masteries.reason != 'illuminate')
)


ORDER BY
  "Site",
  "Grade Level",
  "Student Last Name",
  "Student First Name",
  "Subject",
  "Course Grade Level",
  "Course Name",
  "Power Level" DESC,
  "Sequence",
  "Focus Area Name",
  "Reason",
  "Date Taken"
;
