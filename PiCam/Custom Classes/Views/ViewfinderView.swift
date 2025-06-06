//
//  ViewfinderView.swift
//  PiCam
//
//  Created by Tyson Miles on 9/4/2025.
import UIKit

class ViewfinderView: UIView {
    
    // MARK: - Customizable Properties
    /// The base length of each L-shaped corner line.
    var baseCornerLength: CGFloat = 30.0
    /// The thickness of the corner lines.
    var lineThickness: CGFloat = 9.0
    /// The minimum scale for the expand-retract animation (e.g. 50% of the original size).
    var minScale: CGFloat = 0.69
    /// The maximum scale for the expand-retract animation (e.g. 100% of the original size).
    var maxScale: CGFloat = 0.8
    /// The duration (in seconds) of one complete expand-retract cycle.
    var animationDuration: TimeInterval = 1.8
    
    // MARK: - Private Properties
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        // Force the view size to be 128x128.
        let fixedFrame = CGRect(origin: frame.origin, size: CGSize(width: 128, height: 128))
        super.init(frame: fixedFrame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Optionally override frame size via layout constraints externally.
        self.frame.size = CGSize(width: 128, height: 128)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    // MARK: - Animation
    @objc private func updateAnimation() {
        guard let startTime = animationStartTime else { return }
        let elapsed = CACurrentMediaTime() - startTime
        // Smooth sine-wave oscillation producing a value between 0 and 1.
        let progress = (sin((2 * .pi / animationDuration) * elapsed) + 1) / 2
        // Compute current scale based on progress.
        let scale = minScale + (maxScale - minScale) * CGFloat(progress)
        // Apply scaling transform to expand or retract the entire viewfinder.
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        // Define the drawing rectangle by insetting half the line thickness to avoid clipping.
        let drawingRect = rect.insetBy(dx: lineThickness / 2, dy: lineThickness / 2)
        
        // We use the baseCornerLength unchanged for the drawing, so the corner lines remain fixed relative to the view.
        let effectiveCornerLength = baseCornerLength
        
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round
        
        // Top Left Corner
        // Horizontal line.
        path.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.minY))
        path.addLine(to: CGPoint(x: drawingRect.minX + effectiveCornerLength, y: drawingRect.minY))
        // Vertical line.
        path.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.minY))
        path.addLine(to: CGPoint(x: drawingRect.minX, y: drawingRect.minY + effectiveCornerLength))
        
        // Top Right Corner
        // Horizontal line.
        path.move(to: CGPoint(x: drawingRect.maxX - effectiveCornerLength, y: drawingRect.minY))
        path.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.minY))
        // Vertical line.
        path.move(to: CGPoint(x: drawingRect.maxX, y: drawingRect.minY))
        path.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.minY + effectiveCornerLength))
        
        // Bottom Left Corner
        // Horizontal line.
        path.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY))
        path.addLine(to: CGPoint(x: drawingRect.minX + effectiveCornerLength, y: drawingRect.maxY))
        // Vertical line.
        path.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY - effectiveCornerLength))
        path.addLine(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY))
        
        // Bottom Right Corner
        // Horizontal line.
        path.move(to: CGPoint(x: drawingRect.maxX - effectiveCornerLength, y: drawingRect.maxY))
        path.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.maxY))
        // Vertical line.
        path.move(to: CGPoint(x: drawingRect.maxX, y: drawingRect.maxY - effectiveCornerLength))
        path.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.maxY))
        
        // Set the color for the lines.
        UIColor.white.setStroke()
        path.stroke()
    }
}
