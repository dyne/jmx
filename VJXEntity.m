//
//  VJXObject.m
//  VeeJay
//
//  Created by xant on 9/1/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import "VJXEntity.h"


@implementation VJXEntity

- (id)init
{
    if (self = [super init]) {
        inputPins = [[NSMutableArray alloc] init];
        outputPins = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [inputPins release];
    [outputPins release];
    [super dealloc];
}

- (void)defaultInputCallback:(id)inputData
{
    
}

- (void)defaultOuputCallback:(id)outputData
{
}

- (void)registerInputPin:(NSString *)pinName withType:(VJXPinType)pinType
{
    [self registerInputPin:pinName withType:pinType andSelector:@"defaultInputCallback:"];
}

- (void)registerInputPin:(NSString *)pinName withType:(VJXPinType)pinType andSelector:(NSString *)selector
{
    [inputPins addObject:[VJXPin pinWithName:pinName andType:pinType forObject:self withSelector:selector]];
}

- (void)registerOutputPin:(NSString *)pinName withType:(VJXPinType)pinType
{
    [self registerOutputPin:pinName withType:pinType andSelector:@"defaultOutputCallback:"];
}

- (void)registerOutputPin:(NSString *)pinName withType:(VJXPinType)pinType andSelector:(NSString *)selector
{
    [outputPins addObject:[VJXPin pinWithName:pinName andType:pinType forObject:self withSelector:selector]];
}

- (void)signalOutput:(id)data
{
    
}

- (id)copyWithZone:(NSZone *)zone
{
    // we don't want copies, but we want to use such objects as keys of a dictionary
    // so we still need to conform to the 'copying' protocol
    return self;
}

@synthesize inputPins, outputPins, name;
@end
