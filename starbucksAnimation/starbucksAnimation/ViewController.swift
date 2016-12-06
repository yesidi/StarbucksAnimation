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
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var lid: UIImageView!
    @IBOutlet weak var cup: UIImageView!
    let starNum = 10
    var animator:UIDynamicAnimator?
    lazy var motionManager = CMMotionManager()
    var timer:Timer?
    var dynamicItems = [UIView]()
    var gravity = UIGravityBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.restart(nil)
    }
    
    func stopAnimation() {
        timer?.invalidate()
        self.animator?.removeAllBehaviors()
        for item in dynamicItems {
            item.removeFromSuperview()
        }
        dynamicItems.removeAll()
        motionManager.stopDeviceMotionUpdates()
    }
    
    @IBAction func restart(_ sender: Any?) {
        if #available(iOS 10.0, *) {
            self.stopAnimation()
            self.lid.layer.anchorPoint = CGPoint(x: 0, y: 1)
            self.lid.layer.position = CGPoint(x: self.lid.frame.origin.x - 61, y: self.lid.frame.origin.y + 66)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.lid.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI_4))
            })
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block:{ timer in
                self.createAnimation()
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func createAnimation() {
        restartBtn.isHidden = true
        guard dynamicItems.count < starNum else {
            restartBtn.isHidden = false
            timer?.invalidate()
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, err) in
                let rotation = atan2(motion!.gravity.x, motion!.gravity.y) - (M_PI/2)
                guard abs(rotation) > 0.7 else { return }
                self.gravity.setAngle(CGFloat(rotation), magnitude: 0.1)
            }
            UIView.animate(withDuration: 0.5, animations: { 
                self.lid.transform = CGAffineTransform.identity
            }, completion: { (finished) in
                self.lid.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.lid.layer.position = CGPoint(x: 160, y: 278)
            })
            return
        }
        
        dynamicItems.append(createStar())
        animator = UIDynamicAnimator(referenceView: self.cup)
        gravity = UIGravityBehavior(items: dynamicItems)
        gravity.magnitude = 0.8
        
        let collisionTop = UICollisionBehavior(items: dynamicItems)
        let collisionLeft = UICollisionBehavior(items: dynamicItems)
        let collisionRight = UICollisionBehavior(items: dynamicItems)
        let collisionBottom = UICollisionBehavior(items: dynamicItems)
        
        let pLeftTop = CGPoint(x: 6, y: 0)
        let pRightTop = CGPoint(x: 116, y: 0)
        
        let pLeftBottom = CGPoint(x: 22, y: 163)
        let pRightBottom = CGPoint(x: 100, y: 163)
        
        collisionTop.addBoundary(withIdentifier: "boundaryTop" as NSCopying, from: pLeftTop, to: pRightTop)
        collisionLeft.addBoundary(withIdentifier: "boundaryLeft" as NSCopying, from: pLeftTop, to: pLeftBottom)
        collisionRight.addBoundary(withIdentifier: "boundaryRight" as NSCopying, from: pRightBottom, to: pRightTop)
        collisionBottom.addBoundary(withIdentifier: "boundaryBottom" as NSCopying, from: pLeftBottom, to: pRightBottom)
        
        let behavior = UIDynamicItemBehavior(items: dynamicItems)
        behavior.elasticity = 0.4
        
        animator?.addBehavior(gravity)
        animator?.addBehavior(collisionTop)
        animator?.addBehavior(collisionLeft)
        animator?.addBehavior(collisionRight)
        animator?.addBehavior(collisionBottom)
        animator?.addBehavior(behavior)
    }

    func createStar() -> UIView {
        let star = Star(image: UIImage(named:"MSRInfo_Main_star_01")!)
        let x = CGFloat(arc4random_uniform(75) + 7)
        star.frame = CGRect(x: x, y: 0, width: 24, height: 24)
        self.cup.addSubview(star)
        return star
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

