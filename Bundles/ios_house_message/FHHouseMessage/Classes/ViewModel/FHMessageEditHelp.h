//
//  FHMessageEditHelp.h
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/28.
//

#import <Foundation/Foundation.h>
#import "FHMessageCell.h"

@interface FHMessageEditHelp : NSObject

@property (nonatomic, weak) FHMessageCell *currentCell;

@property (nonatomic, assign) BOOL isCanReloadData;

+ (instancetype)shared;

+ (void)close;

@end

