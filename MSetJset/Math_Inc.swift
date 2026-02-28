//
//  main.swift
//  Math_Inc
//
//  Created by Jeff Brindle on 28/2/2026.
//
// Adapted from the book "Advanced Graphics Programming in Pascal" by Roger Stevens and Christopher Watkins, 1991

import Foundation


// =======================================================
// ===              Mathematical Functions             ===
// =======================================================


// MARK: - Mathematical Constants and type aliases

let Ln10: Double = 2.3025850929940456840179134573846
let Pi: Double = 3.1415926535897932384626433832795
let PiOver180: Double = 0.017453292519943295769236907684886
let PiUnder180: Double = 57.295779513082320876798154117944


// MARK: - Mathematical Functions

func Round(x: Double) -> Int {
    return Int(round(x))
}

func Trunc(x: Double) -> Int {
    return Int(x)
}

func SqrFP(x: Double) -> Double {
    return x * x
}

func Sqr(x: Int) -> Int {
    return x * x
}

func Radians(Angle: Double) -> Double {
    return Angle * PiOver180
}

func Degrees(Angle: Double) -> Double {
    return Angle * PiUnder180
}

func CosD(Angle: Double) -> Double {
    return cos(Radians(Angle: Angle))
}

func SinD(Angle: Double) -> Double {
    return sin(Radians(Angle: Angle))
}

func Power(Base: Double, Exponent: Int) -> Double {
    if Exponent == 0 {
        return 1.0
    } else {
        var BPower: Double = 1.0
        for _ in 1...Exponent {
            BPower *= Base
        }
        return BPower
    }
}

func Log(x: Double) -> Double {
    return log(x) / Ln10
}

func Exp10(x: Double) -> Double {
    return exp(x * Ln10)
}

func Sign(x: Double) -> Int {
    if x < 0 {
        return -1
    } else {
        if x > 0 {
            return 1
        } else {
            return 0
        }
    }
}

func IntSign(x: Int) -> Int {
    if x < 0 {
        return -1
    } else {
        if x > 0 {
            return 1
        } else {
            return 0
        }
    }
}

func IntSqrt(x: Int) -> Int {
    var NewX = x
    var OddInt: Int, FirstSqrt: Int

    OddInt = 1

    while NewX >= 0 {
        NewX -= OddInt
        OddInt += 2
    }
    FirstSqrt = OddInt >> 1
    if Sqr(x: FirstSqrt) - FirstSqrt + 1 > x {
        return FirstSqrt - 1
    } else {
        return FirstSqrt
    }
}

func IntPower(Base: Int, Exponent: Int) -> Int {
    if Exponent == 0 {
        return 1
    }
    return Base * IntPower(Base: Base, Exponent: Exponent - 1)
}


// =======================================================
// ===            Vector and Matrix Routines           ===
// =======================================================

// MARK: - Vector and Matrix type aliases

typealias TDA = [Double]  // [0..2]
typealias TDIA = [Int]  // [0..2]
typealias FDA = [Double]  // [0..3]
typealias Matx4x4 = [[Double]]  // [0..3][0..3]

// New*    My own routines not in book
func NewTDA() -> TDA {
    return [0.0, 0.0, 0.0]
}

func NewTDIA() -> TDIA {
    return [0, 0, 0]
}

func NewFDA() -> FDA {
    return [0.0, 0.0, 0.0, 0.0]
}

func NewMat4x4() -> Matx4x4 {
    return [
        [0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 0.0]
    ]
}

// MARK: - Vector and Matrix Routines

func Vec(r: Double, s: Double, t: Double, A: inout TDA) {
    A[0] = r
    A[1] = s
    A[2] = t
}

func VecInt(r: Int, s: Int, t: Int, A: inout TDIA) {
    A[0] = r
    A[1] = s
    A[2] = t
}

func UnVec(A: TDA, r: inout Double, s: inout Double, t: inout Double) {
    r = A[0]
    s = A[1]
    t = A[2]
}

func UnVecInt(A: TDIA, r: inout Int, s: inout Int, t: inout Int) {
    r = A[0]
    s = A[1]
    t = A[2]
}

func VecDot(A: TDA, B: TDA) -> Double {
    return A[0] * B[0] + A[1] * B[1] + A[2] * B[2]
}

