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

@property (nonatomic, strong) FHMessageCell *currentCell;

@property (nonatomic, assign) BOOL isCanReloadData;

@property (nonatomic, strong) IMConversation *conversation;

+ (instancetype)shared;

+ (void)close;

+ (void)clear;

@end

