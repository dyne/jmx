//
//  JMXVideoEntity.m
//  JMX
//
//  Created by Igor Sutton on 8/24/10.
//  Copyright 2010 StrayDev.com. All rights reserved.
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

#define __JMXV8__ 1
#import "JMXVideoEntity.h"
#import <QuartzCore/QuartzCore.h>
#import "JMXScript.h"

using namespace v8;

@implementation JMXVideoEntity

@synthesize alpha, saturation, brightness, contrast, rotation,
            origin, size, scaleRatio, fps;

- (id)init
{
    self = [super init];
    if (self) {
        currentFrame = nil;
        name = @"";
        colorFilter = [[CIFilter filterWithName:@"CIColorControls"] retain];
        [colorFilter setDefaults];
        NSDictionary *filterAttributes = [colorFilter attributes];
        NSSize defaultLayerSize = { 640, 480 };
        self.size = [JMXSize sizeWithNSSize:defaultLayerSize];
        self.saturation = [colorFilter valueForKey:@"inputSaturation"];
        self.brightness = [colorFilter valueForKey:@"inputBrightness"];
        self.contrast = [colorFilter valueForKey:@"inputContrast"];
        self.alpha = [NSNumber numberWithFloat:1.0];
        self.rotation = [NSNumber numberWithFloat:1.0];
        self.scaleRatio = [NSNumber numberWithFloat:1.0];
        NSPoint zeroPoint = { 0, 0 };
        self.origin = [JMXPoint pointWithNSPoint:zeroPoint];
        [self registerInputPin:@"name" withType:kJMXStringPin andSelector:@"setName:" ];
        JMXInputPin *inputPin;
        inputPin = [self registerInputPin:@"alpha"
                                 withType:kJMXNumberPin
                              andSelector:@"setAlpha:"
                            allowedValues:nil
                            initialValue:self.alpha];
        [inputPin addMinLimit:[NSNumber numberWithFloat:0.0]];
        [inputPin addMaxLimit:[NSNumber numberWithFloat:2.0]];
        inputPin = [self registerInputPin:@"saturation"
                                  withType:kJMXNumberPin
                               andSelector:@"setSaturation:"
                             allowedValues:nil
                             initialValue:self.saturation];
        [inputPin addMinLimit:[[filterAttributes objectForKey:@"inputSaturation"] objectForKey:@"CIAttributeSliderMin"]];
        [inputPin addMaxLimit:[[filterAttributes objectForKey:@"inputSaturation"] objectForKey:@"CIAttributeSliderMax"]];
        inputPin = [self registerInputPin:@"brightness"
                                 withType:kJMXNumberPin
                              andSelector:@"setBrightness:"
                            allowedValues:nil
                            initialValue:self.brightness];
        [inputPin addMinLimit:[[filterAttributes objectForKey:@"inputBrightness"] objectForKey:@"CIAttributeSliderMin"]];
        [inputPin addMaxLimit:[[filterAttributes objectForKey:@"inputBrightness"] objectForKey:@"CIAttributeSliderMax"]];
        inputPin = [self registerInputPin:@"contrast" 
                                 withType:kJMXNumberPin
                              andSelector:@"setContrast:"
                            allowedValues:nil
                             initialValue:self.contrast];
        [inputPin addMinLimit:[[filterAttributes objectForKey:@"inputContrast"] objectForKey:@"CIAttributeSliderMin"]];
        [inputPin addMaxLimit:[[filterAttributes objectForKey:@"inputContrast"] objectForKey:@"CIAttributeSliderMax"]];
        inputPin = [self registerInputPin:@"rotation"
                                 withType:kJMXNumberPin
                              andSelector:@"setRotation:"
                            allowedValues:nil
                             initialValue:self.rotation];
        [inputPin addMinLimit:[NSNumber numberWithFloat:0.0]];
        [inputPin addMaxLimit:[NSNumber numberWithFloat:360.0]];
        inputPin = [self registerInputPin:@"scaleRatio"
                                 withType:kJMXNumberPin
                              andSelector:@"setScaleRatio:"
                            allowedValues:nil
                             initialValue:[NSNumber numberWithFloat:1.0]];
        [inputPin addMinLimit:[NSNumber numberWithFloat:0.0]];
        [inputPin addMaxLimit:[NSNumber numberWithFloat:100.0]];
        [self registerInputPin:@"origin"
                      withType:kJMXPointPin
                   andSelector:@"setOrigin:"
                 allowedValues:nil
                  initialValue:self.origin];
        [self registerInputPin:@"frameSize"
                      withType:kJMXSizePin
                   andSelector:@"setSize:"
                 allowedValues:nil
                  initialValue:self.size];

        // we output at least 1 image
        outputFramePin = [self registerOutputPin:@"frame" withType:kJMXImagePin];
        outputFrameSizePin = [self registerOutputPin:@"frameSize" withType:kJMXSizePin];
        [outputFrameSizePin setContinuous:NO];
        [outputFrameSizePin allowMultipleConnections:YES];
    }
    return self;
}

