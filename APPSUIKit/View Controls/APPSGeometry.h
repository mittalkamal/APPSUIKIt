//
//  APPSGeometry.h
//
//  Created by Chris Morris on 6/25/14.
//

#ifndef APPSGeometry_h
#define APPSGeometry_h

#include <CoreGraphics/CGGeometry.h>

struct APPSLine {
    CGFloat slope;
    CGFloat yIntercept;
};

typedef struct APPSLine APPSLine;


APPSLine APPSLineMake(CGFloat slope, CGFloat yIntercept);

APPSLine APPSLineFromPoints(CGPoint point1, CGPoint point2);

APPSLine APPSLineFromSlopeAndPoint(CGFloat slope, CGPoint point);

CGPoint APPSLineGetXIntercept(APPSLine line);

CGPoint APPSLineGetYIntercept(APPSLine line);

/**
 Find the point along the line given the x-value.
 */
CGPoint APPSLinePointWithX(APPSLine line, CGFloat x);

/**
 Find the point along the line given the y-value.
 */
CGPoint APPSLinePointWithY(APPSLine line, CGFloat y);

#endif
