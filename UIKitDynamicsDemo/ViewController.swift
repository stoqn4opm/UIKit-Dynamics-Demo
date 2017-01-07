//
//  ViewController.swift
//  UIKitDynamicsDemo
//
//  Created by Stoyan Stoyanov on 1/6/17.
//  Copyright © 2017 Stoyan Stoyanov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    
    var circles:[Circle] = []
    var circlesBehaviour: [UIDynamicItemBehavior] = []
    
    var noiseGravityBehaviour: UIFieldBehavior!
    var radialTouchGravityBehaviour: UIFieldBehavior!
    
    func generateCircles() {
        let circlesCount = 15
        
        for i in 0...circlesCount {
            let circle = Circle.randomCircle
            self.view.addSubview(circle)
            circle.frame.origin = self.view.center
            circles.append(circle)
            
            let circleBehaviour = UIDynamicItemBehavior(items: [circle])
            circleBehaviour.elasticity = 0.1
            circleBehaviour.friction = 0
            circleBehaviour.resistance = 0
            circleBehaviour.density = ( 100 - circle.frame.width / 50) * 8
            animator.addBehavior(circleBehaviour)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: view)

        animator.setValue(true, forKey: "debugEnabled")
//        animator.setValue(0.05, forKey: "debugAnimationSpeed")
        
        self.generateCircles()
        self.setupBehaviors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            print("slow")
//            self.noiseGravityBehaviour.animationSpeed = 1
//            self.noiseGravityBehaviour.strength = 100
        })
        
    }
    
    
    func setupBehaviors() {
        
        collision = UICollisionBehavior(items: circles)
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        radialTouchGravityBehaviour.position = (touches.first?.location(in: self.view))!
        animator.removeBehavior(noiseGravityBehaviour)
        animator.addBehavior(radialTouchGravityBehaviour)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        radialTouchGravityBehaviour.position = (touches.first?.location(in: self.view))!
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

