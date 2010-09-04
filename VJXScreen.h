//
//  VJXScreen.h
//  VeeJay
//
//  Created by xant on 9/2/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VJXEntity.h"

@interface VJXScreen : VJXEntity {
@protected
    CIImage *currentFrame;
    NSSize size;
}

- (id)initWithSize:(NSSize)screenSize;
- (void)outputFrame:(CIImage *)frame;

@end