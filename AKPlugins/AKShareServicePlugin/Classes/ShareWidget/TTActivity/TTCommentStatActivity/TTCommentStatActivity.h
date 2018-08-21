//
//  TTCommentStatActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTCommentStatContentItem.h"

@interface TTCommentStatActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTCommentStatContentItem *contentItem;

@end
