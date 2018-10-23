//
// Created by linlin on 2018/7/5.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation

extension Array {
    func take(_ count: Int) -> [Element] {
        var re: [Element] = self
        if count < self.count {
            re.removeLast(self.count - count)
        }
        return re
    }
}
