//
//  ViewController.swift
//  starbucksAnimation
//
//  Created by iOSDev on 2016/12/5.
//  Copyright © 2016年 iOSDev. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    @IBOutlet weak var lid: UIImageView!
    @IBOutlet weak var cup: UIImageView!
    let starNum = 5
    var animator:UIDynamicAnimator!
    lazy var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let dynamicItems = createStars()
        self.animator = UIDynamicAnimator(referenceView: self.cup)
        
        let gravity = UIGravityBehavior(items: dynamicItems)
        
        let collisionTop = UICollisionBehavior(items: dynamicItems)
        let collisionLeft = UICollisionBehavior(items: dynamicItems)
        let collisionRight = UICollisionBehavior(items: dynamicItems)
        let collisionBottom = UICollisionBehavior(items: dynamicItems)
        
        let pLeftTop = CGPoint(x: 6, y: 0)
        let pRightTop = CGPoint(x: 116, y: 0)
        
        let pLeftBottom = CGPoint(x: 22, y: 165)
        let pRightBottom = CGPoint(x: 100, y: 165)
        
        collisionTop.addBoundary(withIdentifier: "boundaryTop" as NSCopying, from: pLeftTop, to: pRightTop)
        collisionLeft.addBoundary(withIdentifier: "boundaryLeft" as NSCopying, from: pLeftTop, to: pLeftBottom)
        collisionRight.addBoundary(withIdentifier: "boundaryRight" as NSCopying, from: pRightBottom, to: pRightTop)
        collisionBottom.addBoundary(withIdentifier: "boundaryBottom" as NSCopying, from: pLeftBottom, to: pRightBottom)
        
        let behavior = UIDynamicItemBehavior(items: dynamicItems)
        behavior.elasticity = 0.3
        
        self.animator.addBehavior(gravity)
        self.animator.addBehavior(collisionTop)
        self.animator.addBehavior(collisionLeft)
        self.animator.addBehavior(collisionRight)
        self.animator.addBehavior(collisionBottom)
        self.animator.addBehavior(behavior)
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, err) in
            let rotation = atan2(motion!.gravity.x, motion!.gravity.y) - (M_PI/2)
            guard abs(rotation) > 0.8 else { return }
                        gravity.setAngle(CGFloat(rotation), magnitude: 0.1)
        }
    }

    func createStars() -> [UIView] {
        var animationObjects = [UIView]()
        for _ in 0..<starNum {
            let star = Star(image: UIImage(named:"MSRInfo_Main_star_01")!)
            let x = CGFloat(arc4random_uniform(30) + 10)
            star.frame = CGRect(x: x, y: 0, width: 24, height: 24)
            self.cup.addSubview(star)
            animationObjects.append(star)
        }
        return animationObjects
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class Star: UIImageView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

