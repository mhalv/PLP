SELECT
  sites.name AS "School",

  -- Course and Teacher Info
  courses.grade_level AS "Course Grade Level",
  subjects.name AS "Subject",
  courses.name AS "Course Name",
  teachers.last_name AS "Teacher Last Name",
  teachers.first_name AS "Teacher First Name",
  teachers.email AS "Teacher Email",

  -- Student Info
  students.grade_level AS "Grade Level",
  students.school_id AS "Student ID",
  students.last_name AS "Student Last Name",
  students.first_name AS "Student First Name",
  students.email AS "Student Email",

  -- SPED Info
  sped_cases.id IS NOT NULL AS "Student Is Special Ed?",
  case_managers.first_name AS "Case Manager First Name",
  case_managers.last_name AS "Case Manager Last Name",

  -- Mentor Info
  mentors.last_name AS "Mentor Last Name",
  mentors.first_name AS "Mentor First Name",
  mentors.email AS "Mentor Email",

  -- Course Level Student Metrics
  course_assignments.num_projects_overdue AS "Number of Projects Overdue",
  course_assignments.project_score AS "Cog Skill Percentage",
  ROUND(course_assignments.raw_cog_skill_score,5) AS "Cog Skill Score",

  -- Project Info
  projects.name AS "Project Name",

  -- Cog Skill Info
  cog_skill_domains.name AS "Cognitive Skill Domain",
  cog_skill_dimensions.name AS "Cognitive Skill Dimension",
  (courses.default_seventy_pcnt_score + 1) AS "Target Score",
  (courses.alternate_seventy_pcnt_score + 1) AS "Alternate Target Score",

  -- Cog Skill Level Student Metrics
  skill_scores.goal AS "Goal Score",
  skill_scores.score AS "Earned Score",
  skill_scores.score_updated_on::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'US/Pacific' AS "Score Updated On",
  times_assessed.num AS "Assessed So Far",
  assessments_remaining.num AS "To Be Assessed"


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
  INNER JOIN subjects
    ON subjects.id = courses.subject_id
  INNER JOIN course_assignment_sections
    ON course_assignment_sections.course_assignment_id = course_assignments.id
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
  INNER JOIN project_cog_skill_dimensions
    ON project_cog_skill_dimensions.project_id = projects.id
  INNER JOIN cog_skill_dimensions
    ON project_cog_skill_dimensions.cog_skill_dimension_id = cog_skill_dimensions.id
  INNER JOIN cog_skill_domains
    ON cog_skill_domains.id = cog_skill_dimensions.cog_skill_domain_id
  LEFT OUTER JOIN skill_scores
    ON (students.school_id = skill_scores.school_id AND
        courses.id = skill_scores.course_id AND
        projects.id = skill_scores.project_id AND
        cog_skill_dimensions.id = skill_scores.cog_skill_id)
  INNER JOIN times_assessed
    ON (students.school_id = times_assessed.school_id AND
        courses.id = times_assessed.course_id AND
        cog_skill_dimensions.id = times_assessed.cog_skill_id)
  INNER JOIN assessments_remaining
    ON (students.school_id = assessments_remaining.school_id AND
        courses.id = assessments_remaining.course_id AND
        cog_skill_dimensions.id = assessments_remaining.cog_skill_id)


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
  courses.grade_level,
  subjects.name,
  courses.name,
  teachers.last_name,
  teachers.first_name,
  students.last_name,
  students.first_name,
  projects.name,
  cog_skill_domains.name,
  cog_skill_dimensions.name
;
