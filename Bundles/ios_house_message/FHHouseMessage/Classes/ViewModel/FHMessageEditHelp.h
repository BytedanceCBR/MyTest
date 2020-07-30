//
//  FHMessageEditHelp.h
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/28.
//

#import <Foundation/Foundation.h>
#import "FHMessageCell.h"

@class IMConversation;
@interface FHMessageEditHelp : NSObject

@property (nonatomic, weak) FHMessageCell *currentCell;

@property (nonatomic, assign) BOOL isCanReloadData;

@property (nonatomic, weak) IMConversation *conversation;

+ (instancetype)shared;

+ (void)close;

@end

