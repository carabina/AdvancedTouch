//
//  ViewController.swift
//  AdvancedTouch
//
//  Created by Simon Gladman on 17/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let mainDrawLayer = CAShapeLayer()
    let mainDrawPath = UIBezierPath()
    
    let coalescedDrawLayer = CAShapeLayer()
    let coalescedDrawPath = UIBezierPath()

    let predictedDrawLayer = CAShapeLayer()
    let predictedDrawPath = UIBezierPath()
    
    let layers: [CAShapeLayer]
    let paths: [UIBezierPath]

    required init?(coder aDecoder: NSCoder)
    {
        layers = [mainDrawLayer, coalescedDrawLayer, predictedDrawLayer]
        paths = [mainDrawPath, coalescedDrawPath, predictedDrawPath]
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        // common
        
        for layer in layers
        {
            layer.lineCap = kCALineCapRound
            layer.lineWidth = 2
            layer.fillColor = nil
            
            view.layer.addSublayer(layer)
        }
        
        // mainDrawLayer
        
        mainDrawLayer.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1).CGColor
        
        // coalescedDrawLayer
        
        coalescedDrawLayer.strokeColor = UIColor.yellowColor().CGColor

        // predictedDrawLayer
        
        predictedDrawLayer.strokeColor = UIColor.whiteColor().CGColor
        predictedDrawLayer.lineWidth = 1
        predictedDrawLayer.fillColor = UIColor.whiteColor().CGColor
    }


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent: event)
        
        for (path, layer) in zip(paths, layers)
        {
            path.removeAllPoints()
            
            layer.path = path.CGPath
            layer.hidden = false
        }
        
        guard let touch = touches.first else
        {
            return
        }
        
        let locationInView = touch.locationInView(view)
        
        for path in paths
        {
            path.moveToPoint(locationInView)
        }
        
        for layer in layers
        {
            layer.hidden = false
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesMoved(touches, withEvent: event)
        
        guard let touch = touches.first, event = event else
        {
            return
        }
        
        let locationInView = touch.locationInView(view)
        
        mainDrawPath.addLineToPoint(locationInView)
        mainDrawPath.appendPath(UIBezierPath.createCircleAtPoint(locationInView, radius: 4))
        mainDrawPath.moveToPoint(locationInView)
        
        mainDrawLayer.path = mainDrawPath.CGPath
        
        // draw coalescedTouches
        
        if let coalescedTouches = event.coalescedTouchesForTouch(touch)
        {
            print("coalescedTouches:", coalescedTouches.count)
            
            for coalescedTouch in coalescedTouches
            {
                let locationInView = coalescedTouch.locationInView(view)
                
                coalescedDrawPath.addLineToPoint(locationInView)
                coalescedDrawPath.appendPath(UIBezierPath.createCircleAtPoint(locationInView, radius: 2))
                coalescedDrawPath.moveToPoint(locationInView)
            }
            
            coalescedDrawLayer.path = coalescedDrawPath.CGPath
        }
        
        // draw predictedTouches
        
        if let predictedTouches = event.predictedTouchesForTouch(touch)
        {
            print("predictedTouches:", predictedTouches.count)
            
            for predictedTouch in predictedTouches
            {
                let locationInView =  predictedTouch.locationInView(view)
                
                predictedDrawPath.moveToPoint(touch.locationInView(view))
                predictedDrawPath.addLineToPoint(locationInView)
                
                predictedDrawPath.appendPath(UIBezierPath.createCircleAtPoint(locationInView, radius: 1))
            }
            
            predictedDrawLayer.path = predictedDrawPath.CGPath
        }
        
        // stupid synchronous calculation
        
        var foo = Double(1)
        
        for bar in 0 ... 4_000_000
        {
            foo += sqrt(Double(bar))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesEnded(touches, withEvent: event)
        
      
    }
}

extension UIBezierPath
{
    static func createCircleAtPoint(origin: CGPoint, radius: CGFloat) -> UIBezierPath
    {
        let boundingRect = CGRect(x: origin.x - radius,
            y: origin.y - radius,
            width: radius * 2,
            height: radius * 2)
        
        let circle = UIBezierPath(ovalInRect: boundingRect)
        
        return circle
    }
}

