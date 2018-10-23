//
//  TTEditActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTMessageContentItem.h"

@interface TTMessageActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTMessageContentItem *contentItem;

@end
