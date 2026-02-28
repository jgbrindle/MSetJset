//
//  main.swift
//  Graph_Inc
//
//  Created by Jeff Brindle on 28/2/2026.
//

// Adapted from the book "Advanced Graphics Programming in Pascal" by Roger Stevens and Christopher Watkins, 1991

// Utilizes SpriteKit for graphics rendering
// and based on the book's 320 x 200 VGA display with 256 colours

import Foundation
import SpriteKit


// MARK: - Graphics Constants and type aliases

let MaxXRes: Int = 320
let MaxYRes: Int = 200
let MaxX: Int = MaxXRes - 1
let MaxY: Int = MaxYRes - 1

var XRes: Int = 0
var YRes: Int = 0
var PreCalcY: [Int] = Array(repeating: 0, count: MaxY+1)

public typealias PaletteRegister = [SKColor]
var Color: PaletteRegister = [SKColor]()

// MARK: - General Graphics functions

// selects the display mode - for compatibility only: does nothing
func SetMode(Mode: Int) {
}

func PreCalc() {
    for j in 0...MaxY {
        PreCalcY[j] = XRes * j
    }
}

// single pixel draw routine - note uses SKShapeNode and extra parent parameter
func Plot(x: Int, y: Int, ColorIndex: Int, parent: SKNode) {
    if !(x < 0 || y < 0 || x > MaxX || y > MaxY) {
        let pixel = SKSpriteNode(color: Color[ColorIndex], size: CGSize(width: 1, height: 1))
        pixel.position = CGPoint(x: CGFloat(x), y: CGFloat(MaxY - y))
        parent.addChild(pixel)

        if SavePlottedPixelColor {
            SavedPixels[y][x] = ColorIndex
        }
    }
}


// reset all entries in the palette register to 0's
func ClearPalette(ColorPalette: inout PaletteRegister) {
    for i in 0...255 {
        ColorPalette[i] = .black
    }
}

// not needed with my implementation as read colors directly
// from palette register not ROM BIOS
func SetPalette(_hue: inout PaletteRegister) {

}

// sets the 256 colours to the standard EGA set
// 64 levels of grey, red, green and blue
func InitPalette1(ColorPalette: inout PaletteRegister) {
    ColorPalette = [SKColor](repeating: .black, count: 256)
    // greys
    for i in 0...63 {
        ColorPalette[i] = SKColor(
            red: CGFloat(i) / 63.0,
            green: CGFloat(i) / 63.0,
            blue: CGFloat(i) / 63.0,
            alpha: 1.0
        )
    }
    // reds
    for i in 64...127 {
        ColorPalette[i] = SKColor(
            red: CGFloat(i - 64) / 63.0,
            green: 0,
            blue: 0,
            alpha: 1.0
        )
    }
    // greens
    for i in 128...191 {
        ColorPalette[i] = SKColor(
            red: 0,
            green: CGFloat(i - 128) / 63.0,
            blue: 0,
            alpha: 1.0
        )
    }
    // blues
    for i in 192...255 {
        ColorPalette[i] = SKColor(
            red: 0,
            green: 0,
            blue: CGFloat(i - 192) / 63.0,
            alpha: 1.0
        )
    }
}

