//
//  JMXWindowController.m
//  JMX
//
//  Created by Igor Sutton on 11/14/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import "JMXWindowController.h"
#import "JMXBoardViewController.h"

@implementation JMXWindowController

@synthesize documentSplitView;
@synthesize boardViewController;

#pragma mark -
#pragma mark NSWindowController

- (void)windowDidLoad
{
	[documentSplitView setPosition:200.0f ofDividerAtIndex:0];
	[documentSplitView adjustSubviews];	
}

#pragma mark -
#pragma mark Interface Builder actions

- (IBAction)toggleInspector:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	if ([inspectorPanel isVisible]) {
        [inspectorPanel close];
		[menuItem setTitle:@"Show Inspector"];
	}
	else {
        [inspectorPanel setIsVisible:YES];
        [inspectorPanel makeKeyAndOrderFront:sender];
		[menuItem setTitle:@"Hide Inspector"];
	}
}

- (IBAction)toggleLibrary:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	if ([documentSplitView isSubviewCollapsed:libraryView]) {
		[libraryView setHidden:NO];
		[documentSplitView adjustSubviews];
		[documentSplitView setPosition:200.0f ofDividerAtIndex:0];
		[menuItem setTitle:@"Hide Library"];
	}
	else {
		[libraryView setHidden:YES];
		[documentSplitView adjustSubviews];
		[menuItem setTitle:@"Show Library"];
	}
	
}

#pragma mark -

- (void)setBoardViewController:(NSViewController *)vc
{
	if (boardViewController != vc)
		[boardViewController release];
	
	boardViewController = [vc retain];
	
	if (boardViewController) {
		[(JMXBoardViewController *)boardViewController setDocument:[self document]];
	}	
}

@end
