//
//  GameScene.swift
//  MSetJset
//
//  Created by Jeff Brindle on 28/2/2026.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene {

    let XMin: Double = -2.20
    let XMax: Double = 0.60
    let YMin: Double = -1.20
    let YMax: Double = 1.20
    let MaxIter: Int = 30
    let Res: Int = 160

    var isWaitingForKey = false
    var lastKeyPress = ""

    func CalcMSet() {

        func Iterate(cx: Double, cy: Double) -> Int {
            var Iters: Int
            var x: Double
            var y: Double
            var x2: Double
            var y2: Double
            var temp: Double

            x = cx
            x2 = SqrFP(x: x)
            y = cy
            y2 = SqrFP(x: y)
            Iters = 0

            while (Iters < MaxIter) && (x2 + y2) < 4.0 {
                temp = cx + x2 - y2
                y = cy + 2 * x * y
                y2 = SqrFP(x: y)
                x = temp
                x2 = SqrFP(x: x)
                Iters += 1
            }
            return Iters
        }

        func Pix(x: Int, y: Int, col: Int) {
            Plot(x: x, y: y, ColorIndex: col, parent: self)
            Plot(x: x, y: Res - y - 1, ColorIndex: col, parent: self)
        }

        var Iters: Int
        var cx: Double
        var cy: Double
        var dx: Double
        var dy: Double
        var L1: Int
        var L2: Int

        Draw(xx1: 0, yy1: 0, xx2: Res - 1, yy2: 0, ColorIndex: 35, parent: self)
        Draw(
            xx1: Res - 1,
            yy1: 0,
            xx2: Res - 1,
            yy2: Res - 1,
            ColorIndex: 35,
            parent: self
        )
        Draw(
            xx1: Res - 1,
            yy1: Res,
            xx2: 0,
            yy2: Res,
            ColorIndex: 35,
            parent: self
        )
        Draw(xx1: 0, yy1: Res, xx2: 0, yy2: 0, ColorIndex: 35, parent: self)

        Draw(
            xx1: Res,
            yy1: 0,
            xx2: 2 * Res - 1,
            yy2: 0,
            ColorIndex: 35,
            parent: self
        )
        Draw(
            xx1: 2 * Res - 1,
            yy1: 0,
            xx2: 2 * Res - 1,
            yy2: Res - 1,
            ColorIndex: 35,
            parent: self
        )
        Draw(
            xx1: 2 * Res - 1,
            yy1: Res,
            xx2: Res,
            yy2: Res,
            ColorIndex: 35,
            parent: self
        )

        // limits for color calc
        L1 = MaxIter - (MaxIter * 2) / 3
        L2 = MaxIter - (MaxIter * 5) / 6

        dx = (XMax - XMin) / Double(Res - 1)
        dy = (YMax - YMin) / Double(Res - 1)

        for iy in 2...((Res - 1) / 2) {
            cy = YMin + Double(iy) * dy
            for ix in 2...(Res - 3) {
                cx = XMin + Double(ix) * dx
                Iters = Iterate(cx: cx, cy: cy)
                if Iters == MaxIter {
                    // color based on number of iterations
                    Pix(x: ix, y: iy, col: 143)  // light red
                } else {
                    if Iters > L1 {
                        Pix(x: ix, y: iy, col: 215)  // light yellow
                    } else {
                        if Iters > L2 {
                            Pix(x: ix, y: iy, col: 35)  // light blue
                        }
                    }
                }
            }
        }
    }

    func CalcJSet(cx: Double, cy: Double, x: inout Double, y: inout Double) {
        var xp: Int
        var yp: Int
        var dx: Double
        var dy: Double
        var r: Double
        var Theta: Double

        for _ in 0..<100 {
            // calculate Julia Set by iterating inverse equation

            dx = x - cx
            dy = y - cy
            if dx > 0 {
                Theta = atan(dy / dx) * 0.5
            } else {
                if dx < 0 {
                    Theta = (Pi + atan(dy / dx)) * 0.5
                } else {
                    Theta = Pi * 0.25
                }
            }
            r = sqrt(sqrt(SqrFP(x: dx) + SqrFP(x: dy)))

            if Float.random(in: 0.0..<1.0) < 0.5 {
                r = -r
            }
            x = r * cos(Theta)
            y = r * sin(Theta)
            xp = Res / 2 + Round(x: x * 36) + Res
            yp = Res / 2 + Round(x: y * 36)
            Plot(x: xp, y: yp, ColorIndex: 143, parent: self)  // light red

        }
    }

    var ColrArray: [Int] = Array(repeating: 0, count: 10)

    func InitCursor() {
        ColrArray = Array(repeating: 0, count: 10)
    }

    func PutCursor(x: Int, y: Int, ox: inout Int, oy: inout Int) {
        // restore the screen
        for xx in 1...5 {
            Plot(x: ox + xx - 3, y: oy, ColorIndex: ColrArray[xx], parent: self)
        }
        for xx in 6...7 {
            Plot(x: ox, y: oy + xx - 8, ColorIndex: ColrArray[xx], parent: self)
        }
        for xx in 8...9 {
            Plot(x: ox, y: oy + xx - 7, ColorIndex: ColrArray[xx], parent: self)
        }

        // save the screen
        for xx in 1...5 {
            ColrArray[xx] = GetPixel(x: x + xx - 3, y: y)
        }
        for xx in 6...7 {
            ColrArray[xx] = GetPixel(x: x, y: y + xx - 8)
        }
        for xx in 8...9 {
            ColrArray[xx] = GetPixel(x: x, y: y + xx - 7)
        }

        // draw green cursor
        Draw(xx1: x - 2, yy1: y, xx2: x + 2, yy2: y, ColorIndex: 71, parent: self)
        Draw(xx1: x, yy1: y-2, xx2: x, yy2: y + 2, ColorIndex: 71, parent: self)

        ox = x
        oy = y
    }

    func BlockHalfScreen() {
        // different to book
        self.removeAllChildren()
        CalcMSet()
    }

    func ViewStats(cxVal: Double, cyVal: Double) {
        print("Mandelbrot Set: ")
        print("   XMin = \(XMin)")
        print("   XMax = \(XMax)")
        print("   YMin = \(YMin)")
        print("   YMax = \(YMax)")
        print()
        print("Julia Set: ")
        print("   cx =   \(cxVal)")
        print("   cy =   \(cyVal)")
        InitGraphics()
        InitCursor()
        CalcMSet()
    }

    func WalkAbout(CursX: inout Int, CursY: inout Int, cx: inout Double, cy: inout Double) {
        var dx: Double, dy: Double

        dx = (XMax - XMin) / Double(Res - 1)
        dy = (YMax - YMin) / Double(Res - 1)

        switch lastKeyPress {
        case " ":
            ViewStats(cxVal: cx, cyVal: cy)
            lastKeyPress = ""
        case "a":
            CursX -= 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "d":
            CursX += 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "w":
            CursY -= 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "s":
            CursY += 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "q":
            CursX -= 1
            CursY -= 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "e":
            CursX += 1
            CursY -= 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "z":
            CursX -= 1
            CursY += 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "x":
            CursX += 1
            CursY += 1
            PutCursor(x: CursX, y: CursY, ox: &CursX, oy: &CursY)
            lastKeyPress = ""
        case "j":
            BlockHalfScreen()
            lastKeyPress = ""
            cx = XMin + dx * Double(CursX)
            cy = YMin + dy * Double(CursY)
            isWaitingForKey = true // start the Julia set

        default:
            lastKeyPress = ""
        }
    }

    override func didMove(to view: SKView) {
        self.view?.window?.makeFirstResponder(self)  // Ensure scene gets input

        InitGraphics()
        InitSavedPixels(Col: 0)
        InitCursor()
        CalcMSet()
        PutCursor(x: 3, y: 3, ox: &CursX, oy: &CursY)

        isWaitingForKey = true // start of Julia render
        ExitGraphics(parent: self)
    }

    func touchDown(atPoint pos: CGPoint) {

    }

    func touchMoved(toPoint pos: CGPoint) {

    }

    func touchUp(atPoint pos: CGPoint) {

    }

    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }

    override func keyDown(with event: NSEvent) {

        switch event.keyCode {
        case 53:  // escape
            exit(0)

        default:
            if isWaitingForKey {
                isWaitingForKey = false
            }
            lastKeyPress = event.characters!
        }
    }

    var JuliaX: Double = 0.0
    var JuliaY: Double = 0.0
    var cx: Double = 0.0
    var cy: Double = 0.0
    var CursX: Int = 3
    var CursY: Int = 3

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        if isWaitingForKey {
            CalcJSet(cx: cx, cy: cy, x: &JuliaX, y: &JuliaY)
        } else {
            WalkAbout(CursX: &CursX, CursY: &CursY, cx: &cx, cy: &cy)
        }

    }
}
