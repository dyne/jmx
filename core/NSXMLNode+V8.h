//
//  NSXMLNode+V8.h
//  JMX
//
//  Created by xant on 1/4/11.
//  Copyright 2011 Dyne.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JMXV8.h"

#ifdef __JMXV8__
#import "NSXMLNode+V8.h"
#import "JMXScript.h"

/*!
 @define JMXV8_EXPORT_NODE_CLASS
 @abstract define both the constructor and the descructor for the mapped class
 @param __class
 */
#define JMXV8_EXPORT_NODE_CLASS(__class) \
    JMXV8_EXPORT_PERSISTENT_CLASS(__class)

/*!
 @define JMXV8_DECLARE_NODE_CONSTRUCTOR
 @abstract define the constructor for the mapped class
 @param __class
 */
#define JMXV8_DECLARE_NODE_CONSTRUCTOR(__class)\
    JMXV8_DECLARE_CONSTRUCTOR(__class)

#else

#define JMXV8_EXPORT_NODE_CLASS(__class)

#define JMXV8_DECLARE_NODE_CONSTRUCTOR(__class)

#endif

@interface NSXMLNode (JMXV8) <JMXV8>

- (id)jmxInit;
- (id)jmxInit:(id)arg;
- (NSString *)hashString;

JMXV8_DECLARE_NODE_CONSTRUCTOR(NSXMLNode);
@end
