//
//  TTCommentStatContentItem.h
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"

typedef NS_ENUM(NSUInteger, TTCommentStat) {
    TTCommentStatForbid,
    TTCommentStatAllow,
};
extern NSString * const TTActivityContentItemTypeCommentStat;

@interface TTCommentStatContentItem : NSObject <TTActivityContentItemProtocol>

@property (nonatomic, assign) TTCommentStat stat;
@property (nonatomic, copy) TTCustomAction customAction;

@end
