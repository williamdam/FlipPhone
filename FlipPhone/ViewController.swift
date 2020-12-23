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

    @IBOutlet weak var flipItLabel: UIView!                 // Flip it label
    @IBOutlet weak var gameModeTitle: UILabel!              // Title above slider
    @IBOutlet weak var gameModeSlider: UISegmentedControl!  // Slider of Game Modes
    @IBOutlet weak var guessFlipsTextField: UITextField!    // Text field for guess flips
    @IBOutlet weak var startCountingButton: UIButton!       // Button Start
    @IBOutlet weak var stopCountingButton: UIButton!        // Button Stop
    @IBOutlet weak var greetingLabel: UILabel!              // Label Max Rotation Speed
    @IBOutlet weak var numRotationsLabel: UILabel!          // Label Num Rotations
    
    // Array to hold rotation data
    var rotationData: [Double] = []
    
    var gameMode: Int = 0               // 0 = max flips, 1 = always up, 2 = guess it
    var alwaysUpFlips: Int = 0          // Count number of times always up
    var faceUp: Bool = false            // Did phone land face up
    var motion = CMMotionManager()      // Init motion manager
    var audioPlayer: AVAudioPlayer?     // Init audio player for chime
    
    var sensorMessage = ""              // String holds error message
    var alert = UIAlertController(title: "", message: "", preferredStyle: .alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Done button for number pad
        setupTextFields()
        
        // Dismiss keyboard, tap anywhere
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismissKeyboard))
                view.addGestureRecognizer(tap) // Add gesture recognizer to background view
        
        // Set UILabels to invisible
        flipItLabel.isHidden = true
        hideLabels()
        hideGuessFlipsTextField()
        
        // Display start button
        showStartButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if motion services available, else popup alert.
        if !motion.isDeviceMotionAvailable || !motion.isAccelerometerAvailable || !motion.isGyroAvailable {
            
            // Append message with service(s) unavailable
            if !motion.isDeviceMotionAvailable {
                sensorMessage.append("\n Device Motion ")
            }
            if !motion.isAccelerometerAvailable {
                sensorMessage.append("\n Accelerometer ")
            }
            if !motion.isGyroAvailable {
                sensorMessage.append("\n Gyro ")
            }
            
            // Format alert window
            alert = UIAlertController(title: "Phone Sensors Unavailable", message: sensorMessage, preferredStyle: .alert)
            
            // Okay button to quit
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            // Display alert
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    // Function: hideGuessFlipsTextField()
    // Args: None
    // Returns: Void
    // Description: Void function hides guess field
    func hideGuessFlipsTextField() {
        
        guessFlipsTextField.alpha = 0.0
        
    }
    
    // Function: showGuessFlipsTextField()
    // Args: None
    // Returns: Void
    // Description: Void function shows guess field
    func showGuessFlipsTextField() {
        
        guessFlipsTextField.alpha = 1.0
        
    }
    
    // Function: showLabels()
    // Args: None
    // Returns: Void
    // Description: Void function shows labels
    func showLabels() {
        
        greetingLabel.alpha = 1.0
        numRotationsLabel.alpha = 1.0
        
    }
    
    // Function: hideLabels()
    // Args: None
    // Returns: Void
    // Description: Void function hides labels
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
    
    // Function: hideForFlip()
    // Args: None
    // Returns: Void
    // Description: Hide before flip
    func hideForFlip() {
        
        gameModeTitle.isHidden = true       // Hide game mode title
        gameModeSlider.isHidden = true      // Hide game mode slider
        startCountingButton.isHidden = true // Hide start button
        
        // Hide guess flips
        if gameMode == 2 {
            guessFlipsTextField.isHidden = true
        }
        
        flipItLabel.isHidden = false        // Show flip it label
        
    }
    
    // Function: showAfterFlip()
    // Args: None
    // Returns: Void
    // Description: Show after flip
    func showAfterFlip() {
        
        gameModeTitle.isHidden = false      // Show game mode title
        gameModeSlider.isHidden = false     // Show game mode slider
        startCountingButton.isHidden = false// Show start button
        
        // Show guess flips
        if gameMode == 2 {
            guessFlipsTextField.isHidden = false
        }
        
        flipItLabel.isHidden = true         // Hide flip it label
        
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
        if abs(radians) > (halfwayPoint - 0.49) && abs(radians) <= halfwayPoint {
            
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
        if abs(radians) >= finishLine && abs(radians) < (finishLine + 0.49) {
            
            return true
            
        }
        
        return false
        
    }
    
    // Function: MyGyro()
    // Args: None
    // Returns: Void
    // Description: Gets gyroscope data from device
    func MyGyro() {
        
        // Flag to track min speed satisfied
        var minSpeedReached:Bool = false
        
        // Check for change every 0.01  sec
        motion.gyroUpdateInterval = 0.01
        
        // Start gyroscope
        motion.startGyroUpdates(to: OperationQueue.current!) { (data, error) in
            
            if let trueData = data {
                
                // Print to console
                print("Rotation: \(trueData)")
                print("Rotation rate y: \(trueData.rotationRate.y)")
                
                // Set min speed flag true if min speed reached
                if minSpeedReached == false && trueData.rotationRate.y > 7 {
                    
                    minSpeedReached = true
                    
                }
                
                if self.gameMode == 1 && minSpeedReached == true && abs(trueData.rotationRate.y) < 0.1 {
                    
                    // Show results
                    self.showResults()
                                        
                    minSpeedReached = false
                    
                }
                
                // Stop count and display results when rotation stops
                else if self.gameMode != 1 && minSpeedReached == true && abs(trueData.rotationRate.y) < 0.1 {
                    
                    // Stop all motion data
                    self.stopCounting()
                    
                    // Print array
                    print(self.rotationData)
                    
                    // Show results
                    self.showResults()
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
                print("Acceleration: \(accelData)")    // Access acceleration with .acceleration
                
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
        
        showAfterFlip()
        
        // Play chime
        // self.playSound(sound: "chime", type: "mp3")
        
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
    
    // Function: deviceIsUp()
    // Args: Double Array stores attitude data
    // Returns: Bool
    // Description: Takes array arg of attitude data on y-axis and returns
    // bool True if last array element has position within finish line range.
    func deviceIsUp(_ rotationArray: [Double]) -> Bool {
        
        var isUp: Bool = true              // Bool true if device face up
        var passedCheckpoint: Bool = false  // Bool true if passed checkpoint
        
        // Iterate array of rotatation data
        for deviceAttitude in 0...rotationArray.count - 1 {
            
            // If in finish line and passed checkpoint, device is up
            if inFinishLineRange(rotationArray[deviceAttitude]) {
                if passedCheckpoint == true {
                    isUp = true
                    passedCheckpoint = false
                }
            }
            
            // If in checkpoint and passed finish line, device is down
            else if inCheckPointRange(rotationArray[deviceAttitude]) {
                if isUp == true {
                    isUp = false
                    passedCheckpoint = true
                }
            }
        }
        
        return isUp     // Return var bool true if device is up
    }
    
    func gameMode0() {
        
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
        
        // Amend string with singular or plural
        var changeToPlural = "s"
        if numRotations == 1 {
            changeToPlural = ""
        }
        
        // Set num rotations label to total rotations
        numRotationsLabel.text = String("\(numRotations) flip\(changeToPlural)")
        
        // Display labels
        showLabels()
        
        self.playSound(sound: "chime", type: "mp3")
        
        // Clear rotation data stored in array
        rotationData.removeAll()
        
    }
    
    func gameMode1() {
                
        print(self.rotationData)
        
        if deviceIsUp(rotationData) {
            alwaysUpFlips += 1
            greetingLabel.text = "Nice! Keep going."
            self.playSound(sound: "chime", type: "mp3")
            
        }
        else {
            stopCounting()
            greetingLabel.text = "Aw, you didn't land it."
            self.playSound(sound: "alert", type: "mp3")
            showStartButton()
            rotationData.removeAll()
        }
        
        // Amend string with singular or plural
        var changeToPlural = "s"
        if alwaysUpFlips == 1 {
            changeToPlural = ""
        }
        numRotationsLabel.text = String("\(alwaysUpFlips) flip\(changeToPlural)")
        
        showLabels()
    }
    
    func gameMode2() {
        
        // Process number of rotations and save to var
        let numRotations = getNumRotations(rotationData)
        print("Processed Rotations: \(numRotations)")
        
        let originalGuess = Int(guessFlipsTextField.text ?? "0")
        
        if numRotations == originalGuess {
            greetingLabel.text = "YOU WIN!"
            self.playSound(sound: "chime", type: "mp3")
        }
        else {
            greetingLabel.text = "YOU LOSE."
            self.playSound(sound: "alert", type: "mp3")
        }
        
        // Amend string with singular or plural
        var changeToPlural = "s"
        if numRotations == 1 {
            changeToPlural = ""
        }
        
        // Set num rotations label to total rotations
        numRotationsLabel.text = String("\(numRotations) flip\(changeToPlural)")
        
        // Display labels
        showLabels()
        
        // Clear rotation data stored in array
        rotationData.removeAll()
        
    }
    
    
    // Function: showResults()
    // Args: None
    // Returns: Void
    // Description: Calls getNumRotations() on data array to get num rotations.
    // Switch statement generates greeting based on num rotations.  Display
    // text label with results.  Clear array.
    func showResults() {
        
        if gameMode == 0 {
            gameMode0()
        }
        else if gameMode == 1 {
            gameMode1()
        }
        else {
            gameMode2()
        }
        
    }
    
    // Action: User selects game mode
    // Description: Switch between game modes. Action picks up on change.
    @IBAction func gameModeOptionSlider(_ sender: UISegmentedControl) {
        
        stopCounting()
        rotationData.removeAll()
        alwaysUpFlips = 0
        print("Cleared Rotation Data and Always Up Flip Counter")
        
        hideLabels()
        showStartButton()
        
        let gameMode = sender.selectedSegmentIndex
        
        switch gameMode {
        case 0:
            hideGuessFlipsTextField()
            self.gameMode = 0
        case 1:
            hideGuessFlipsTextField()
            self.gameMode = 1
        case 2:
            showGuessFlipsTextField()
            self.gameMode = 2
        default:
            hideGuessFlipsTextField()
            self.gameMode = 0
        }
        
    }
    
    // Action: User presses start button
    // Description: Set labels to invisible.  Call all motion functions.
    @IBAction func startCountingButtonPressed(_ sender: UIButton) {
        
        // Hide everything when flipping
        hideForFlip()
        
        alwaysUpFlips = 0
                
        // Start all motion devices
        if !motion.isDeviceMotionActive {
            MyAttitude()
            MyGyro()
            MyAccel()
        }
        
        // Hide labels
        hideLabels()
        
        
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
        
        // Show results
        showResults()
        
    }
    
    @objc func tapToDismissKeyboard() {
        
        // Dismiss keyboard
        guessFlipsTextField.resignFirstResponder()
        
    }
    
    func setupTextFields() {
            let toolbar = UIToolbar()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done,
                                             target: self, action: #selector(doneButtonTapped))
            
            toolbar.setItems([flexSpace, doneButton], animated: true)
            toolbar.sizeToFit()
            
            guessFlipsTextField.inputAccessoryView = toolbar
        }
        
        @objc func doneButtonTapped() {
            view.endEditing(true)
        }
}


