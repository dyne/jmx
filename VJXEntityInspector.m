//
//  VJXEntityInspector.m
//  VeeJay
//
//  Created by xant on 9/11/10.
//  Copyright 2010 Dyne.org. All rights reserved.
//

#import "VJXEntityInspector.h"
#import "VJXBoardDelegate.h"

@interface VJXEntityInspector (Private)
- (void)setEntity:(VJXBoardEntity *)entity;
@end

@implementation VJXEntityInspector

static VJXEntityInspector *inspector = nil;

@synthesize entityView, panel;

+ (void)setPanel:(VJXEntityInspectorPanel *)aPanel
{
    if (!inspector)
        inspector = [[VJXEntityInspector alloc] init];
    inspector.panel = aPanel;

}

+ (void)unsetEntity:(VJXBoardEntity *)entity
{
    if (inspector.entityView == entity)
        inspector.entityView = nil;
}

+ (void)setEntity:(VJXBoardEntity *)entity
{
    if (!inspector)
        inspector = [[VJXEntityInspector alloc] init];
    if (![inspector.panel isVisible])
        [inspector.panel setIsVisible:YES];
    // we will maintain a weak reference, the entity itself 
    // should take care of unsetting the inspectorpanel before being destroyed
    [inspector setEntity:entity];
}

- (void)setEntity:(VJXBoardEntity *)boardEntity
{
    entityView = boardEntity;
    inputPins = panel.inputPins;
    outputPins = panel.outputPins;
    producers = panel.producers;
    //[inputPins setDataSource:inspector];
    if ([inputPins dataSource] != self) {
        [inputPins setDataSource:self];
        [inputPins setDelegate:self];
    }
    [inputPins reloadData];
    if ([outputPins dataSource] != self) {
        [outputPins setDataSource:self];
        [outputPins setDelegate:self];
    }
    [outputPins reloadData];
    if ([producers dataSource] != self) {
        [producers setDataSource:self];
        [producers setDelegate:self];
        [producers registerForDraggedTypes:[NSArray arrayWithObject:@"PinRowIndex"]];

    }
    [producers reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSInteger count = 0;
    if (aTableView == inputPins) {
        count = [entityView.entity.inputPins count];
    } else if (aTableView == outputPins) {
        count = [entityView.entity.outputPins count];
    } else if (aTableView == producers) {
        NSInteger selectedRow = [inputPins selectedRow];
        if (selectedRow >= 0) {
            NSArray *pins = [[entityView.entity.inputPins allKeys]
                             sortedArrayUsingComparator:^(id obj1, id obj2)
                             {
                                 return [obj1 compare:obj2];
                             }];
            NSString *pinName = [pins objectAtIndex:selectedRow];
            VJXPin *pin = [entityView.entity inputPinWithName:pinName];
            return [pin.producers count];
        }
    }
    return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{ 
    if (aTableView == inputPins) {
        NSArray *pins = [[entityView.entity.inputPins allKeys]
                            sortedArrayUsingComparator:^(id obj1, id obj2)
                                                        {
                                                            return [obj1 compare:obj2];
                                                        }];
        
        if ([[aTableColumn identifier] isEqualTo:@"pinName"])
            return [pins objectAtIndex:rowIndex];
        else
            return [[entityView.entity.inputPins objectForKey:[pins objectAtIndex:rowIndex]] typeName];
    } else if (aTableView == outputPins) {
        NSArray *pins = [[entityView.entity.outputPins allKeys]
                         sortedArrayUsingComparator:^(id obj1, id obj2)
                                                     {
                                                         return [obj1 compare:obj2];
                                                     }];
        if ([[aTableColumn identifier] isEqualTo:@"pinName"])
            return [pins objectAtIndex:rowIndex];
        else
            return [[entityView.entity.outputPins objectForKey:[pins objectAtIndex:rowIndex]] typeName];        
    } else if (aTableView == producers) {
        NSInteger selectedRow = [inputPins selectedRow];
        if (selectedRow >= 0) {
            NSArray *pins = [[entityView.entity.inputPins allKeys]
                             sortedArrayUsingComparator:^(id obj1, id obj2)
                                                         {
                                                             return [obj1 compare:obj2];
                                                         }];
            NSString *pinName = [pins objectAtIndex:selectedRow];
            VJXPin *pin = [entityView.entity inputPinWithName:pinName];
            return [NSString stringWithFormat:@"%@",[pin.producers objectAtIndex:rowIndex]];
        }
    }
    return nil;
}
                                 
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *aTableView =[notification object];
    // at the moment we are interested only in selection among inputPins
    if (aTableView == inputPins)
        [producers reloadData];
}


- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return false; // we don't allow editing items for now
}

- (NSArray *)tableView:(NSTableView *)aTableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination 
                                                                forDraggedRowsWithIndexes:(NSIndexSet *)indexSet
{
    if (aTableView != producers)
        return nil;
    return [NSArray arrayWithObjects:@"PinRowIndex", nil];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    if (aTableView != producers)
        return NO;
    
    NSUInteger row = [rowIndexes firstIndex];
    [pboard addTypes:[NSArray arrayWithObjects:@"PinRowIndex", nil] owner:(id)self];
    [pboard setData:[NSData dataWithBytes:&row length:sizeof(NSUInteger)] forType:@"PinRowIndex"];
    return YES;
}


- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row 
                                                                                      proposedDropOperation:(NSTableViewDropOperation)operation
{
    NSDragOperation dragOp = NSDragOperationMove;
    [aTableView setDropRow: row
             dropOperation: NSTableViewDropAbove];   
    return dragOp;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    if (aTableView != producers)
        return NO;
    NSInteger srcRow = -1;
    [[[info draggingPasteboard] dataForType:@"PinRowIndex"] getBytes:&srcRow length:sizeof(NSUInteger)];
    if (srcRow >= 0) {
        NSInteger selectedRow = [inputPins selectedRow];
        if (selectedRow >= 0) {
            NSArray *pins = [[entityView.entity.inputPins allKeys]
                             sortedArrayUsingComparator:^(id obj1, id obj2)
                             {
                                 return [obj1 compare:obj2];
                             }];
            NSString *pinName = [pins objectAtIndex:selectedRow];
            VJXPin *pin = [entityView.entity inputPinWithName:pinName];
            if ([pin moveProducerFromIndex:(NSUInteger)srcRow toIndex:(NSUInteger)(srcRow < row)?row-1:row]) {
                [aTableView reloadData];
                return YES;
            }
        }
    }
    return NO;
}

@end
