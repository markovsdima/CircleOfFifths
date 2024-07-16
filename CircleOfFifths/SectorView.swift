import SwiftUI

struct Sector: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadiusRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = rect.width / 2
        let innerRadius = outerRadius * innerRadiusRatio
        
        var path = Path()
        path.move(to: CGPoint(x: center.x + innerRadius * cos(CGFloat(startAngle.radians)),
                              y: center.y + innerRadius * sin(CGFloat(startAngle.radians))))
        path.addArc(center: center,
                    radius: innerRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.addLine(to: CGPoint(x: center.x + outerRadius * cos(CGFloat(endAngle.radians)),
                                 y: center.y + outerRadius * sin(CGFloat(endAngle.radians))))
        path.addArc(center: center,
                    radius: outerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true)
        path.closeSubpath()
        
        return path
    }
}
