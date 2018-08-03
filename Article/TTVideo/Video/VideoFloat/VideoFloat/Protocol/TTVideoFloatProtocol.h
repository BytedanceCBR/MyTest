//
//  TTVideoFloatProtocol.h
//  skin
//
//  Created by panxiang on 15/10/11.
//  Copyright © 2015年 panxiang. All rights reserved.
//

#import <Foundation/Foundation.h>


static BOOL canRemovMovie = YES;

static NSString *kFloatVideoCellBackgroundColor = @"0x1b1b1b";
static NSString *kVideoFloatTrackEvent = @"video_float";

typedef NS_ENUM(NSUInteger, TTVideoFloatCellAction) {
    TTVideoFloatCellAction_Subscribe,
    TTVideoFloatCellAction_unSubscribe,
    TTVideoFloatCellAction_Comment,
    TTVideoFloatCellAction_Digg,
    TTVideoFloatCellAction_Bury,
    TTVideoFloatCellAction_Share,
    TTVideoFloatCellAction_UserInfo,
    TTVideoFloatCellAction_Play
};


@protocol TTVideoFloatProtocol <NSObject>


@end

@protocol TTStatusButtonDelegate <NSObject>

- (void)statusButtonHighlighted:(BOOL)highlighted;

@end
