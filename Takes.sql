(
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
    sped_cases.dbid IS NOT NULL AS "Student Is Special Ed?",
    case_managers.first_name AS "Case Manager First Name",
    case_managers.last_name AS "Case Manager Last Name",

    -- Course & Teacher Info
    subjects.name AS "Subject",
    courses.grade_level AS "Course Grade Level",
    courses.name AS "Course Name",
    teachers.last_name AS "Teacher Last Name",
    teachers.first_name AS "Teacher First Name",
    teachers.email AS "Teacher Email",
    sections.sis_id AS "Illuminate Section ID",
    sections.name AS "Period Name",

    -- Content Assessment Info
    course_know_dos.level AS "Power Level",
    know_dos.name AS "Focus Area Name",
    assessment_takes.is_content_assessment AS "Content Assessment?",
    assessments.type AS "Assessment Type",
    course_know_dos.sequence AS "Sequence",
    CONVERT_TIMEZONE('US/Pacific', assessment_takes.taken_at) AS "Date Taken",
    assessment_takes.num_correct AS "Num Correct",
    assessment_takes.num_possible AS "Num Possible",
    (
      CASE assessment_takes.is_content_assessment
        WHEN TRUE THEN
          (assessment_takes.num_correct / CAST (assessment_takes.num_possible AS FLOAT)) >= know_dos.pcnt_to_pass
        WHEN FALSE THEN NULL
      END
    ) AS "Mastered?",
    NULL AS "Reason"


  FROM latest_scrape_students AS students
    LEFT OUTER JOIN latest_scrape_sped_cases AS sped_cases
      ON sped_cases.student_id = students.dbid
    LEFT OUTER JOIN latest_scrape_teachers AS case_managers
      ON case_managers.dbid = sped_cases.teacher_id
    LEFT OUTER JOIN latest_scrape_teachers AS mentors
      ON mentors.dbid = students.mentor_id
    INNER JOIN latest_scrape_course_assignments AS course_assignments
      ON course_assignments.student_id = students.dbid
    INNER JOIN latest_scrape_sites AS sites
      ON sites.dbid = course_assignments.site_id  -- pulls site info for enrolled courses
    INNER JOIN latest_scrape_districts AS districts
      ON districts.dbid = sites.district_id
    INNER JOIN latest_scrape_courses AS courses
      ON courses.dbid = course_assignments.course_id
    INNER JOIN latest_scrape_course_assignment_sections AS course_assignment_sections
      ON course_assignment_sections.course_assignment_id = course_assignments.dbid
    INNER JOIN latest_scrape_subjects AS subjects
      ON subjects.dbid = courses.subject_id
    INNER JOIN latest_scrape_sections AS sections
      ON sections.dbid = course_assignment_sections.section_id
    INNER JOIN latest_scrape_section_teachers AS section_teachers
      ON section_teachers.section_id = sections.dbid
    INNER JOIN latest_scrape_teachers AS teachers
      ON teachers.dbid = section_teachers.teacher_id
    INNER JOIN latest_scrape_course_know_dos AS course_know_dos
      ON course_know_dos.course_id = courses.dbid
    INNER JOIN latest_scrape_know_dos AS know_dos
      ON know_dos.dbid = course_know_dos.know_do_id
    LEFT OUTER JOIN latest_scrape_assessment_takes AS assessment_takes
      ON assessment_takes.student_id = students.dbid AND assessment_takes.know_do_id = know_dos.dbid
    LEFT OUTER JOIN scrape_assessments AS assessments --no latest_scrape_assessments
      ON assessments.dbid = assessment_takes.assessment_id

  WHERE

        districts.dbid = 1  -- 1 = Summit Public Schools
    AND courses.academic_year = 2016
    AND sites.name NOT IN ('Unknown Summit', 'SPS Demo')
    AND students.last_leave_on > '2016-06-01' -- Date selected near end of 2015-2016. If during school year, adjust to CURRENT_DATE.
    AND subjects.core = TRUE

    AND course_assignments.visibility = 'visible'
    AND section_teachers.visibility = 'visible'
    AND courses.visibility = 'visible'
    AND teachers.visibility = 'visible'
    AND students.visibility = 'visible'
    AND assessment_takes.visibility = 'visible'
    AND know_dos.visibility = 'visible'
    -- assessment_takes.taken_at >= '2015-08-17' AND   -- Optional: include if only want takes done during this school year (first day of school 8/17/2015)
    AND assessment_takes.is_content_assessment = TRUE   -- Optional: remove to include Diagnostic and Content Assessments

)


