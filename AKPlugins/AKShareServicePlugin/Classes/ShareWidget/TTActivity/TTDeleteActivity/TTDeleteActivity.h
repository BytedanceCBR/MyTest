//
//  TTDeleteActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTDeleteContentItem.h"

@interface TTDeleteActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTDeleteContentItem *contentItem;

@end
