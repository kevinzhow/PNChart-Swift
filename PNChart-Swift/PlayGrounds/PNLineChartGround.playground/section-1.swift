import UIKit
import QuartzCore

var toPushPointer = CGPointMake(1.0, 2.0)
var a = NSValue.valueWithBytes(&toPushPointer, objCType: "CGPoint" )
a
a.copy()
