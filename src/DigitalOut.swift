/**
 The DigitalOut class is used to set a High or Low voltage output to a digital output pin. An initiation is required before using the member functions of this class.

 The driving capability of the digital output pins is not very strong. It is meant to be a **SIGNAL** output. It is not capable of driving a device requires large current.
 
 
 ### BASIC USAGE
 
 After the initiation, the member functions of this class can be used freely. Here's some basic usage of this class.

 ````
 import SwiftIO
 
 func main() {
    // Initiate a DigitalOut to Pin 0
    let pin = DigitalOut(.D0)
 
    // Reverse the output value every 1000 ms
    while true {
        pin.toggle()
        sleep(ms: 1000)
    }
 }
 ````
 Alternatively,
 ````
 import SwiftIO
 
 func main() {
     // Initiate a DigitalOut to the Green LED
     let greenLED = DigitalOut(.GREEN)
 ​
     while true {
       // Toggle the output of the pin every 1000 ms using another member function.
       greenLED.write(true)
       sleep(ms: 1000)
       greenLED.write(false)
       sleep(ms: 1000)
    }
 }
 ````
 */
public class DigitalOut {

    private var obj: DigitalIOObject

    private let id: Id
    private var mode: Mode {
        willSet {
            obj.outputMode = newValue.rawValue
        }
    }

    /**
     The current state of the output value.
     Write to this property would change the output value.
     
     */
    public var value: Bool {
        willSet {
			swiftHal_gpioWrite(&obj, newValue ? 1 : 0)
		}
	}

    private func objectInit() {
        obj.id = id.rawValue
        obj.direction = Direction.output.rawValue
        obj.outputMode = mode.rawValue

        swiftHal_gpioInit(&obj)
		swiftHal_gpioWrite(&obj, value ? 1 : 0)
    }
    
    /**
     An initiation of the class to a specific output pin.
     
     - Parameter id: **REQUIRED** The name of output pin. Reference the Id enumerate.
     - Parameter mode: **OPTIONAL** The output mode of the pin. `.pushPull` for default.
     - Parameter value: **OPTIONAL** The output value after initiation. `false` for default.


     #### Usage Example
     ````
     // The most simple way of initiating a pin D0, with all other parameters set to default.
     let outputPin0 = DigitalOut(.D0)
     ​
     // Initiate the pin D1 with the output mode openDrain.
     let outputPin1 = DigitalOut(.D1, mode: .openDrain)
     ​
     // Initiate the pin D2 with a High voltage output after initiation.
     let outputPin2 = DigitalOut(.D2, value: true)
     
     // Initiate the pin D3 with the openDrain mode and a High voltage output after initiation.
     let outputPin3 = DigitalOut(.D3, mode: .openDrain, value: true)
     ````
     */
    public init(_ id: Id,
                mode: Mode = .pushPull,
                value: Bool = false) {
        self.id = id
        self.mode = mode
        self.value = value
        obj = DigitalIOObject()
        objectInit()
    }

    deinit {
        swiftHal_gpioDeinit(&obj)
    }

    /**
     This function returns the current output mode in a format of DigitalOut.Mode enumerate.

     - Returns: `.pushPull` or `.openDrain` for the current mode.
     
     #### Usage Example
     ````
     let pin = DigitalOut(.D0)
     if pin.getMode() == .pushPull {
        //do something
     }
     ````
     */
    public func getMode() -> Mode {
        return mode
    }

    /**
     Change the output mode.
     
     - Parameter mode : The output mode. `.pushPull` or `.openDrain`
     */
    public func setMode(_ mode: Mode) {
        self.mode = mode
        swiftHal_gpioConfig(&obj)
	}



    /**
     Set the output value of a specific pin.

     - Parameter value : The output value. `true` for high voltage and `false` for low voltage
     */
	public func write(_ value: Bool) {
		self.value = value
	}
    
    /**
     Reverse the current output value of the specific pin.
     
     */
    public func toggle() {
        value = value ? false : true
    }

    /**
     Get the current output value in Boolean format.
     
     - Returns: `true` or `false` of the logic value.
     - Attention:
        The return value of this function **has nothing to do with the actual output** of the pin.
        For example, the pin is set to `true` but it is short to ground. The actual pin voltage would be low. This function will still return `true` despite the actual low output, since this pin is set to HIGH.
     */
    public func getValue() -> Bool {
        return value
    }
    
}


extension DigitalOut {
    
    /**
     The Id enumerate includes available digital pin. They are D0 ~ D45, RED, GREEN, BLUE.
     
     - Returns: `true` or `false` of the logic value.
     - Attention:
        Using digital pin D26 ~ D37 is not recommended, as they are required to be pulled down upon startup of the MCU. After startup they act as normal digital pins.
     */
    public enum Id: UInt8 {
        case D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16,
            D17, D18, D19, D20, D21, D22, D23, D24, D25, D26, D27, D28, D29, D30, D31,
            D32, D33, D34, D35, D36, D37, D38, D39, D40, D41, D42, D43, D44, D45,
            RED, GREEN, BLUE
    }

    /**
        **DO NOT USE**
     */
    public enum Direction: UInt8 {
        case output = 1, input
    }

    /**
     The Mode enumerate includes the available output modes.
     
     */
    public enum Mode: UInt8 {
        case pushPull = 1, openDrain
    }
}


