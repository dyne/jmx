//
//  VJXBoard.h
//  GraphRep
//
//  Created by Igor Sutton on 8/26/10.
//  Copyright 2010 StrayDev.com. All rights reserved.
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
#import "VJXBoardEntity.h"
#import "VJXBoardSelection.h"

@interface VJXBoard : NSView {
    NSPoint lastDragLocation;
    VJXBoardSelection *currentSelection;
    NSMutableArray *entities;
    NSMutableArray *selectedEntities;
}

@property (nonatomic,retain) VJXBoardSelection *currentSelection;
@property (nonatomic,retain) NSMutableArray *entities;

+ (VJXBoard *)sharedBoard;
+ (void)setSharedBoard:(VJXBoard *)aBoard;
- (void)setSelected:(VJXBoardEntity *)theEntity multiple:(BOOL)isMultiple;

+ (void)shiftSelectedToLocation:(NSPoint)aLocation;
- (void)shiftSelectedToLocation:(NSPoint)aLocation;

- (BOOL)hasMultipleEntitiesSelected;

- (void)removeSelectedEntities;
- (void)addToBoard:(VJXBoardEntity *)theEntity;

@end
