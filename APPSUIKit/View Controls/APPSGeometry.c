//
//  APPSGeometry.c
//
//  Created by Chris Morris on 6/25/14.
//

#include "APPSGeometry.h"

#pragma mark - Line Related Functions
APPSLine APPSLineMake(CGFloat slope, CGFloat yIntercept)
{
    return (APPSLine){.slope = slope, .yIntercept =  yIntercept};
}

APPSLine APPSLineFromPoints(CGPoint point1, CGPoint point2)
{
    CGFloat slope      = (point1.y - point2.y) / (point1.x - point2.x);
    CGFloat yIntercept = point1.y - (slope * point1.x);

    return (APPSLine){.slope = slope, .yIntercept = yIntercept};
}

APPSLine APPSLineFromSlopeAndPoint(CGFloat slope, CGPoint point)
{
    return (APPSLine){.slope      = slope,
                      .yIntercept = point.y - (slope * point.x)};
}

CGPoint APPSLineGetXIntercept(APPSLine line)
{
    return CGPointMake(-(line.yIntercept / line.slope), 0);
}

CGPoint APPSLineGetYIntercept(APPSLine line)
{
    return CGPointMake(0, line.yIntercept);
}

/**
 Find the point along the line given the x-value.
 */
CGPoint APPSLinePointWithX(APPSLine line, CGFloat x)
{
    return CGPointMake(x, line.slope * x + line.yIntercept);
}

/**
 Find the point along the line given the y-value.
 */
CGPoint APPSLinePointWithY(APPSLine line, CGFloat y)
{
    return CGPointMake((y - line.yIntercept) / line.slope, y);
}

