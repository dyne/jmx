//
//  VJXAudioFileLayer.h
//  VeeJay
//
//  Created by xant on 9/26/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//
//  This file is part of VeeJay
//
//  VeeJay is free software: you can redistribute it and/or modify
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
//  along with VeeJay.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import "VJXThreadedEntity.h"
#import "VJXFileRead.h"

@class VJXAudioFile;
@class VJXAudioDevice;

@interface VJXAudioFileLayer : VJXThreadedEntity < VJXFileRead > {
@private
    VJXAudioFile *audioFile;
    VJXAudioBuffer *currentSample;
    VJXOutputPin *outputPin;
    NSMutableArray *samples;
    BOOL repeat; // defaults to YES
    NSUInteger offset;
    VJXAudioDevice *device; // used to obtain the clock
    BOOL useAggregateDevice; // defaults to NO
}

@property (readwrite) BOOL repeat;
@property (readwrite) BOOL useAggregateDevice;
- (void)doRepeat:(id)value; // input pin setter (we will receive NSNumbers from pins)
@end
