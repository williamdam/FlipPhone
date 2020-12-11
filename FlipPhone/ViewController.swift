//
//  ViewController.swift
//  FlipPhone
//
//  Created by william dam on 12/7/20.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var startCountingButton: UIButton!
    @IBOutlet weak var stopCountingButton: UIButton!
    @IBOutlet weak var maxRotationSpeed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    var motion = CMMotionManager()

    var maxSpeed = 0.0
    var maxG = 0.0
    
    // Gets rotational velocity in Rad/Sec
    func MyGyro() {
        motion.gyroUpdateInterval = 0.05    // Check for change every .5  sec
        motion.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            if let trueData = data {
                print(trueData)
                print("Y: \(trueData.rotationRate.y)")
                if abs(trueData.rotationRate.y) > self.maxSpeed {
                    self.maxSpeed = abs(trueData.rotationRate.y)
                }
            }
        }
    }
    
    // Gets force in G's per axis.  Device at rest should show ~1 G
    func MyAccel() {
        motion.accelerometerUpdateInterval = 0.05
        motion.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let accelData = data {
                print("Accel: \(accelData)")
                
            }
        }
    }
    
    func MyAttitude() {
        motion.deviceMotionUpdateInterval = 0.05
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) { (data, error) in
            if let attitudeData = data {
                print("Attitude: \(attitudeData.attitude)")
            }
        }
    }

    @IBAction func startCountingButtonPressed(_ sender: UIButton) {
        
        //MyAttitude()
        //MyGyro()
        MyAccel()
        
    }
    @IBAction func stopCountingButtonPressed(_ sender: UIButton) {
        
        motion.stopDeviceMotionUpdates()
        motion.stopGyroUpdates()
        motion.stopAccelerometerUpdates()
        maxRotationSpeed.text = String(maxSpeed)
        self.maxSpeed = 0.0
    }
    
    
}

