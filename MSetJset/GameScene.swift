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
    let Res: Int = MaxX / 2

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

        for _ in 0..<1000 {
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
            xp = Res / 2 + Round(x: x * 36 * 4) + Res
            yp = Res / 2 + Round(x: y * 36 * 4)
            Plot(x: xp, y: yp, ColorIndex: 143, parent: self)  // light red

        }
    }

    var ColrArray: [Int] = Array(repeating: 0, count: 34)

    func InitCursor() {
        ColrArray = Array(repeating: 0, count: 34)
    }

    func PutCursor(x: Int, y: Int, ox: Int, oy: Int) {
        // restore the screen
        for xx in 1...17 {
            Plot(x: ox + xx - 9, y: oy, ColorIndex: ColrArray[xx], parent: self)
        }
        for xx in 18...25 {
            Plot(
                x: ox,
                y: oy + xx - 25,
                ColorIndex: ColrArray[xx],
                parent: self
            )
        }
        for xx in 26...33 {
            Plot(
                x: ox,
                y: oy + xx - 26,
                ColorIndex: ColrArray[xx],
                parent: self
            )
        }

        // save the screen
        for xx in 1...17 {
            ColrArray[xx] = GetPixel(x: x + xx - 9, y: y)
        }
        for xx in 18...25 {
            ColrArray[xx] = GetPixel(x: x, y: y + xx - 25)
        }
        for xx in 26...33 {
            ColrArray[xx] = GetPixel(x: x, y: y + xx - 26)
        }

        // draw green cursor
        Draw(
            xx1: x - 8,
            yy1: y,
            xx2: x + 8,
            yy2: y,
            ColorIndex: 71,
            parent: self
        )
        Draw(
            xx1: x,
            yy1: y - 8,
            xx2: x,
            yy2: y + 8,
            ColorIndex: 71,
            parent: self
        )

    }

    func BlockClearHalfScreen() {
        // different to book
//        self.removeAllChildren()
//        CalcMSet()
        // remove all children named "Julia"
        //        for child in self.children {
        //            if child.name == "Julia" {
        //                child.removeFromParent()
        //            }
        //        }
        let rectSize = CGSize(width: Res - 10, height: Res - 10)
        let filledRect = SKSpriteNode(color: .black, size: rectSize)

        // Position the rectangle
        filledRect.position = CGPoint(x: Res + Res / 2 , y: Res / 2)

        // Add to scene
        addChild(filledRect)

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

    func WalkAbout(
        CursX: inout Int,
        CursY: inout Int,
        cx: inout Double,
        cy: inout Double
    ) {
        var dx: Double
        var dy: Double

        dx = (XMax - XMin) / Double(Res - 1)
        dy = (YMax - YMin) / Double(Res - 1)

        let oCursX = CursX
        let oCursY = CursY

        switch lastKeyPress {
        case " ":
            ViewStats(cxVal: cx, cyVal: cy)
            lastKeyPress = ""
        case "a":
            CursX -= 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "d":
            CursX += 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "w":
            CursY -= 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "s":
            CursY += 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "q":
            CursX -= 4
            CursY -= 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "e":
            CursX += 4
            CursY -= 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "z":
            CursX -= 4
            CursY += 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "x":
            CursX += 4
            CursY += 4
            PutCursor(x: CursX, y: CursY, ox: oCursX, oy: oCursY)
            lastKeyPress = ""
        case "j":
            BlockClearHalfScreen()
            lastKeyPress = ""
            cx = XMin + dx * Double(CursX)
            cy = YMin + dy * Double(CursY)
            isWaitingForKey = true  // start the Julia set

        default:
            lastKeyPress = ""
        }
    }

    override func didMove(to view: SKView) {
        self.view?.window?.makeFirstResponder(self)  // Ensure scene gets input
        self.backgroundColor = SKColor.black

        InitGraphics()
        InitSavedPixels(Col: 0)
        InitCursor()
        CalcMSet()
        PutCursor(x: 9, y: 9, ox: CursX, oy: CursY)

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
