/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { QuizSubmissionBreakdownGraphSection, mapStateToProps } from '../QuizSubmissionBreakdownGraphSection'
import renderer from 'react-test-renderer'
import explore from '../../../../../../test/helpers/explore'
const template = {
  ...require('../../../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../../api/canvas-api/__templates__/quizSubmission'),
  ...require('../../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../../../redux/__templates__/app-state'),
}
jest.mock('LayoutAnimation', () => ({
  create: jest.fn(),
  configureNext: jest.fn(),
  easeInEaseOut: jest.fn(),
  Types: { linear: null },
  Properties: { opacity: null },
  onPress: jest.fn(),
}))
jest.mock('TouchableOpacity', () => 'TouchableOpacity')

let course: any = template.course()
let assignment: any = template.quiz()

let defaultProps = {}

beforeEach(() => {
  let a = template.quizSubmission({ id: 1, kept_score: 5 })
  let b = template.quizSubmission({ id: 2, workflow_state: 'untaken' })
  let c = template.quizSubmission({ id: 3, workflow_state: 'pending_review' })

  defaultProps = {
    courseID: course.id,
    quizID: assignment.assignmentID,
    refreshQuizSubmissions: (courseID: string, assignmentID: string) => {},
    refreshEnrollments: (courseID: string) => {},
    quizSubmissions: [{ data: a }, { data: b }, { data: c }],
    pending: 0,
    refresh: jest.fn(),
    refreshing: false,
    onPress: jest.fn(),
  }
})

test('render', () => {
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render 0 submissions', () => {
  defaultProps.quizSubmissions = []
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render multiple data points ', () => {
  let a = template.quizSubmission({ id: 1, kept_score: 1 })
  let b = template.quizSubmission({ id: 2, kept_score: 2 })
  let c = template.quizSubmission({ id: 3, kept_score: 3 })
  let d = template.quizSubmission({ id: 4, kept_score: 4 })
  let e = template.quizSubmission({ id: 5, kept_score: 5 })
  let f = template.quizSubmission({ id: 6, kept_score: 6 })
  defaultProps.quizSubmissions = [{ data: a }, { data: b }, { data: c }, { data: d }, { data: e }, { data: f }]

  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render loading with null submissions', () => {
  defaultProps.quizSubmissions = null
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render loading with pending set', () => {
  defaultProps.pending = 1
  let tree = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('onPress is called graded dial', () => {
  testDialOnPress('quiz-submission_dial_0', 'graded')
})

test('onPress is called ungraded dial', () => {
  testDialOnPress('quiz-submission_dial_1', 'notgraded')
})

test('onPress is called not_submitted dial', () => {
  testDialOnPress('quiz-submission_dial_2', 'notsubmitted')
})

function testDialOnPress (expectedID: string, expectedValueParameter: string) {
  let component = renderer.create(
    <QuizSubmissionBreakdownGraphSection {...defaultProps} />
  )
  let dial: any = explore(component.toJSON()).selectByID(expectedID)
  dial.props.onPress()
  expect(defaultProps.onPress).toBeCalledWith(expectedValueParameter)
}

test('mapStateToProps', () => {
  const course = template.course()
  const quiz = template.quiz()

  const u1 = template.user({
    id: '1',
  })
  const e1 = template.enrollment({
    id: '1',
    user_id: u1.id,
    user: u1,
  })
  const qs1 = template.quizSubmission({
    id: '1',
    quiz_id: quiz.id,
    user_id: e1.user.id,
    workflow_state: 'pending_review',
  })

  const appState = template.appState({
    entities: {
      courses: {
        [course.id]: { enrollments: { refs: [e1.id] } },
      },
      enrollments: {
        [e1.id]: e1,
      },
      quizzes: {
        [quiz.id]: {
          data: quiz,
          quizSubmissions: { refs: [qs1.id] },
        },
      },
      quizSubmissions: {
        [qs1.id]: { data: qs1 },
      },
    },
  })

  const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
  expect(result).toMatchObject({
    enrollmentCount: 1,
    quizSubmissions: [
      {
        data: qs1,
      },
    ],
  })
})

test('mapStateToProps with no data should not explode', () => {
  const course = template.course()
  const quiz = template.quiz()
  const appState = template.appState()
  const result = mapStateToProps(appState, { courseID: course.id, quizID: quiz.id })
  expect(result).toMatchObject({
    enrollmentCount: 0,
    quizSubmissions: [],
  })
})
