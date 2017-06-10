import Glibc

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

let inputs = (readLine()!).characters.split {$0 == " "}.map(String.init)
let nbFloors = Int(inputs[0])! // number of floors
let width = Int(inputs[1])! // width of the area
let nbRounds = Int(inputs[2])! // maximum number of rounds
let exitFloor = Int(inputs[3])! // floor on which the exit is found
let exitPos = Int(inputs[4])! // position of the exit on its floor
let nbTotalClones = Int(inputs[5])! // number of generated clones
let nbAdditionalElevators = Int(inputs[6])! // ignore (always zero)
let nbElevators = Int(inputs[7])! // number of elevators

var elevators = [Int: Int]()

if nbElevators > 0 {
    for i in 0...(nbElevators-1) {
        let inputs = (readLine()!).characters.split {$0 == " "}.map(String.init)
        let elevatorFloor = Int(inputs[0])! // floor on which this elevator is found
        let elevatorPos = Int(inputs[1])! // position of the elevator on its floor

        elevators[elevatorFloor] = elevatorPos
    }
}

// game loop
while true {
    let inputs = (readLine()!).characters.split {$0 == " "}.map(String.init)
    let cloneFloor = Int(inputs[0])! // floor of the leading clone
    let clonePos = Int(inputs[1])! // position of the leading clone on its floor
    let direction = inputs[2] // direction of the leading clone: LEFT or RIGHT
    var result = "WAIT"

    // Write an action using print("message...")
    // To debug: print("Debug messages...", to: &errStream)

    print(direction, to: &errStream)
    print(exitPos, clonePos, to: &errStream)
    print(cloneFloor, exitFloor, to: &errStream)

    if cloneFloor < 0 || cloneFloor == exitFloor {
        let direction2Exit = exitPos - clonePos > 0 ? "RIGHT" : "LEFT"

        result = direction2Exit != direction ? "BLOCK" : "WAIT"
    } else {
        let elevatorPos = elevators[cloneFloor]!
        print(elevatorPos, cloneFloor, to: &errStream)
        let direction2Elevator = elevatorPos - clonePos > 0 ? "RIGHT" : "LEFT"

        if elevatorPos - clonePos == 0 {
            result = "WAIT"
        } else {
            result = direction2Elevator != direction ? "BLOCK" : "WAIT"
        }
    }

    print(result) // action: WAIT or BLOCK
}