func VecCross(A: TDA, B: TDA, C: inout TDA) {
    C[0] = A[1] * B[2] - A[2] * B[1]
    C[1] = A[2] * B[0] - A[0] * B[2]
    C[2] = A[0] * B[1] - A[1] * B[0]
}

func VecLen(A: TDA) -> Double {
    return sqrt(SqrFP(x: A[0]) + SqrFP(x: A[1]) + SqrFP(x: A[2]))
}

func VecNormalize(A: inout TDA) {
    var dist: Double, invdist: Double

    dist = VecLen(A: A)
    if !dist.isZero {
        invdist = 1.0 / dist
        A[0] *= invdist
        A[1] *= invdist
        A[2] *= invdist
    } else {
        fatalError("Zero-Length Vectors cannot be Normalized")
    }
}

func VecMatxMult(A: FDA, Matrix: Matx4x4, B: inout FDA) {
    for mCol in 0...3 {
        B[mCol] = 0.0
        for mRow in 0...3 {
            B[mCol] += A[mRow] * Matrix[mRow][mCol]
        }
    }
}

func VecSub(A: TDA, B: TDA, C: inout TDA) {
    C[0] = A[0] - B[0]
    C[1] = A[1] - B[1]
    C[2] = A[2] - B[2]
}

func VecSubInt(A: TDIA, B: TDIA, C: inout TDIA) {
    C[0] = A[0] - B[0]
    C[1] = A[1] - B[1]
    C[2] = A[2] - B[2]
}

func VecAdd(A: TDA, B: TDA, C: inout TDA) {
    C[0] = A[0] + B[0]
    C[1] = A[1] + B[1]
    C[2] = A[2] + B[2]
}

func VecAdd3(A: TDA, B: TDA, C: TDA, D: inout TDA) {
    D[0] = A[0] + B[0] + C[0]
    D[1] = A[1] + B[1] + C[1]
    D[2] = A[2] + B[2] + C[2]
}

func VecCopy(A: TDA, B: inout TDA) {
    B[0] = A[0]
    B[1] = A[1]
    B[2] = A[2]
}

func VecLinComb(r: Double, A: TDA, s: Double, B: TDA, C: inout TDA) {
    C[0] = r * A[0] + s * B[0]
    C[1] = r * A[1] + s * B[1]
    C[2] = r * A[2] + s * B[2]
}

func VecScalMult(r: Double, A: TDA, B: inout TDA) {
    B[0] = r * A[0]
    B[1] = r * A[1]
    B[2] = r * A[2]
}

func VecScalMultI(r: Double, A: TDIA, B: inout TDA) {
    B[0] = r * Double(A[0])
    B[1] = r * Double(A[1])
    B[2] = r * Double(A[2])
}

func VecScalMultInt(r: Double, A: TDA, B: inout TDIA) {
    B[0] = Round(x: r * A[0])
    B[1] = Round(x: r * A[1])
    B[2] = Round(x: r * A[2])
}

func VecAddScalMult(r: Double, A: TDA, B: TDA, C: inout TDA) {
    C[0] = r * A[0] + B[0]
    C[1] = r * A[1] + B[1]
    C[2] = r * A[2] + B[2]
}

func VecNull(A: inout TDA) {
    A[0] = 0.0
    A[1] = 0.0
    A[2] = 0.0
}

func VecNullInt(A: inout TDIA) {
    A[0] = 0
    A[1] = 0
    A[2] = 0
}

func VecElemMult(r: Double, A: TDA, B: TDA, C: inout TDA) {
    C[0] = r * A[0] * B[0]
    C[1] = r * A[1] * B[1]
    C[2] = r * A[2] * B[2]
}




// =======================================================
// ===            Affine Transform Routines            ===
// =======================================================


func ZeroMatrix(A: inout Matx4x4) {
    for i in 0...3 {
        for j in 0...3 {
            A[i][j] = 0.0
        }
    }
}

func Translate3D(tx: Double, ty: Double, tz: Double, A: inout Matx4x4) {
    ZeroMatrix(A: &A)

    for i in 0...3 {
        A[i][i] = 1.0
    }
    A[0][3] = -tx
    A[1][3] = -ty
    A[2][3] = -tz
}

func Scale3D(sx: Double, sy: Double, sz: Double, A: inout Matx4x4) {
    ZeroMatrix(A: &A)

    A[0][0] = sx
    A[1][1] = sy
    A[2][2] = sz
    A[3][3] = 1.0
}

