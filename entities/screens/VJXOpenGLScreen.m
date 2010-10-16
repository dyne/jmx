//
//  VJXOpenGLScreen.m
//  VeeJay
//
//  Created by xant on 9/2/10.
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

#import "VJXOpenGLScreen.h"
#import <QuartzCore/QuartzCore.h>
#import "VJXContext.h"


@interface VJXOpenGLView : NSOpenGLView {
    CIImage *currentFrame;
    CIContext *ciContext;
    NSRecursiveLock *lock;
    CVDisplayLinkRef    displayLink; // the displayLink that runs the show
    CGDirectDisplayID   viewDisplayID;
    uint64_t lastTime;
}

@property (retain) CIImage *currentFrame;

- (void)setSize:(NSSize)size;
- (void)cleanup;
- (void)renderFrame:(uint64_t)timeStamp;

@end

static CVReturn renderCallback(CVDisplayLinkRef displayLink, 
                               const CVTimeStamp *inNow, 
                               const CVTimeStamp *inOutputTime, 
                               CVOptionFlags flagsIn, 
                               CVOptionFlags *flagsOut, 
                               void *displayLinkContext)
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(VJXOpenGLView*)displayLinkContext renderFrame:inNow->hostTime];
    [pool drain];
    return noErr;
}

@implementation VJXOpenGLView

@synthesize currentFrame;

- (id)initWithFrame:(NSRect)frameRect
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 32,
        0
    };
    NSOpenGLPixelFormat* pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
    return [self initWithFrame:frameRect pixelFormat:pixelFormat];
}

- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format
{
    if (self = [super initWithFrame:frameRect pixelFormat:format]) {
        currentFrame = nil;
        ciContext = nil;
        lastTime = 0;
    }
    return self;
}

- (void)prepareOpenGL
{
    if (ciContext == nil) {

        [super prepareOpenGL];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        ciContext = [[CIContext contextWithCGLContext:[[self openGLContext] CGLContextObj]
                                          pixelFormat:[[self pixelFormat] CGLPixelFormatObj]
                                           colorSpace:colorSpace
                                              options:nil] retain];
        CGColorSpaceRelease(colorSpace);

        // Create display link 
        CGOpenGLDisplayMask    totalDisplayMask = 0;
        int            virtualScreen;
        GLint        displayMask;
        NSOpenGLPixelFormat    *openGLPixelFormat = [self pixelFormat];

        [self setNeedsDisplay:YES];
        viewDisplayID = (CGDirectDisplayID)[[[[[self window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];  
        for (virtualScreen = 0; virtualScreen < [openGLPixelFormat  numberOfVirtualScreens]; virtualScreen++)
        {
            [openGLPixelFormat getValues:&displayMask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:virtualScreen];
            totalDisplayMask |= displayMask;
        }
        CVReturn ret = CVDisplayLinkCreateWithCGDisplay(viewDisplayID, &displayLink);
        if (ret != noErr) {
            // TODO - Error Messages
        }
        // Set up display link callbacks 
        CVDisplayLinkSetOutputCallback(displayLink, renderCallback, self);
        CVDisplayLinkStart(displayLink);
        [self setNeedsDisplay:YES];
    }
}

- (void)dealloc
{
    [self cleanup];
    [super dealloc];
}

- (void)renderFrame:(uint64_t)timeStamp
{
    if ((timeStamp-lastTime)/1e9 > 1e9/60)
        return;
    lastTime = timeStamp;
  /*  [[self openGLContext] makeCurrentContext];
    if (CGLLockContext([[self openGLContext] CGLContextObj]) != kCGLNoError)
        NSLog(@"Could not lock CGLContext"); */
    NSRect bounds = [self bounds];
    @synchronized(self) {
        //CIImage *image = [self.currentFrame retain];
        if (self.currentFrame) {
            CGRect screenSizeRect = NSRectToCGRect(bounds);
            [ciContext drawImage:self.currentFrame inRect:screenSizeRect fromRect:screenSizeRect];
        }
        //[image release];
        [[self openGLContext] flushBuffer];
    }
    [self setNeedsDisplay:NO];
 //   CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void)drawRect:(NSRect)rect
{
    //@synchronized(self) {
    //[self renderFrame];
    [self setNeedsDisplay:NO];
    //}
}

// Called by Cocoa when the view's visible rectangle or bounds change.
- (void)reshape
{
    @synchronized(self) {
        NSRect bounds = [self frame];
        
        GLfloat minX, minY, maxX, maxY;
        minX = NSMinX(bounds);
        minY = NSMinY(bounds);
        maxX = NSMaxX(bounds);
        maxY = NSMaxY(bounds);
        [[self openGLContext] makeCurrentContext];
        /*
        if (CGLLockContext([[self openGLContext] CGLContextObj]) != kCGLNoError)
            NSLog(@"Could not lock CGLContext");
        */
        glViewport(0, 0, bounds.size.width, bounds.size.height);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(minX, maxX, minY, maxY, -1.0, 1.0);
        glDisable(GL_DITHER);
        glDisable(GL_ALPHA_TEST);
        glDisable(GL_BLEND);
        glDisable(GL_STENCIL_TEST);
        glDisable(GL_FOG);
        glDisable(GL_DEPTH_TEST);
        glPixelZoom(1.0, 1.0);
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        //CGLUnlockContext([[self openGLContext] CGLContextObj]);
        [[self openGLContext] flushBuffer];
    }
}

- (void)cleanup
{
    if (ciContext) {
        [ciContext release];
        ciContext = nil;
    }
    
    if (lock) {
        [lock release];
        lock = nil;
    }
    self.currentFrame = nil;
}

- (void)setSize:(NSSize)size
{
    //@synchronized(self) {
        NSRect actualRect = [[self window ] frame];
        // XXX - we actually don't allow setting a 0-size (for neither width nor height)
        if (size.width && size.height &&
            (size.width != actualRect.size.width ||
             size.height != actualRect.size.height))
        {
            NSRect newRect = NSMakeRect(0, 0, size.width, size.height);
            [self setFrame:newRect];
            newRect.origin.x = actualRect.origin.x;
            newRect.origin.y = actualRect.origin.y;
            [[self window] setFrame:newRect display:NO];
            [[self window] setMovable:YES]; // XXX - this shouldn't be necessary
            [self setNeedsDisplay:YES]; // triggers reshape
        }
    //}
}

@end

@implementation VJXOpenGLScreen

@synthesize window, view;

- (id)initWithSize:(NSSize)screenSize
{
    if (self = [super initWithSize:screenSize]) {
        NSRect frame = NSMakeRect(0, 0, size.width, size.height);
        window = [[NSWindow alloc] initWithContentRect:frame                                          
                                             styleMask:NSTitledWindowMask|NSMiniaturizableWindowMask
                                               backing:NSBackingStoreBuffered 
                                                 defer:NO];
        view = [[VJXOpenGLView alloc] initWithFrame:[window frame]];
        [[window contentView] addSubview:view];
        [window setReleasedWhenClosed:NO];
        [window setIsVisible:YES];
        //[window orderBack:self];
    }
    return self;
    
}

- (void)dealloc
{
    [view release];
    [window release];
    [super dealloc];
}

- (void)setSize:(VJXSize *)newSize
{
    //@synchronized(self) {
        if (![newSize isEqual:size]) {
            [super setSize:newSize];
            [view setSize:[newSize nsSize]];
        }
    //}
}

- (void)drawFrame:(CIImage *)frame
{
    [super drawFrame:frame];
    //@synchronized(view) {
        view.currentFrame = frame;
    //}
}

@end
