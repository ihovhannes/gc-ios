//
// Created by Hovhannes Sukiasian on 28/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation

class GeometryUtils {

    public static func calcFrac(prev: Double, next: Double, cur: Double) -> Double {
        if (next == prev) {
            return 0;
        }
        return (cur - prev) / (next - prev);
    }

    public static func calcSegmentPos(prev: Double, next: Double, frac: Double) -> Double {
        return prev * (1 - frac) + next * frac;
    }

}
