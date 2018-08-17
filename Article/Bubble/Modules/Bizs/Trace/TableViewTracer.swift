//
//  TableViewTracer.swift
//  Article
//
//  Created by leo on 2018/8/16.
//

import Foundation
import RxCocoa
import RxSwift
protocol TableViewTracer {
}

extension TableViewTracer {
    func callTracer(tracer: [ElementRecord]?, atIndexPath: IndexPath, traceParams: TracerParams) {
        if let tracer = tracer, tracer.count > atIndexPath.row {
            tracer[atIndexPath.row](traceParams)
        }
    }
}
