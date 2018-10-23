//
//  GAButtonGroup.h
//  MyFM
//
//  Created by Dianwei Hu on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAToggleButton.h"

@class GAButtonGroup;
@protocol GAButtonGroupDelegate

- (void)buttonGroup:(GAButtonGroup*)group selectedIndex:(NSNumber*)index;

@end

@interface GAButtonGroup : NSObject<GAToggleButtonDelegate>{
}

@property(nonatomic, weak)NSObject<GAButtonGroupDelegate> *delegate;

- (void)addButton:(GAToggleButton*)button withIndex:(int)index;
- (void)setToggleAtIndex:(int)buttonIndex performDelegate:(BOOL)perform;
@end