// sets the 256 colors to 7 colors with 35 intensities each
func InitPalette2(ColorPalette: inout PaletteRegister) {
    ColorPalette = [SKColor](repeating: .black, count: 256)
    // shades of blue
    for i in 0...35 {
        ColorPalette[i] = SKColor(
            red: 0,
            green: 0,
            blue: CGFloat(1.8 * Double(i)) / 63.0,
            alpha: 1.0
        )
    }
    // shade of green
    for i in 36...71 {
        ColorPalette[i] = SKColor(
            red: 0,
            green: CGFloat(1.8 * Double(i - 36)) / 63.0,
            blue: 0,
            alpha: 1.0
        )
    }
    // shades of cyan
    for i in 72...107 {
        ColorPalette[i] = SKColor(
            red: 0,
            green: CGFloat(1.8 * Double(i - 72)) / 63.0,
            blue: CGFloat(1.8 * Double(i - 72)) / 63.0,
            alpha: 1.0
        )
    }
    // shades of red
    for i in 108...143 {
        ColorPalette[i] = SKColor(
            red: CGFloat(1.8 * Double(i - 108)) / 63.0,
            green: 0,
            blue: 0,
            alpha: 1.0
        )
    }
    // shades of magenta
    for i in 144...179 {
        ColorPalette[i] = SKColor(
            red: CGFloat(1.8 * Double(i - 144)) / 63.0,
            green: 0,
            blue: CGFloat(1.8 * Double(i - 144)) / 63.0,
            alpha: 1.0
        )
    }
    // shades of yellow
    for i in 180...215 {
        ColorPalette[i] = SKColor(
            red: CGFloat(1.8 * Double(i - 180)) / 63.0,
            green: CGFloat(1.8 * Double(i - 180)) / 63.0,
            blue: 0,
            alpha: 1.0
        )
    }
    // shades of gray
    for i in 216...251 {
        ColorPalette[i] = SKColor(
            red: CGFloat(1.8 * Double(i - 216)) / 63.0,
            green: CGFloat(1.8 * Double(i - 216)) / 63.0,
            blue: CGFloat(1.8 * Double(i - 216)) / 63.0,
            alpha: 1.0
        )
    }
}

// cycles all the colors down one slot - wrapping around
func CyclePalette(Hue: inout PaletteRegister) {
    let tmp: SKColor = Hue[0]

    for i in 1...256 {
        Hue[i - 1] = Hue[i]
    }
    Hue[255] = tmp
}

// swap 2 ints
func Swap(first: inout Int, second: inout Int) {
    (first, second) = (second, first)
}


// circle outline draw routine - note uses SKShapeNode and extra parent parameter
func Circle(x: Int, y: Int, Radius: Int, ColorIndex: Int, parent: SKNode) {
    let circle: SKShapeNode = SKShapeNode(circleOfRadius: CGFloat(Radius))
    circle.position = CGPoint(x: CGFloat(x), y: CGFloat(MaxY - y))
    circle.strokeColor = Color[ColorIndex]
    circle.lineWidth = 1
    parent.addChild(circle)
}

// draw a line - note uses SKShape Node and extra parent parameter
func Draw(
    xx1: Int,
    yy1: Int,
    xx2: Int,
    yy2: Int,
    ColorIndex: Int,
    parent: SKNode
) {
    let pathToDraw = CGMutablePath()
    pathToDraw.move(to: CGPoint(x: CGFloat(xx1), y: CGFloat(MaxY - yy1)))
    pathToDraw.addLine(to: CGPoint(x: CGFloat(xx2), y: CGFloat(MaxY - yy2)))
    let line: SKShapeNode = SKShapeNode(path: pathToDraw)
    line.strokeColor = Color[ColorIndex]
    line.lineWidth = 1
    parent.addChild(line)
}

func InitGraphics() {
    XRes = MaxXRes
    YRes = MaxYRes
    PreCalc()
    SetMode(Mode: 19)
    Color = [SKColor](repeating: SKColor.black, count: 256)
    ClearPalette(ColorPalette: &Color)
    InitPalette2(ColorPalette: &Color)
}

// stops all program action except that of looking for a key to be pressed at the keyboard. Function terminates when a key having an ASCII value of greater than a space is entered.
func WaitForKey() {
    var c: Int32 = 0
    repeat {
        c = 0
        while c == 0 {
            usleep(1000)
            c = getchar()
        }
    } while c <= 32
}

// does nothing in my implementation except play a sound
func ExitGraphics(parent: SKNode) {
    let sound = SKAction.playSoundFileNamed(
        "finished.wav",
        waitForCompletion: false
    )
    parent.run(sound)
}

func Title(parent: SKNode) {
    parent.removeAllChildren()
}


// =======================================================
// ===       Three Dimensional Plotting Routines       ===
// =======================================================


// MARK: - Three Dimensional Plotting Globals

var CentreX: Int = 0
var CentreY: Int = 0
var Angl: Int = 0
var Tilt: Int = 0
var CosA: Double = 0.0
var SinA: Double = 0.0
var CosB: Double = 0.0
var SinB: Double = 0.0
var CosACosB: Double = 0.0
var SinASinB: Double = 0.0
var CosASinB: Double = 0.0
var SinACosB: Double = 0.0


