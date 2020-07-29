//
//  FHMessageEditHelp.h
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/28.
//

#import <Foundation/Foundation.h>
#import "FHMessageCell.h"

@interface FHMessageEditHelp : NSObject

@property (weak, nonatomic) FHMessageCell *currentCell;

+ (instancetype)shared;

+ (void)close;

@end

