//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

public struct QuizEditorView: View {
    let courseID: String
    let quizID: String?

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var assignmentID: String?
    @State var assignment: Assignment?
    @State var quiz: Quiz?
    @State var canUnpublish: Bool = true
    @State var description: String = ""
    @State var gradingType: GradingType = .points
    @State var name: String = ""
    @State var overrides: [AssignmentOverridesEditor.Override] = []
    @State var pointsPossible: Double?
    @State var published: Bool = false

    @State var isLoading = true
    @State var isLoaded = false
    @State var isSaving = false
    @State var isTeacher = false
    @State var rceHeight: CGFloat = 60
    @State var rceCanSubmit = false
    @State var alert: AlertItem?

    public init(courseID: String, quizID: String) {
        self.courseID = courseID
        self.quizID = quizID
    }

    public var body: some View {
        form
            .navigationBarTitle(Text("Edit Quiz Details", bundle: .core), displayMode: .inline)
            .navBarItems(leading: {
                Button(action: {
                    env.router.dismiss(controller)
                }, label: {
                    Text("Cancel", bundle: .core).fontWeight(.regular)
                })
                    .identifier("screen.dismiss")
            }, trailing: {
                Button(action: save, label: {
                    Text("Done", bundle: .core).bold()
                })
                    .disabled(isLoading || isSaving)
                    .identifier("AssignmentEditor.doneButton")
            })

            .alert(item: $alert) { alert in
                switch alert {
                case .error(let error):
                    return Alert(title: Text(error.localizedDescription))
                case .removeOverride(let override):
                    return AssignmentOverridesEditor.alert(toRemove: override, from: $overrides)
                }
            }

            .onAppear(perform: load)
    }

    enum AlertItem: Identifiable {
        case error(Error)
        case removeOverride(AssignmentOverridesEditor.Override)

        var id: String {
            switch self {
            case .error(let error):
                return error.localizedDescription
            case .removeOverride(let override):
                return "remove override \(override.id)"
            }
        }
    }

    var form: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            EditorSection(label: Text("Title", bundle: .core)) {
                CustomTextField(placeholder: Text("Add Title", bundle: .core),
                                text: $name,
                                identifier: "QuizEditor.titleField",
                                accessibilityLabel: Text("Title", bundle: .core))
            }

            EditorSection(label: Text("Description", bundle: .core)) {
                RichContentEditor(
                    placeholder: NSLocalizedString("Add description", comment: ""),
                    a11yLabel: NSLocalizedString("Description", comment: ""),
                    html: $description,
                    context: .course(courseID),
                    uploadTo: .context(.course(courseID)),
                    height: $rceHeight,
                    canSubmit: $rceCanSubmit,
                    error: Binding(get: {
                        if case .error(let error) = alert { return error }
                        return nil
                    }, set: {
                        if let error = $0 { alert = .error(error) }
                    })
                )
                    .frame(height: max(200, rceHeight))
            }

            EditorSection(label: Text("Options", bundle: .core)) {
                DoubleFieldRow(
                    label: Text("Points", bundle: .core),
                    placeholder: "--",
                    value: $pointsPossible
                )
                    .identifier("QuizEditor.pointsField")
                Divider()
                ButtonRow(action: {
                    let options = GradingType.allCases
                    self.env.router.show(ItemPickerViewController.create(
                        title: NSLocalizedString("Display Grade as", comment: ""),
                        sections: [ ItemPickerSection(items: options.map {
                            ItemPickerItem(title: $0.string)
                        }), ],
                        selected: options.firstIndex(of: gradingType).flatMap {
                            IndexPath(row: $0, section: 0)
                        },
                        didSelect: { gradingType = options[$0.row] }
                    ), from: controller)
                }, content: {
                    Text("Display Grade as", bundle: .core)
                    Spacer()
                    Text(gradingType.string)
                        .font(.medium16).foregroundColor(.textDark)
                    Spacer().frame(width: 16)
                    DisclosureIndicator()
                })
                    .identifier("QuizEditor.gradingTypeButton")
                if !published || canUnpublish {
                    Divider()
                    Toggle(isOn: $published) { Text("Publish", bundle: .core) }
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .padding(16)
                        .identifier("QuizEditor.publishedToggle")
                }
            }

            AssignmentOverridesEditor(
                courseID: courseID,
                groupCategoryID: assignment?.groupCategoryID,
                overrides: $overrides,
                toRemove: Binding(get: {
                    if case .removeOverride(let override) = alert {
                        return override
                    }
                    return nil
                }, set: {
                    alert = $0.map { AlertItem.removeOverride($0) }
                })
            )
        }
    }

    func load() {
        guard !isLoaded, let quizID = quizID else { return }
        let useCase = GetQuiz(courseID: courseID, quizID: quizID)
        useCase.fetch(force: true) { _, _, fetchError in performUIUpdate {
            quiz = env.database.viewContext.fetch(scope: useCase.scope).first
            assignmentID = quiz?.assignmentID
            //TODO quiz only attributes

            isLoading = false
            isLoaded = true
            alert = fetchError.map { .error($0) }
            loadAssignment()
        } }
    }

    func loadAssignment() {
        guard !isLoaded, let assignmentID = assignmentID else { return }
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [ .overrides ])
        useCase.fetch(force: true) { _, _, fetchError in performUIUpdate {
            assignment = env.database.viewContext.fetch(scope: useCase.scope).first
            canUnpublish = assignment?.canUnpublish == true
            description = assignment?.details ?? ""
            gradingType = assignment?.gradingType ?? .points
            name = assignment?.name ?? ""
            overrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) } ?? []
            pointsPossible = assignment?.pointsPossible
            published = assignment?.published == true

            isLoading = false
            isLoaded = true
            alert = fetchError.map { .error($0) }
        } }
    }

    func save() {
        controller.view.endEditing(true) // dismiss keyboard
        isSaving = true
        let originalOverrides = assignment.map { AssignmentOverridesEditor.overrides(from: $0) }
        guard
            let assignmentID = assignmentID,
            let assignment = assignment,
            assignment.details != description ||
            assignment.gradingType != gradingType ||
            assignment.pointsPossible != pointsPossible ||
            assignment.published != published ||
            assignment.name != name ||
            originalOverrides != overrides
        else {
            isSaving = false
            return env.router.dismiss(controller)
        }
        let (dueAt, unlockAt, lockAt, apiOverrides) = AssignmentOverridesEditor.apiOverrides(for: assignment.id, from: overrides)
        UpdateAssignment(
            courseID: courseID,
            assignmentID: assignmentID,
            description: description,
            dueAt: dueAt,
            gradingType: gradingType,
            lockAt: lockAt,
            name: name,
            overrides: originalOverrides == overrides ? nil : apiOverrides,
            pointsPossible: pointsPossible,
            published: published,
            unlockAt: unlockAt
        ).fetch { result, _, fetchError in performUIUpdate {
            alert = fetchError.map { .error($0) }
            isSaving = false
            if result != nil {
                GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [ .overrides ])
                    .fetch(force: true) // updated overrides & allDates aren't in result
                env.router.dismiss(controller)
            }
        } }
    }
}