// MARK: - Three Dimensional Plotting Routines

func InitPlotting(Ang: Int, Tlt: Int) {
    CentreX = MaxX / 2
    CentreY = MaxY / 2
    Angl = Ang
    Tilt = Tlt
    CosA = CosD(Angle: Double(Angl))
    SinA = SinD(Angle: Double(Angl))
    CosB = CosD(Angle: Double(Tilt))
    SinB = SinD(Angle: Double(Tilt))
    CosACosB = CosA * CosB
    SinASinB = SinA * SinB
    CosASinB = CosA * SinB
    SinACosB = SinA * CosB
}

var PerspectivePlot: Bool = false
var Mx: Double = 0.0
var My: Double = 0.0
var Mz: Double = 0.0
var ds: Double = 0.0

func InitPerspective(
    Perspective: Bool,
    x: Double,
    y: Double,
    z: Double,
    m: Double
) {
    PerspectivePlot = Perspective
    Mx = x
    My = y
    Mz = z
    ds = m
}

// transform world x, y, z to screen xp, yp
func MapCoordinates(
    X: Double,
    Y: Double,
    Z: Double,
    Xp: inout Int,
    Yp: inout Int
) {
    var Xt: Double, Yt: Double, Zt: Double

    Xt = Mx + X * CosA - Y * SinA
    Yt = My + X * SinASinB + Y * CosASinB + Z * CosB

    if PerspectivePlot {
        Zt = Mz + X * SinACosB + Y * CosACosB - Z * SinB
        Xp = CentreX + Round(x: ds * Xt / Zt)
        Yp = CentreY - Round(x: ds * Yt / Zt)
    } else {
        Xp = CentreX + Round(x: Xt)
        Yp = CentreY - Round(x: Yt)
    }
}

func CartesianPlot3D(
    X: Double,
    Y: Double,
    Z: Double,
    ColorIndex: Int,
    parent: SKNode
) {
    var Xp: Int = 0
    var Yp: Int = 0

    MapCoordinates(X: X, Y: Y, Z: Z, Xp: &Xp, Yp: &Yp)
    Plot(x: Xp, y: Yp, ColorIndex: ColorIndex, parent: parent)
}

func CylindricalPlot3D(
    Rho: Double,
    Theta: Double,
    Z: Double,
    ColorIndex: Int,
    parent: SKNode
) {
    var X: Double, Y: Double

    let ThetaRad: Double = Radians(Angle: Theta)
    X = Rho * cos(ThetaRad)
    Y = Rho * sin(ThetaRad)
    CartesianPlot3D(X: X, Y: Y, Z: Z, ColorIndex: ColorIndex, parent: parent)
}

func SphericalPlot3D(
    R: Double,
    Theta: Double,
    Phi: Double,
    ColorIndex: Int,
    parent: SKNode
) {
    var X: Double, Y: Double, Z: Double

    let ThetaRad: Double = Radians(Angle: Theta)
    let PhiRad: Double = Radians(Angle: Phi)
    X = R * sin(ThetaRad) * cos(PhiRad)
    Y = R * sin(ThetaRad) * sin(PhiRad)
    Z = R * cos(ThetaRad)
    CartesianPlot3D(X: X, Y: Y, Z: Z, ColorIndex: ColorIndex, parent: parent)
}

func DrawLine3D(Pnt1: TDA, Pnt2: TDA, ColorIndex: Int, parent: SKNode) {
    var Xp1: Int = 0
    var Yp1: Int = 0
    var Xp2: Int = 0
    var Yp2: Int = 0
    var x1: Double = 0.0
    var y1: Double = 0.0
    var z1: Double = 0.0
    var x2: Double = 0.0
    var y2: Double = 0.0
    var z2: Double = 0.0

    UnVec(A: Pnt1, r: &x1, s: &y1, t: &z1)
    UnVec(A: Pnt2, r: &x2, s: &y2, t: &z2)

    MapCoordinates(X: x1, Y: y1, Z: z1, Xp: &Xp1, Yp: &Yp1)
    MapCoordinates(X: x2, Y: y2, Z: z2, Xp: &Xp2, Yp: &Yp2)
    Draw(
        xx1: Xp1,
        yy1: Yp1,
        xx2: Xp2,
        yy2: Yp2,
        ColorIndex: ColorIndex,
        parent: parent
    )
}