UNION


(
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
    sped_cases.dbid IS NOT NULL AS "Student Is Special Ed?",
    case_managers.first_name AS "Case Manager First Name",
    case_managers.last_name AS "Case Manager Last Name",

    -- Course & Teacher Info
    subjects.name AS "Subject",
    courses.grade_level AS "Course Grade Level",
    courses.name AS "Course Name",
    teachers.last_name AS "Teacher Last Name",
    teachers.first_name AS "Teacher First Name",
    teachers.email AS "Teacher Email",
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

  FROM latest_scrape_students AS students
    LEFT OUTER JOIN latest_scrape_sped_cases AS sped_cases
      ON sped_cases.student_id = students.dbid
    LEFT OUTER JOIN latest_scrape_teachers AS case_managers
      ON case_managers.dbid = sped_cases.teacher_id
    LEFT OUTER JOIN latest_scrape_teachers AS mentors
      ON mentors.dbid = students.mentor_id
    INNER JOIN latest_scrape_course_assignments AS course_assignments
      ON course_assignments.student_id = students.dbid
    INNER JOIN latest_scrape_sites AS sites
      ON sites.dbid = course_assignments.site_id  -- pulls site info for enrolled courses
    INNER JOIN latest_scrape_districts AS districts
      ON districts.dbid = sites.district_id
    INNER JOIN latest_scrape_courses AS courses
      ON courses.dbid = course_assignments.course_id
    INNER JOIN latest_scrape_course_assignment_sections AS course_assignment_sections
      ON course_assignment_sections.course_assignment_id = course_assignments.dbid
    INNER JOIN latest_scrape_subjects AS subjects
      ON subjects.dbid = courses.subject_id
    INNER JOIN latest_scrape_sections AS sections
      ON sections.dbid = course_assignment_sections.section_id
    INNER JOIN latest_scrape_section_teachers AS section_teachers
      ON section_teachers.section_id = sections.dbid
    INNER JOIN latest_scrape_teachers AS teachers
      ON teachers.dbid = section_teachers.teacher_id
    INNER JOIN latest_scrape_course_know_dos AS course_know_dos
      ON course_know_dos.course_id = courses.dbid
    INNER JOIN latest_scrape_know_dos AS know_dos
      ON know_dos.dbid = course_know_dos.know_do_id
    LEFT OUTER JOIN latest_scrape_know_do_masteries AS know_do_masteries
      ON know_do_masteries.know_do_id = know_dos.dbid AND know_do_masteries.student_id = students.dbid


  WHERE
        districts.dbid = 1  -- 1 = Summit Public Schools
    AND courses.academic_year = 2017
    AND sites.name NOT IN ('Unknown Summit', 'SPS Demo')
    AND students.last_leave_on > CURRENT_DATE -- Date selected near end of 2015-2016. If during school year, adjust to CURRENT_DATE.
    AND subjects.core = TRUE
    AND course_assignments.visibility = 'visible'
    AND section_teachers.visibility = 'visible'
    AND courses.visibility = 'visible'
    AND teachers.visibility = 'visible'
    AND students.visibility = 'visible'
    AND know_dos.visibility = 'visible'
    AND know_do_masteries.reason IS NOT NULL
    AND know_do_masteries.reason != 'plp'
    AND know_do_masteries.reason != 'illuminate'
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
