import Glibc

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

let DIRECTIONS = [
    "S": "SOUTH",
    "E": "EAST",
    "N": "NORTH",
    "W": "WEST"
]

let START = "@"
let END = "$"
let WALL = "#"
let OBSTACLE = "X"
let BEER = "B"
let INVERSE = "I"
let TELEPORT = "T"
let SPACE = " "

let SOUTH = "S"
let EAST = "E"
let NORTH = "N"
let WEST = "W"

let LOOP = "LOOP"

struct Compass {
    var state = [SOUTH, EAST, NORTH, WEST]

    mutating func reverseDirections() {
        state = state.reversed()
    }

    func getDirection(_ index: Int) -> String {
        let direction = state[index]

        return direction
    }
}

struct Position {
    var x = 0
    var y = 0

    init(x: Int, y: Int) {
       self.x = x
       self.y = y
    }

    func next(_ direction: String) -> Position {
        var _x = x
        var _y = y

        switch direction {
        case SOUTH:
            _y += 1
        case EAST:
            _x += 1
        case NORTH:
            _y -= 1
        case WEST:
            _x -= 1
        default:
            print("NO SUCH DIRECTION \(direction)", to: &errStream)
        }

        return Position(x: _x, y: _y)
    }

    func toString() -> String {
        return "\(x):\(y)"
    }
}

struct Bender {
    var compass = Compass()
    var map: [[String]] = []
    var way: [String] = []
    var beerMode = false
    var position: Position?
    var direction: String?
    var teleports: [String: Position] = [:]

    var loopMode = false
    var loopPositionHash: String?
    var loopIndex: Int?
    var prevPositions: [String] = []
    var loopPositions: [String] = []

    mutating func setMap(map: [[String]]) {
        self.map = map
    }

    mutating func setPosition(x: Int, y: Int) {
        position = Position(x: x, y: y)
    }

    mutating func setTeleports(a: Position, b: Position) {
        teleports[a.toString()] = b
        teleports[b.toString()] = a
    }

    mutating func go() {
        direction = compass.getDirection(0)

        while getCeil(position!) != END && !isLoop()  {
            // remember where we've been
            rememberPosition()
            // try to make one step
            step()
            // update the way
            way.append(DIRECTIONS[direction!]!)

            let ceil = getCeil(position!)

            switch ceil {
            case BEER:
                beerMode = !beerMode
                if beerMode {
                    // print("Beer! I gonna break the wall!", to: &errStream)
                } else {
                    // print("Another beer... I'm too drunk to destroy :(", to: &errStream)
                }
            case OBSTACLE:
                // print("BOOM! Through the wall!", to: &errStream)
                map[position!.y][position!.x] = " "
            case TELEPORT:
                let newPosition = teleports[position!.toString()]!
                // print("Weeep! Looks like I'm teleported \(position!.toString()) -> \(newPosition.toString())", to: &errStream)
                position = newPosition
            case SOUTH, EAST, NORTH, WEST:
                direction = ceil
            case INVERSE:
                // print("Wow! Magneto inverse my navigator!", to: &errStream)
                compass.reverseDirections()
            default:
                break
            }
        }
    }

    mutating func step() {
        var i = 0
        var nextPosition = position?.next(direction!)
        var nextDirection = direction!
        var ceil = getCeil(nextPosition!)

        while (ceil == WALL || (ceil == OBSTACLE && !beerMode)) && i < DIRECTIONS.count {
            nextDirection = compass.getDirection(i)
            nextPosition = position?.next(nextDirection)
            ceil = getCeil(nextPosition!)

            // print("Loking from \(position!.toString()) -> \(nextPosition!.toString()) (\(nextDirection))", to: &errStream)
            i += 1
        }

        if i < DIRECTIONS.count {
            // print("Step from \(position!.toString()) -> \(nextPosition!.toString()) (\(nextDirection))", to: &errStream)
            position = nextPosition
            direction = nextDirection
        }
    }

    mutating func rememberPosition() {
        let positionHash = getPositionHash()

        if loopMode {
            loopPositions.append(positionHash)
        } else {
            prevPositions.append(positionHash)
        }
    }

    /**
     * If bender find himself in same position he was before
     * he starting to record all next steps to compare 
     * when he will be again in this position if it was same loops
     */
    mutating func isLoop() -> Bool {
        var isLoop = false
        let positionHash = getPositionHash()

        // two circles were made, lets compare them
        if loopMode && positionHash == loopPositionHash! {
            let firstLoop = Array(prevPositions[loopIndex!..<prevPositions.count])

            isLoop = loopPositions.count == firstLoop.count && loopPositions.sorted() == firstLoop.sorted()
            if isLoop {
                print("F@$K... I am in LOOP!!!", to: &errStream)
            } else {
                print("I've been here TWICE, but looks like its OKAY... \(loopPositionHash!)", to: &errStream)
            }

            if isLoop {
                way = [LOOP]
            } else {
                // no loop, reset paths
                loopPositions = []
                prevPositions = []
                loopMode = false
            }

            return isLoop
        }

        if loopPositionHash == nil && prevPositions.contains(positionHash) {
            loopPositionHash = positionHash
            loopIndex = prevPositions.index(of: positionHash)
            loopMode = true
            print("I've been HERE! \(loopPositionHash!)", to: &errStream)
        }

        return false
    }

    func getPositionHash() -> String {
        return "\(position!.x)_\(position!.y)_\(direction!)\(beerMode ? "_B" : "")"
    }

    func getCeil(_ position: Position) -> String {
        return map[position.y][position.x]
    }

    func getWay() -> [String] {
        return way
    }
}

var bender = Bender()
var map = [[String]]()
var teleports = [Position]()

let inputs = (readLine()!).characters.split{$0 == " "}.map(String.init)
let L = Int(inputs[0])!
let C = Int(inputs[1])!
if L > 0 {
    for i in 0...(L-1) {
        let row = readLine()!.characters.map { String($0) }

        for (j, char) in row.enumerated() {
            if char == START {
                bender.setPosition(x:j, y:i)
            }

            if char == TELEPORT {
                teleports.append(Position(x:j, y:i))
            }
        }

        map.append(row)

        print(row, to: &errStream)
    }
}

bender.setMap(map: map)

if teleports.count == 2 {
    bender.setTeleports(a: teleports[0], b: teleports[1])
}

bender.go()

for way in bender.getWay() {
    print(way)
}
