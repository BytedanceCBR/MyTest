//
//  TTEditActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTEditContentItem.h"

@interface TTEditActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTEditContentItem *contentItem;

@end
