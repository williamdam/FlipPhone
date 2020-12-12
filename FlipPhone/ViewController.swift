//
//  ViewController.swift
//  FlipPhone
//
//  Created by william dam on 12/7/20.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var startCountingButton: UIButton!       // Button Start
    @IBOutlet weak var stopCountingButton: UIButton!        // Button Stop
    @IBOutlet weak var maxRotationSpeedLabel: UILabel!      // Label Max Rotation Speed
    @IBOutlet weak var numRotationsLabel: UILabel!          // Label Num Rotations
    
    var motion = CMMotionManager()      // Init motion manager
    var maxSpeed:Double = 0.0           // Max rotational speed
    var maxG:Double = 0.0               // Max G's
    var finishLine:Bool = true          // Flag for finish line
    var checkPoint:Bool = false         // Flag for check point
    var numRotations:Int = 0            // Number of rotations
    var audioPlayer: AVAudioPlayer?     // Init audio player for chime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UILabels to invisible
        maxRotationSpeedLabel.alpha = 0.0
        numRotationsLabel.alpha = 0.0
    }
    
    // Play sound
    func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            }
            catch {
                print("Could not play sound file.")
            }
        }
    }
    
    // Set rotation passed halfway point at 3 radians (PENDING: Increase precision with pi)
    func setCheckPoint(_ rotationAngle:Double) {
        
        // Checkpoint located between 2.8 and 3.2 radians.
        // If finishLine flagged, flag checkPoint, and unflag finishLine
        if abs(rotationAngle) > 2.8 && abs(rotationAngle) < 3.2 && self.finishLine == true {
            
            self.checkPoint = true
            self.finishLine = false
        }
        

    }
    
    // Set rotation passed finish line at 0 radians (PENDING: Increase precision with pi)
    func setFinishLine(_ rotationAngle:Double) {
        
        // Finish line located at 0 radians, threshold +/- 0.8
        // If checkPoint flagged, flag finishLine, and unflag checkPoint
        if abs(rotationAngle) > 0 && abs(rotationAngle) < 0.8 && self.checkPoint == true {
            
            self.finishLine = true
            self.checkPoint = false
            
            // Increment counter
            self.numRotations += 1
        }
        
    }
    
    // Function: MyGyro()
    // Args: None
    // Returns: Void
    // Description: Gets gyroscope data from device and sets maxSpeed with rad/sec
    func MyGyro() {
        
        // Check for change every 0.01  sec
        motion.gyroUpdateInterval = 0.01
        
        // Start gyroscope
        motion.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            
            if let trueData = data {
                
                // Print to console
                print(trueData)
                print("Rotation rate y: \(trueData.rotationRate.y)")
                
                // Update maxSpeed with rotationRate
                if abs(trueData.rotationRate.y) > self.maxSpeed {
                    
                    self.maxSpeed = abs(trueData.rotationRate.y)    // (PENDING: Convert to rps or rpm)
                }
                
            }
        }
    }
    
    // Function: MyAccel()
    // Args: None
    // Returns: Void
    // Description: Gets accelerometer data from device and sets maxG with number of G's
    func MyAccel() {
        
        // Check for change every 0.01 sec
        motion.accelerometerUpdateInterval = 0.01
        
        // Start accelerometer
        motion.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let accelData = data {
                
                // Print to console
                print("Accel: \(accelData)")
                
                // Update maxG with number of G's
                if accelData.acceleration.z > self.maxG {
                    
                    self.maxG = accelData.acceleration.z        // (PENDING: Check data for +/- G's)
                }
                
            }
            
            // Automatically stop motion data on G sensor shock
            // PENDING: Check instantaneous G's on all axes, instead of max.
            // PENDING: Require minimum rotation speed flag
            if self.maxG > 1.3 {
                
                // Call stop count function, stop all sensors
                self.stopCounting()
                
                // Play chime
                self.playSound(sound: "chime", type: "mp3")
                
                // Reinitialize maxG
                self.maxG = 0.0
            }
            
            
            
        }
    }
    
    // Function: MyAttitude()
    // Args: None
    // Returns: Void
    // Description: Gets attitude of device around the Y-axis, then calls
    // functions, setCheckPoint() and setFinishLine()
    func MyAttitude() {
        
        // Check for change every 0.01 sec
        motion.deviceMotionUpdateInterval = 0.01
        
        // Start getting device attitude roll (Y-axis)
        motion.startDeviceMotionUpdates(to: OperationQueue.current!) { (data, error) in
            if let attitudeData = data {
                
                // Print to console
                print("Attitude: \(attitudeData.attitude)")
                
                // Call helper functions
                self.setCheckPoint(attitudeData.attitude.roll)
                self.setFinishLine(attitudeData.attitude.roll)
                
            }
            
        }
    }

    func stopCounting() {
        
        // Stop motion updates
        motion.stopDeviceMotionUpdates()
        motion.stopGyroUpdates()
        motion.stopAccelerometerUpdates()
        
        // Set speed label to max rad/sec
        maxRotationSpeedLabel.text = String(format: "%.2f rad/sec", self.maxSpeed)
        
        // Set num rotations label to total rotations
        numRotationsLabel.text = String("\(numRotations) times")
        
        // Make both labels visible
        maxRotationSpeedLabel.alpha = 1.0
        numRotationsLabel.alpha = 1.0
        
        // Reset vars
        self.maxSpeed = 0.0
        self.numRotations = 0
        
    }
    
    // Action: User presses start button
    // Description: Set labels to invisible.  Call all motion functions.
    @IBAction func startCountingButtonPressed(_ sender: UIButton) {
        
        // Make labels invisible
        maxRotationSpeedLabel.alpha = 0.0
        numRotationsLabel.alpha = 0.0
        
        MyAttitude()
        MyGyro()
        MyAccel()
        
    }
    
    // Action: User presses stop button
    // Description: Stop all motion updates.
    @IBAction func stopCountingButtonPressed(_ sender: UIButton) {
        
        // Stop motion updates
        motion.stopDeviceMotionUpdates()
        motion.stopGyroUpdates()
        motion.stopAccelerometerUpdates()
        
        // Set speed label to max rad/sec
        maxRotationSpeedLabel.text = String(format: "%.2f rad/sec", self.maxSpeed)
        
        // Set num rotations label to total rotations
        numRotationsLabel.text = String("\(numRotations) times")
        
        // Make both labels visible
        maxRotationSpeedLabel.alpha = 1.0
        numRotationsLabel.alpha = 1.0
        
        // Reset vars
        self.maxSpeed = 0.0
        self.numRotations = 0
    }
    
    
}

