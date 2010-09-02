//
//  MoviePlayerOpenGLView.h
//  MoviePlayerC
//
//  Created by Igor Sutton on 8/5/10.
//  Copyright (c) 2010 StrayDev.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>
#import <QTKit/QTKit.h>
#import <OpenGL/OpenGL.h>
#import "VJXController.h"

@interface VJXOpenGLView : NSOpenGLView {
    CIImage *currentFrame;
    CIContext *ciContext;
    NSRecursiveLock *lock;

    BOOL needsReShape;

    IBOutlet VJXController *vjController;
}

- (void)tick;

@end