import Glibc

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

/**
 * To remember myself: Why here is struct, and not class
 * - no inheritance needed (structs can not inherit)
 * - only one instance (so no need of references)
 */
struct PIDController {
    var kp: Float = 0 // Error coefficient
    var ki: Float = 0 // Integration coefficient
    var kd: Float = 0 // Derivation coefficient
    var dt: Float = 0 // Interval of time between two updates

    var target: Float = 0

    var sumError: Float = 0
    var lastError: Float = 0

    init(kp: Float, ki: Float, kd: Float, dt: Float = 1) {
        self.kp = kp
        self.ki = ki
        self.kd = kd
        self.dt = dt
    }

    mutating func setTarget(_ target: Float) {
        self.target = target
    }

    mutating func update(_ target: Float) -> Float {
        let error = self.target - target

        // Integration input
        self.sumError += error * self.dt

        // Derivation input
        let derivativeError = (error - self.lastError) / self.dt

        self.lastError = error

        return self.kp * error + self.ki * self.sumError + self.kd * derivativeError
    }
}

struct Engine {
    var targetVelocityX: Float = 0
    var targetVelocityY: Float = 0

    var controllerX: PIDController
    var controllerY: PIDController

    init () {
        self.controllerX = PIDController(kp: 0.2, ki: 0.0003, kd: 0.3)
        self.controllerY = PIDController(kp: 0.2, ki: 0.0003, kd: 0.3)
    }

    mutating func setTarget(_ velocityX: Float, _ velocityY: Float) {
        self.controllerX.setTarget(velocityX)
        self.controllerY.setTarget(velocityY)
    }

    mutating func getOutput(_ velocityX: Float, _ velocityY: Float) -> (Float, Float) {
        let velocityXUpdate = self.controllerX.update(velocityX)
        let velocityYUpdate = self.controllerY.update(velocityY)

        let rotate = -Float(atan(velocityXUpdate / abs(velocityYUpdate)) * (180 / .pi))
        let power = Float(sqrt(pow(velocityXUpdate, 2) + pow(velocityYUpdate, 2)))

        return (power, rotate)
    }
}

var landX = 0
var landY = 0
// Temporary params to define flat landing zone
var prevLandX = 0
var prevLandY = 0
// Coordinates of the center of flat landing zone
var targetX = 0
var targetY = 0

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

let surfaceN = Int(readLine()!)! // the number of points used to draw the surface of Mars.
if surfaceN > 0 {
    for i in 0...(surfaceN-1) {
        let inputs = (readLine()!).characters.split{$0 == " "}.map(String.init)
        landX = Int(inputs[0])! // X coordinate of a surface point. (0 to 6999)
        landY = Int(inputs[1])! // Y coordinate of a surface point. By linking all the points together in a sequential fashion, you form the surface of Mars.

        if prevLandY == landY {
            targetX = prevLandX + (landX - prevLandX) / 2
            targetY = landY
        }

        prevLandX = landX
        prevLandY = landY
    }
}

print(targetX, targetY, to: &errStream)

var engine = Engine()

// game loop
while true {
    let inputs = (readLine()!).characters.split{$0 == " "}.map(String.init)
    let X = Int(inputs[0])!
    let Y = Int(inputs[1])!
    let hSpeed = Int(inputs[2])! // the horizontal speed (in m/s), can be negative.
    let vSpeed = Int(inputs[3])! // the vertical speed (in m/s), can be negative.
    let fuel = Int(inputs[4])! // the quantity of remaining fuel in liters.
    // let rotate = Int(inputs[5])! // the rotation angle in degrees (-90 to 90).
    // let power = Int(inputs[6])! // the thrust power (0 to 4).

    // Write an action using print("message...")
    // To debug: print("Debug messages...", to: &errStream)

    let direction = Float(targetX > X ? 1 : -1)
    let distanceX = abs(targetX - X)
    let distanceY = abs(targetY - Y)

    var targetVX = 0
    var targetVY = 0

    if distanceX > 1200 {
        targetVX = 60
    } else if distanceX < 700 {
        targetVX = 10
    }

    if distanceY > 1200 {
        targetVY = -5
    } else if distanceY < 500 {
        targetVY = 20
    }

    engine.setTarget(direction * Float(targetVX), Float(targetVY))

    var (_power, rotate) = engine.getOutput(Float(hSpeed), Float(vSpeed))
    let power = _power > 4 ? 4 : _power < 0 ? 0 : Int(round(_power))

    if Y - targetY < 100 {
        rotate = 0
    }

    print("Distance X", distanceX, to: &errStream)
    print("Distance Y", distanceY, to: &errStream)
    print("Speed X", hSpeed, to: &errStream)
    print("Speed Y", vSpeed, to: &errStream)
    print("Rotate", rotate, to: &errStream)
    print("Power", _power, power, to: &errStream)
    print("Direction", direction, to: &errStream)

    // rotate power. rotate is the desired rotation angle. power is the desired thrust power.
    print(String(Int(round(rotate))) + " " + String(power))
}
