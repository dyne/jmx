//
//  JMXPoint.m
//  JMX
//
//  Created by xant on 9/5/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//
//  This file is part of JMX
//
//  JMX is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Foobar is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with JMX.  If not, see <http://www.gnu.org/licenses/>.
//

#import "JMXPoint.h"


@implementation JMXPoint

@synthesize nsPoint;

+ (id)pointWithNSPoint:(NSPoint)point
{
    id obj = [JMXPoint alloc];
    return [[obj initWithNSPoint:point] autorelease];
}

- (id)initWithNSPoint:(NSPoint)point
{
    self = [super init];
    if (self) {
        self.nsPoint = point;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
        return [self initWithNSPoint:NSZeroPoint];
    return self;
}

- (CGFloat)x
{
    return nsPoint.x;
}

- (CGFloat)y
{
    return nsPoint.y;
}

- (BOOL)isEqual:(JMXPoint *)object
{
    if (nsPoint.y == object.y && nsPoint.x == object.x)
        return YES;
    return NO;
}

@end