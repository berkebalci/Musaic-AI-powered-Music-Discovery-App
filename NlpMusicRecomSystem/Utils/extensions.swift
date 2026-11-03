import Foundation
extension Date {
    func isWithinPast(_ value: Int, _ component: Calendar.Component) -> Bool {
        let now = Date()
        guard self <= now else { return false }
        guard let limitDate = Calendar.current.date(byAdding: component, value: -value, to: now) else {
            return false
        }
        return self >= limitDate
    }
}//
//  extensions.swift
//  NlpMusicRecomSystem
//
//  Created by Berkenin Bilgisayarı on 30.10.2026.
//

