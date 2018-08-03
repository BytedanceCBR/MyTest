//
//  TTDislikeActivity.h
//  Pods
//
//  Created by 王双华 on 2017/8/24.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTDislikeContentItem.h"

@interface TTDislikeActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTDislikeContentItem *contentItem;

@end
