//
//  Circle.swift
//  UIKitDynamicsDemo
//
//  Created by Stoyan Stoyanov on 1/6/17.
//  Copyright © 2017 Stoyan Stoyanov. All rights reserved.
//

import UIKit

//MARK: - Random Colors

extension UIColor {
    static fileprivate var popsRandom: UIColor {
        get {
            let possibleColors = [UIColor.popsRed, .popsBlue, .popsGray, .popsBlack,
                                  .popsGreen, .popsOrange, .popsYellow, .popsDimGreen]
            
            let randomIndex = arc4random_uniform(UInt32(possibleColors.count))
            return possibleColors[Int(randomIndex)]
        }
    }
}

//MARK: - Random Sizes

extension CGRect {
    static fileprivate var randomCircleSize: CGRect {
        let possibleSizes = [92.5, 44.0, 56.0, 40.0, 30.0, 20.0]
        let randomIndex = arc4random_uniform(UInt32(possibleSizes.count))
        let selectedSize = possibleSizes[Int(randomIndex)]
        return CGRect(x: 0, y: 0, width: selectedSize, height: selectedSize)
    }
}

//MARK: - Circles Creation

class Circle: UIView {
    
    static let strokedCirclesUpperSizeBound: CGFloat = 25
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {  return .ellipse }
    
    static var randomCircle: Circle {
        let circle = Circle(frame: CGRect.randomCircleSize)
        circle.layer.cornerRadius = circle.frame.width / 2.0
        circle.clipsToBounds = true
        
        if circle.frame.width <= Circle.strokedCirclesUpperSizeBound {
            let shouldStroke = Bool(NSNumber(value: arc4random_uniform(UInt32(2))))
            
            if shouldStroke {
                circle.layer.borderColor = UIColor.popsRandom.cgColor
                circle.layer.borderWidth = 2
                circle.backgroundColor = UIColor.clear
            } else {
                circle.backgroundColor = UIColor.popsRandom
            }
        } else {
            circle.backgroundColor = UIColor.popsRandom
        }
        return circle
    }
}
