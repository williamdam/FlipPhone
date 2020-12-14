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
    @IBOutlet weak var greetingLabel: UILabel!              // Label Max Rotation Speed
    @IBOutlet weak var numRotationsLabel: UILabel!          // Label Num Rotations
    
    // Array to hold rotation data
    var rotationData: [Double] = []
    
    var motion = CMMotionManager()      // Init motion manager
    var maxSpeed:Double = 0.0           // Max rotational speed
    var audioPlayer: AVAudioPlayer?     // Init audio player for chime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set UILabels to invisible
        hideLabels()
        
        // Display start button
        showStartButton()
    }
    
    // Function: hideLabels()
    // Args: None
    // Returns: Void
    // Description: Void function sets labels to transparent
    func hideLabels() {
        greetingLabel.alpha = 0.0
        numRotationsLabel.alpha = 0.0
    }
    
    // Function: showStartButton()
    // Args: None
    // Returns: Void
    // Description: Shows start button and hides stop button
    func showStartButton() {
        startCountingButton.alpha = 1.0
        stopCountingButton.alpha = 0.0
    }
    
    // Function: showStopButton()
    // Args: None
    // Returns: Void
    // Description: Shows stop button and hides start button
    func showStopButton() {
        startCountingButton.alpha = 0.0
        stopCountingButton.alpha = 1.0
    }
    
    // Function: showLabels()
    // Args: None
    // Returns: Void
    // Description: Void function sets labels to full alpha
    func showLabels() {
        greetingLabel.alpha = 1.0
        numRotationsLabel.alpha = 1.0
    }
    
    // Function: playSound()
    // Args: String filename, String file extension
    // Returns: Void
    // Description: Void function plays soundfile passed in args.
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
    
    // Function: inCheckPointRange()
    // Args: Double y-axis orientation in radians.
    // Returns: Bool.  True if within halfway point range.
    // Description: Bool function takes device orientation on y-axis and returns
    // true if within range of halfway point at pi radians.
    func inCheckPointRange(_ radians:Double) -> Bool {
        
        let halfwayPoint = 3.14     // pi rad = 180 degrees
        
        // Checkpoint located at pi radians, +/- 0.2 rad
        if abs(radians) > (halfwayPoint - 0.2) && abs(radians) < (halfwayPoint + 0.2) {
            
            return true
            
        }
        
        return false
        
    }
    
    // Function: inFinishLineRange()
    // Args: Double y-axis orientation in radians.
    // Returns: Bool.  True if within origin range.
    // Description: Bool function takes device orientation on y-axis and returns
    // true if within range of origin at 0.0 radians.
    func inFinishLineRange(_ radians:Double) -> Bool {
        
        let finishLine = 0.0     // 0.0 radians
        
        // Checkpoint located at pi radians, +/- 0.2 rad
        if abs(radians) > (finishLine - 0.2) && abs(radians) < (finishLine + 0.2) {
            
            return true
            
        }
        
        return false
        
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
                print("Accel: \(accelData)")    // Access acceleration with .acceleration
                
            }
            
            // Automatically stop motion data on G sensor shock
            // PENDING: Check instantaneous G's on all axes, instead of max.
            // PENDING: Require minimum rotation speed flag

            
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
                /*self.setCheckPoint(attitudeData.attitude.roll)
                self.setFinishLine(attitudeData.attitude.roll)*/
                
                // Add roll position to array
                self.rotationData.append(attitudeData.attitude.roll)
            }
            
        }
    }

    // Function: stopCounting()
    // Args: None
    // Returns: Void
    // Description: Calls stop on all motion updates being used.
    func stopCounting() {
        
        // Stop motion updates
        if motion.isDeviceMotionActive {
            motion.stopDeviceMotionUpdates()
            motion.stopGyroUpdates()
            motion.stopAccelerometerUpdates()
        }
        
        
        // Play chime
        self.playSound(sound: "chime", type: "mp3")
        
    }
    
    // Function: getNumRotations()
    // Args: Double Array stores attitude data
    // Returns: Int
    // Description: Takes array arg of attitude data on y-axis and returns number
    // of rotations.
    func getNumRotations(_ rotationArray: [Double]) -> Int {
        
        var passedCheckPoint:Bool = false           // Checkpoint flag
        let lastElement = rotationArray.count - 1   // Last element in array
        var numRotations:Int = 0                    // Counter for number of rotations
        
        // Analyze all elements in array
        if rotationArray.count != 0 {
            for i in 0...lastElement {
                
                // Device attitude on y-axis in radians
                let position = rotationArray[i]
                
                // Within finish line range and already passed checkpoint
                if inFinishLineRange(position) && passedCheckPoint == true {
                    
                    numRotations += 1           // Increment rotation counter
                    passedCheckPoint = false    // Reset checkpoint flag

                }
                
                // Within checkpoint range for first time
                else if inCheckPointRange(position) && passedCheckPoint == false {
                    
                    passedCheckPoint = true     // Set checkpoint flag
                    
                }
            }
        }
    
        return numRotations
                
    }
    
    // Action: User presses start button
    // Description: Set labels to invisible.  Call all motion functions.
    @IBAction func startCountingButtonPressed(_ sender: UIButton) {
        
        // Display stop button
        showStopButton()
        
        // Make labels invisible
        hideLabels()
        
        // Start all motion devices
        if !motion.isDeviceMotionActive {
            MyAttitude()
            MyGyro()
            MyAccel()
        }
        
        
    }
    
    // Action: User presses stop button
    // Description: Stop all motion updates.
    @IBAction func stopCountingButtonPressed(_ sender: UIButton) {
        
        // Display start button
        showStartButton()
        
        // Stop all motion data
        stopCounting()
        
        // Print array
        print(rotationData)
        
        // Process number of rotations and save to var
        let numRotations = getNumRotations(rotationData)
        print("Processed Rotations: \(numRotations)")
        
        // Set greeting based on numRotations
        var greeting = "Meh."
        
        switch numRotations {
        case 0:
            greeting = "You didn't even flip it!"
        case 1..<3:
            greeting = "Meh."
        case 3..<5:
            greeting = "Pretty good!"
        default:
            greeting = "Wow!"
            
        }
        
        // Set greeting label
        greetingLabel.text = greeting
        
        // Set num rotations label to total rotations
        numRotationsLabel.text = String("\(numRotations) rotations")
        
        // Display labels
        showLabels()
        
        // Clear rotation data stored in array
        rotationData.removeAll()
    }
    
    
}