// MARK: - Pixel
// color 1 = blue
// color 2 = green
// color 3 = cyan
// color 4 = red
// color 5 = magenta
// color 6 = brown/yellow
// color 7 = gray scale

// Intensity levels (0..35) for each color

let MaxCol: Int = 7
let MaxInten: Int = 35


// =======================================================
// ===     PutPixel - plots a pixel to the screen      ===
// =======================================================

func PutPixel(x: Int, y: Int, ColorIndex: Int, Intensity: Int, parent: SKNode)
{
    var Intensity2 = Intensity
    var Col: Int

    if Intensity > MaxInten {
        Intensity2 = MaxInten
    }

    Col = (MaxInten + 1) * (ColorIndex - 1) + Intensity2
    Plot(x: x, y: y, ColorIndex: Col, parent: parent)
}

// =======================================================
// ===     GetPixel - gets a pixel from the screen     ===
// =======================================================

// Note: returns an palette color index not the SKColor

func compareColors(c1: SKColor, c2: SKColor, tolerance: CGFloat = 0.001) -> Bool {
    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

    c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    return abs(r1 - r2) < tolerance &&
           abs(g1 - g2) < tolerance &&
           abs(b1 - b2) < tolerance &&
           abs(a1 - a2) < tolerance
}

// New improved version
var SavedPixels: [[Int]] = [[]] // [height][width] with each entry holding a color index
var SavePlottedPixelColor: Bool = false

// setup SavedPixels if required with background color
func InitSavedPixels(Col: Int) {
    SavedPixels = Array(repeating: Array(repeating: 0, count: MaxXRes), count: MaxYRes)
    if Col != 0 {
        for r in 0..<MaxYRes {
            for c in 0..<MaxXRes {
                SavedPixels[r][c] = Col
            }
        }
    }
    SavePlottedPixelColor = true
}

func GetPixel(x: Int, y: Int) -> Int {
    if SavePlottedPixelColor && x >= 0 && x < MaxXRes && y >= 0 && y < MaxYRes {
        return SavedPixels[y][x]
    } else {
        return 0
    }
}


// ==========================================================
// ===     Setup of coordinate axes and color palette     ===
// ==========================================================

// MARK: - Set up coordinate axes and color palette

var DrawAxisAndPalette: Bool = false

func PutAxisAndPalette(PlaceOnScreen: Bool, parent: SKNode) {
    if PlaceOnScreen {
        DrawAxisAndPalette = true
    } else {
        DrawAxisAndPalette = false
    }
}

func AxisAndPalette(parent: SKNode) {

    func DisplayAxis(parent: SKNode) {
        for x in -100...100 {
            CartesianPlot3D(X: Double(x), Y: 0, Z: 0, ColorIndex: 35, parent: parent) // blue
        }
        CartesianPlot3D(X: 100.0, Y: 0, Z: 0, ColorIndex: 251, parent: parent) // white

        for y in -100...100 {
            CartesianPlot3D(X: 0, Y: Double(y), Z: 0, ColorIndex: 71, parent: parent) // green
        }
        CartesianPlot3D(X: 0, Y: 100, Z: 0, ColorIndex: 251, parent: parent) // white

        for z in -100...100 {
            CartesianPlot3D(X: 0, Y: 0, Z: Double(z), ColorIndex: 107, parent: parent) // cyan
        }
        CartesianPlot3D(X: 0, Y: 0, Z: 100, ColorIndex: 251, parent: parent) // white
    }

    func DisplayPalette(parent: SKNode) {
        for ColorIndex in 1...MaxCol {
            for Intensity in 0...MaxInten {
                for x in 0...3 {
                    for y in 0...3 {
                        PutPixel(x: x + 5 * ColorIndex, y: 190 - y - 5 * Intensity, ColorIndex: ColorIndex, Intensity: Intensity, parent: parent)
                    }
                }
            }
        }
    }

    if DrawAxisAndPalette {
        DisplayAxis(parent: parent)
        DisplayPalette(parent: parent)
    }
}


