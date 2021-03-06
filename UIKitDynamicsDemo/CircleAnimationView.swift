//
//  CircleAnimationView.swift
//  UIKitDynamicsDemo
//
//  Created by Stoyan Stoyanov on 1/7/17.
//  Copyright © 2017 Stoyan Stoyanov. All rights reserved.
//

import UIKit


class CircleAnimationView: UIView {

    var animator: UIDynamicAnimator!
    
    var circles:[Circle] = []
    var circlesBehaviour: [UIDynamicItemBehavior] = []
    
    var collision: UICollisionBehavior!
    var noiseGravityBehaviour: UIFieldBehavior!
    var radialTouchGravityBehaviour: UIFieldBehavior!

    
    
    
    //MARK: - Configuration
    var animationSpeed: AnimationSpeed? {
        willSet { applySpeed(newValue) }
    }
    
    enum AnimationSpeed {
        case slow
        case fast
    }
    
    let circlesCount = 35
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        animator = UIDynamicAnimator(referenceView: self)
        self.generateCircles()
        self.setupBehaviors()
        
        
        // uncoment to enable blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.4
        blurEffectView.frame = self.bounds
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        self.addSubview(blurEffectView)
        self.addSubview(vibrancyEffectView)
        
        // *****************************************
        
        // for enabling debubbing uncomment following lines
        //animator.setValue(true, forKey: "debugEnabled")
        //animator.setValue(0.05, forKey: "debugAnimationSpeed")
        
        // *****************************************
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        performEntranceAnimation()
    }
}

//MARK: - Animations 

extension CircleAnimationView {
    
    fileprivate func applySpeed(_ speed: AnimationSpeed?) {
        guard let speed = speed else { return }
        
        switch speed {
        
        case .slow:
            noiseGravityBehaviour.strength = 50
            self.noiseGravityBehaviour.smoothness = 0.6
            
        case .fast:
            self.noiseGravityBehaviour.strength = 100
            self.noiseGravityBehaviour.smoothness = 0.9
        }
    }
    
    fileprivate func performEntranceAnimation() {
        let expandTiming = CAMediaTimingFunction(controlPoints: Float(0.8), Float(0.0), Float(0.2), Float(1.0))
        let shrinkTiming = CAMediaTimingFunction(controlPoints: Float(0.0), Float(0.2), Float(0.7), Float(1.0))
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            
            // shrink step of animation
            let shrinkAnimation = CABasicAnimation(keyPath: "transform.scale")
            shrinkAnimation.fromValue = 1.1
            shrinkAnimation.toValue = 1
            shrinkAnimation.duration = 0.2
            shrinkAnimation.isRemovedOnCompletion = false
            shrinkAnimation.fillMode = kCAFillModeForwards
            shrinkAnimation.timingFunction = shrinkTiming
            
            for circle in self.circles {
                circle.layer.add(shrinkAnimation, forKey: "scale")
            }
        }
        // expand step of animation
        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.fromValue = 0
        expandAnimation.toValue = 1.1
        expandAnimation.duration = 1
        expandAnimation.isRemovedOnCompletion = false
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.timingFunction = expandTiming
      
        for circle in circles {
            circle.layer.add(expandAnimation, forKey: "scale")
        }
        CATransaction.commit()
    }
}

//MARK: - Generating Circles

extension CircleAnimationView {
    
    fileprivate func generateCircles() {
        
        for _ in 0...circlesCount {
            let circle = Circle.randomCircle
            self.addSubview(circle)
            circle.frame.origin = self.randomSpawnLocation
            circle.alpha = 0.8
            circles.append(circle)
            
            let circleBehaviour = UIDynamicItemBehavior(items: [circle])
            circleBehaviour.elasticity = 0.1
            circleBehaviour.friction = 0
            circleBehaviour.resistance = 0
            circleBehaviour.density = ( 100 - circle.frame.width / 100) * 8
            animator.addBehavior(circleBehaviour)
        }
    }
    
    var randomSpawnLocation: CGPoint {
        let x = arc4random_uniform(UInt32(self.frame.width))
        let y = arc4random_uniform(UInt32(self.frame.height))
        return CGPoint(x: Double(x), y: Double(y))
    }
}

//MARK: - Setting Physics Behaviours

extension CircleAnimationView {
    
    func setupBehaviors() {
        
        collision = UICollisionBehavior(items: circles)
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        // setting slow speed mode as default
        noiseGravityBehaviour = UIFieldBehavior.noiseField(smoothness: 0.6, animationSpeed: 0.3)
        noiseGravityBehaviour.strength = 50
        
        radialTouchGravityBehaviour = UIFieldBehavior.radialGravityField(position: .zero)
        radialTouchGravityBehaviour.minimumRadius = 100
        radialTouchGravityBehaviour.falloff = 3
        
        for circle in circles {
            noiseGravityBehaviour.addItem(circle)
            radialTouchGravityBehaviour.addItem(circle)
        }
        animator.addBehavior(noiseGravityBehaviour)
    }
}

//MARK: - Touches Handling

extension CircleAnimationView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        radialTouchGravityBehaviour.position = (touches.first?.location(in: self))!
        animator.removeBehavior(noiseGravityBehaviour)
        animator.addBehavior(radialTouchGravityBehaviour)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        radialTouchGravityBehaviour.position = (touches.first?.location(in: self))!
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animator.removeBehavior(radialTouchGravityBehaviour)
        animator.addBehavior(noiseGravityBehaviour)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        animator.removeBehavior(radialTouchGravityBehaviour)
        animator.addBehavior(noiseGravityBehaviour)
    }
}