func Rotate3D(m: Int, Theta: Double, A: inout Matx4x4) {
    var m1: Int, m2: Int
    var c: Double, s: Double

    ZeroMatrix(A: &A)

    A[m - 1][m - 1] = 1.0
    A[3][3] = 1.0
    m1 = (m % 3) + 1
    m2 = m1 % 3
    m1 -= 1
    c = CosD(Angle: Theta)
    s = SinD(Angle: Theta)
    A[m1][m1] = c
    A[m1][m2] = s
    A[m2][m2] = c
    A[m2][m1] = -s
}

func Multiply3DMatricies(A: Matx4x4, B: Matx4x4, C: inout Matx4x4) {
    var ab: Double

    for i in 0...3 {
        for j in 0...3 {
            ab = 0.0
            for k in 0...3 {
                ab += A[i][k] * B[k][j]
            }
            C[i][j] = ab
        }
    }
}

func MatCopy(A: Matx4x4, B: inout Matx4x4) {
    for i in 0...3 {
        for j in 0...3 {
            B[i][j] = A[i][j]
        }
    }
}

func PrepareMatrix(
    Tx: Double,
    Ty: Double,
    Tz: Double,
    Sx: Double,
    Sy: Double,
    Sz: Double,
    Rx: Double,
    Ry: Double,
    Rz: Double,
    XForm: inout Matx4x4
) {
    var M1 = NewMat4x4()
    var M2 = NewMat4x4()
    var M3 = NewMat4x4()
    var M4 = NewMat4x4()
    var M5 = NewMat4x4()
    var M6 = NewMat4x4()
    var M7 = NewMat4x4()
    var M8 = NewMat4x4()
    var M9 = NewMat4x4()

    Scale3D(sx: Sx, sy: Sy, sz: Sz, A: &M1)
    Rotate3D(m: 1, Theta: Rx, A: &M2)
    Rotate3D(m: 2, Theta: Ry, A: &M3)
    Rotate3D(m: 3, Theta: Rz, A: &M4)
    Translate3D(tx: Tx, ty: Ty, tz: Tz, A: &M5)
    Multiply3DMatricies(A: M2, B: M1, C: &M6)
    Multiply3DMatricies(A: M3, B: M6, C: &M7)
    Multiply3DMatricies(A: M4, B: M7, C: &M8)
    Multiply3DMatricies(A: M5, B: M8, C: &M9)
    MatCopy(A: M9, B: &XForm)
}

func PrepareInvMatrix(
    Tx: Double,
    Ty: Double,
    Tz: Double,
    Sx: Double,
    Sy: Double,
    Sz: Double,
    Rx: Double,
    Ry: Double,
    Rz: Double,
    XForm: inout Matx4x4
) {
    var M1 = NewMat4x4()
    var M2 = NewMat4x4()
    var M3 = NewMat4x4()
    var M4 = NewMat4x4()
    var M5 = NewMat4x4()
    var M6 = NewMat4x4()
    var M7 = NewMat4x4()
    var M8 = NewMat4x4()
    var M9 = NewMat4x4()

    Scale3D(sx: Sx, sy: Sy, sz: Sz, A: &M1)
    Rotate3D(m: 1, Theta: Rx, A: &M2)
    Rotate3D(m: 2, Theta: Ry, A: &M3)
    Rotate3D(m: 3, Theta: Rz, A: &M4)
    Translate3D(tx: Tx, ty: Ty, tz: Tz, A: &M5)
    Multiply3DMatricies(A: M4, B: M5, C: &M6)
    Multiply3DMatricies(A: M3, B: M6, C: &M7)
    Multiply3DMatricies(A: M2, B: M7, C: &M8)
    Multiply3DMatricies(A: M1, B: M8, C: &M9)
    MatCopy(A: M9, B: &XForm)
}

func Transform(A: TDA, M: Matx4x4, B: inout TDA) {
    B[0] = M[0][0] * A[0] + M[0][1] * A[1] + M[0][2] * A[2] + M[0][3]
    B[1] = M[1][0] * A[0] + M[1][1] * A[1] + M[1][2] * A[2] + M[1][3]
    B[2] = M[2][0] * A[0] + M[2][1] * A[1] + M[2][2] * A[2] + M[2][3]
}
