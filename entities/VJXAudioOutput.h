//
//  VJXAudioOutput.h
//  VeeJay
//
//  Created by xant on 9/14/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VJXEntity.h"

@class VJXAudioBuffer;

@interface VJXAudioOutput : VJXEntity {
    VJXAudioBuffer *currentSample;
}


@end