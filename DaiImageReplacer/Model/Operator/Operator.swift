//
//  Operator.swift
//  DaiImageReplacer
//
//  Created by DaidoujiChen on 2015/12/11.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

func +(left: String, right: Int) -> String {
    return String(format: "%@%td", left, right)
}

func +(left: Int, right: String) -> String {
    return String(format: "%td%@", left, right)
}

func +(left: String, right: Double) -> String {
    return String(format: "%@%f", left, right)
}

func +(left: Double, right: String) -> String {
    return String(format: "%f%@", left, right)
}