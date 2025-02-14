// This SwiftUI example defines and visualizes a generalized Bézier curve function for three or more control points.
// The code includes helper functions to compute the binomial coefficient and a single point on the curve using the Bernstein basis.
// A custom Shape, BezierCurveShape, is then used within a SwiftUI view to draw both the control polygon and the Bézier curve.
// Michael Stebel
// 2/13/2025

import SwiftUI

// Compute the binomial coefficient ("n choose k")
func binomialCoefficient(n: Int, k: Int) -> Int {
    guard k >= 0 && k <= n else { return 0 }
    var result = 1
    for i in 1...k {
        result = result * (n - i + 1) / i
    }
    return result
}

// Calculate a single point on the Bézier curve at parameter t (0 <= t <= 1)
func bezierPoint(controlPoints: [CGPoint], t: CGFloat) -> CGPoint {
    let n = controlPoints.count - 1
    var point = CGPoint.zero
    for i in 0...n {
        let coefficient = CGFloat(binomialCoefficient(n: n, k: i))
        let term = coefficient * pow(1 - t, CGFloat(n - i)) * pow(t, CGFloat(i))
        point.x += term * controlPoints[i].x
        point.y += term * controlPoints[i].y
    }
    return point
}

// Define a custom Shape that draws the Bézier curve by sampling points along the curve.
struct BezierCurveShape: Shape {
    var controlPoints: [CGPoint]
    var steps: Int = 100  // Increase for a smoother curve
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard controlPoints.count > 1 else { return path }
        
        // Start at t = 0
        let start = bezierPoint(controlPoints: controlPoints, t: 0)
        path.move(to: start)
        
        // Sample the curve at evenly spaced values of t
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let p = bezierPoint(controlPoints: controlPoints, t: t)
            path.addLine(to: p)
        }
        return path
    }
}

// A sample SwiftUI view that shows the control polygon and the Bézier curve.
struct ContentView: View {
    // Define an array of control points (3 or more points)
    let controlPoints: [CGPoint] = [
        CGPoint(x: 50, y: 300),
        CGPoint(x: 150, y: 50),
        CGPoint(x: 250, y: 350),
        CGPoint(x: 350, y: 150)
    ]
    
    var body: some View {
        ZStack {
            // Draw the control polygon (dashed gray lines)
            Path { path in
                guard let first = controlPoints.first else { return }
                path.move(to: first)
                for point in controlPoints.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
            
            // Draw control points as red circles
            ForEach(controlPoints, id: \.self) { point in
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(point)
            }
            
            // Draw the Bézier curve in blue
            BezierCurveShape(controlPoints: controlPoints)
                .stroke(Color.blue, lineWidth: 2)
        }
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
}

// Preview provider for SwiftUI previews.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
