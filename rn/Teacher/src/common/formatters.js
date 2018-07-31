//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import i18n from 'format-message'
import { isDateValid } from '../utils/dateUtils'

export function formattedDueDate (date: ?Date): string {
  if (!date || !isDateValid(date)) return i18n('No Due Date')
  return i18n('{date, date, medium} at {date, time, short}', { date })
}

export function formattedDueDateWithStatus (dueAt: ?Date, lockAt: ?Date): string[] {
  const dateString = formattedDueDate(dueAt)
  if (dateString === i18n('No Due Date')) return [dateString]
  const now = new Date()
  if (lockAt && now > lockAt) {
    return [i18n('Closed'), dateString]
  }
  return [i18n('Due {dateString}', { dateString })]
}

export function formatGrade (grade: number) {
  // Truncates to 2 decimal places
  // We truncate instead of round because we don't want to round to next integer
  const truncated = Math.trunc(grade * 100) / 100
  return i18n.number(truncated, 'grade')
}

// This is for Teacher
export function formatGradeText (grade: ?string, gradingType?: GradingType, pointsPossible?: number): ?string {
  if (!['points', 'percent'].includes(gradingType)) {
    switch (grade) {
      case 'pass':
        return i18n('Pass')
      case 'complete':
        return i18n('Complete')
      case 'fail':
        return i18n('Fail')
      case 'incomplete':
        return i18n('Incomplete')
    }

    if (isNaN(grade)) {
      return grade
    }

    return formatGrade(Number(grade))
  }

  if (gradingType === 'percent') {
    const percent = +(grade || '').split('%')[0]
    return i18n.number(percent / 100, 'percent')
  }
  const gradeNum = formatGrade(Number(grade))

  if (gradingType === 'points' && pointsPossible) {
    return `${gradeNum}/${formatGrade(pointsPossible)}`
  }

  return gradeNum
}

// This is for Student
export function formatStudentGrade (assignment: Assignment) {
  const { grading_type, submission } = assignment
  const pointsPossible = formatGrade(assignment.points_possible)

  if (!submission) {
    return `- / ${pointsPossible}`
  }

  const { excused, grade } = submission

  if (excused) {
    return `${i18n('Excused')} / ${pointsPossible}`
  }

  if (submission.score == null) {
    return `- / ${pointsPossible}`
  }

  const score = formatGrade(submission.score)

  switch (grading_type) {
    case 'pass_fail':
      let status = '-'
      switch (submission.grade) {
        case 'complete':
          status = i18n('Complete')
          break
        case 'incomplete':
          status = i18n('Incomplete')
          break
      }
      return `${status} / ${pointsPossible}`
    case 'points':
      return `${formatGrade(Number(grade))} / ${pointsPossible}`
    case 'percent':
    case 'letter_grade':
    case 'gpa_scale':
      return `${score} / ${pointsPossible} (${grade})`
    case 'not_graded':
      // These types should be getting filtered out of the grades list
      // so this case should never be called
      // but we'll return an empty string to keep this return type non-optional
      return ''
  }
}
