// @flow

import 'react-native'
import React from 'react'
import CourseFavorite from '../CourseFavorite'
import explore from '../../../../../../test/helpers/explore'
import * as courseTemplate from '../../../../../api/canvas-api/__templates__/course'

import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  id: '1',
  course: courseTemplate.course(),
  isFavorite: true,
  onPress: () => Promise.resolve(),
}

test('renders favorited correctly', () => {
  let tree = renderer.create(
    <CourseFavorite {...defaultProps} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('renders unfavorited correctly', () => {
  let tree = renderer.create(
    <CourseFavorite {...defaultProps} isFavorite={false} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('calls props.onPress with the course id and the toggled favorite value', () => {
  let onPress = jest.fn()
  let tree = renderer.create(
    <CourseFavorite {...defaultProps} onPress={onPress} />
  ).toJSON()

  let buttonTestID = 'edit-favorites.course-favorite.' + defaultProps.course.id + '-favorited'
  let button: any = explore(tree).selectByID(buttonTestID)
  button.props.onPress()

  expect(onPress).toHaveBeenCalledWith(defaultProps.course.id, false)
})
