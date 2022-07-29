//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct SuccessPanda: PandaScene {
    public var name: String { "success" }
    public var offset: (background: CGSize, foreground: CGSize) {(
        background: CGSize(width: 0, height: 90),
        foreground: CGSize(width: 0, height: -30))
    }
    public var height: CGFloat { 220 }
}

struct SuccessPanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: SuccessPanda(), title: Text(verbatim: "Title"), subtitle: Text(verbatim: "Subtitle"))
            .background(Color.red)
    }
}
