//
//  ScannerMarkerView.swift
//  Kassa Forus
//
//  Created by Jamal on 22/07/2017.
//  Copyright © 2017 Forus. All rights reserved.
//

import UIKit

@IBDesignable class ScannerMarkerView: UIView {

    override func draw(_ rect: CGRect) {
        //// General Declarations
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Color Declarations
        let color3 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        //// Frames
        let frame = rect
        
        //// Subframes
        let frame2 = CGRect(x: frame.minX + fastFloor((frame.width - 202) * 0.50000 + 0.5), y: frame.minY + fastFloor((frame.height - 357) * 0.59631 + 0.5), width: 202, height: 357)
        
        
        //// Group
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + -0.00000 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.00000 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + -0.00000 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.00000 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.06296 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.00000 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.02337 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.06296 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.02903 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.00926 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 0.00926 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + -0.00000 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 0.00607 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 0.00298 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + -0.00000 * frame2.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.00926 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.05193 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.07882 * frame2.width, y: frame2.minY + 0.00926 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.03276 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.00926 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.06296 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.02903 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.06296 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.00000 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.02337 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.00000 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.00000 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.00926 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.00298 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.00607 * frame2.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.93333 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 1.00000 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.97517 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 0.99074 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 0.99703 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.88889 * frame2.width, y: frame2.minY + 0.99394 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.99074 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.93333 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.99074 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.98366 * frame2.width, y: frame2.minY + 0.96953 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 1.00000 * frame2.width, y: frame2.minY + 0.93333 * frame2.height))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.93333 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.99074 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.96953 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.99074 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.99074 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 1.00000 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.99394 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.11111 * frame2.width, y: frame2.minY + 0.99703 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 1.00000 * frame2.height))
        bezierPath.addCurve(to: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.93333 * frame2.height), controlPoint1: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 1.00000 * frame2.height), controlPoint2: CGPoint(x: frame2.minX + 0.00000 * frame2.width, y: frame2.minY + 0.97517 * frame2.height))
        bezierPath.addLine(to: CGPoint(x: frame2.minX + 0.01634 * frame2.width, y: frame2.minY + 0.93333 * frame2.height))
        bezierPath.close()
        color3.setFill()
        bezierPath.fill()
    }
}
