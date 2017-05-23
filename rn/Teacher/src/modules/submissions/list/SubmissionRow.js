// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import Token from '../../../common/components/Token'
import i18n from 'format-message'
import type {
  GradeProp,
  SubmissionStatusProp,
} from './submission-prop-types'
import colors from '../../../common/colors'
import { Text } from '../../../common/text'
import SubmissionStatus from './SubmissionStatus'
import Avatar from '../../../common/components/Avatar'

type RowProps = {
  +testID: string,
  +onPress: () => void,
  +children?: Array<any>,
  +disclosure?: boolean,
}

export type SubmissionRowDataProps = {
  userID: string,
  avatarURL: string,
  name: string,
  status: SubmissionStatusProp,
  grade: GradeProp,
  score: ?number,
  disclosure?: boolean,
}

export type SubmissionRowProps = {
  onPress: () => void,
} & SubmissionRowDataProps

class Row extends Component<any, RowProps, any> {
  render () {
    const { onPress, testID, children, disclosure } = this.props
    return (
      <View style={styles.row}>
        <TouchableHighlight style={styles.touchableHighlight} onPress={onPress} testID={testID}>
          <View style={styles.container}>
            {children}
            {disclosure && <DisclosureIndicator />}
          </View>
        </TouchableHighlight>
      </View>
    )
  }
}

const Grade = ({ grade }: {grade: ?GradeProp}): * => {
  if (!grade || grade === 'not_submitted') {
    return null
  }

  if (grade === 'ungraded') {
    const ungraded = i18n({
      default: 'ungraded',
      description: 'Label for ungraded assignment submission',
    })
    return <Token style={{ alignSelf: 'center' }} color={ colors.primaryButton }>{ ungraded }</Token>
  }

  let gradeText = grade
  if (grade === 'excused') {
    gradeText = i18n({
      default: 'Excused',
      description: `This assignment is excused and does not affect the student's grade`,
    })
  }

  return <Text style={[ styles.gradeText, { alignSelf: 'center' } ]}>{ gradeText }</Text>
}

class SubmissionRow extends Component<any, SubmissionRowProps, any> {
  onPress = () => {
    this.props.onPress(this.props.userID)
  }

  render (): React.Element<View> {
    let { userID, avatarURL, name, status, grade, disclosure } = this.props
    if (disclosure === undefined) {
      disclosure = true
    }
    return (
      <Row disclosure={disclosure} testID={`submission-${userID}`} onPress={this.onPress}>
        <View style={styles.avatar}>
          <Avatar
            key={userID}
            avatarURL={avatarURL}
            userName={name} />
        </View>
        <View style={styles.textContainer}>
          <Text
            style={styles.title}
            ellipsizeMode='tail'
            numberOfLines={2}>{name}</Text>
          <SubmissionStatus status={status} />
        </View>
        <Grade grade={grade} />
      </Row>
    )
  }
}

export default SubmissionRow

const styles = StyleSheet.create({
  row: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
  },
  touchableHighlight: {
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
    alignItems: 'flex-start',
    flexDirection: 'row',
    paddingTop: 10,
    paddingBottom: 10,
    paddingLeft: 16,
    paddingRight: 16,
  },
  textContainer: {
    flex: 1,
    paddingLeft: 8,
  },
  title: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#2D3B45',
  },
  gradeText: {
    fontSize: 14,
    color: colors.primaryButton,
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: 8,
  },
})
