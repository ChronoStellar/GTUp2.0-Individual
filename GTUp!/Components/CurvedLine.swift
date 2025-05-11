//
//  CurvedLine.swift
//  GTUp!
//
//  Created by Hendrik Nicolas Carlo on 09/05/25.
//

import SwiftUI

struct CurvedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let endPoint = CGPoint(x: rect.maxX, y: rect.minY)
        let controlPoint1 = CGPoint(x: rect.midX - 50, y: rect.maxY)
        let controlPoint2 = CGPoint(x: rect.midX + 50, y: rect.minY)
        
        path.move(to: startPoint)
        path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
        
        return path
    }
}

#Preview {
    CurvedLine()
}
