//
//  GAButtonGroup.m
//  MyFM
//
//  Created by Dianwei Hu on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GAButtonGroup.h"

@interface GAButtonGroup(){
@private
    NSMutableDictionary *buttonDict;
}

@property(nonatomic, retain)NSMutableDictionary *buttonDict;
@end

@implementation GAButtonGroup
@synthesize buttonDict, delegate;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.buttonDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addButton:(GAToggleButton*)button withIndex:(int)index
{
    [buttonDict setObject:button forKey:[NSNumber numberWithInt:index]];
    button.toggleDelegate = self;
}

- (void)toggleButtonValueChanged:(GAToggleButton*)button
{
    NSNumber *selectedIndex = nil;
    if(button.toggleStatus == GAToggleButtonStatusToggleOff)
    {
        [button setToggleStatus:GAToggleButtonStatusToggleOn];
    }
    else
    {
        for(NSNumber *indexNumber in [buttonDict allKeys])
        {
            GAToggleButton *tButton = [buttonDict objectForKey:indexNumber];
            if(tButton == button)
            {
                selectedIndex = indexNumber;
                [tButton setToggleStatus:GAToggleButtonStatusToggleOn];
            }
            else
            {
                [tButton setToggleStatus:GAToggleButtonStatusToggleOff];
            }
        }
        
        if(delegate)
        {
            [delegate performSelector:@selector(buttonGroup:selectedIndex:) withObject:self withObject:selectedIndex];
        }
    }
}

- (void)setToggleAtIndex:(int)buttonIndex performDelegate:(BOOL)perform
{
    for(NSNumber *indexNumber in [buttonDict allKeys])
    {
        GAToggleButton *tButton = [buttonDict objectForKey:indexNumber];
        if([indexNumber intValue] == buttonIndex)
        {
            [tButton setToggleStatus:GAToggleButtonStatusToggleOn];
        }
        else
        {
            [tButton setToggleStatus:GAToggleButtonStatusToggleOff];
        }
    }
    
    if(perform)
    {
        if(delegate)
        {
            [delegate performSelector:@selector(buttonGroup:selectedIndex:) withObject:self withObject:[NSNumber numberWithInt:buttonIndex]];
        }
    }
}


@end