- (void)dealloc
{
    if (currentFrame)
        [currentFrame release];
    if (colorFilter)
        [colorFilter release];
    self.size = nil;
    [super dealloc];
}

- (void)tick:(uint64_t)timeStamp
{
    @synchronized(self) {
        if (currentFrame) {
            // Apply image parameters

            // ensure using accessors (by calling self.property) since they will take care of locking
            [colorFilter setValue:self.saturation forKey:@"inputSaturation"];
            [colorFilter setValue:self.brightness forKey:@"inputBrightness"];
            [colorFilter setValue:self.contrast forKey:@"inputContrast"];
            [colorFilter setValue:self.currentFrame forKey:@"inputImage"];
            // scale the image to fit the configured layer size
            CIImage *frame = [colorFilter valueForKey:@"outputImage"];
            
            // frame should be produced with the correct size already by the layer implementation
            // but if the user requested a size impossible to be produced by the source, 
            // we scale it here to honor user request for a specific size
            CGRect imageRect = [frame extent];
            // and scale the frame if necessary
            if (size.width != imageRect.size.width || size.height != imageRect.size.height) {
                CIFilter *scaleFilter = [CIFilter filterWithName:@"CIAffineTransform"];
                float xScale = size.width / imageRect.size.width;
                float yScale = size.height / imageRect.size.height;
                // TODO - take scaleRatio into account for further scaling requested by the user
                NSAffineTransform *transform = [NSAffineTransform transform];
                [transform scaleXBy:xScale yBy:yScale];
                [scaleFilter setDefaults];
                [scaleFilter setValue:transform forKey:@"inputTransform"];
                [scaleFilter setValue:frame forKey:@"inputImage"];
                frame = [scaleFilter valueForKey:@"outputImage"];
            }
            if (frame) {
                [currentFrame release];
                currentFrame = [frame retain];
            }
            // TODO - compute the effective fps and send it to an output pin 
            //        for debugging purposes
        }
    }
    [outputFramePin deliverData:currentFrame fromSender:self];
    [outputFrameSizePin deliverData:size];
}

- (CIImage *)currentFrame
{   
    @synchronized(self) {
        if (currentFrame) {
            CIImage *frame = [currentFrame retain];
            return [frame autorelease];
        }
    }
    return nil;
}

#pragma mark V8

+ (v8::Persistent<v8::FunctionTemplate>)jsClassTemplate
{
    NSLog(@"JMXVideoEntity ClassTemplate created");
    v8::Persistent<v8::FunctionTemplate> entityTemplate = v8::Persistent<FunctionTemplate>::New(FunctionTemplate::New());
    entityTemplate->Inherit([super jsClassTemplate]);
    // accessors to image parameters
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("saturation"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("brightness"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("contrast"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("alpha"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("rotation"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("scaleRatio"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("fps"), GetNumberProperty, SetNumberProperty);
    entityTemplate->InstanceTemplate()->SetAccessor(String::NewSymbol("saturation"), GetNumberProperty, SetNumberProperty);
    return entityTemplate;
}

@end
