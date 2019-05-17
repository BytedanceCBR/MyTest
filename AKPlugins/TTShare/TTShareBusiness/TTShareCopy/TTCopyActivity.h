//
//  TTCopyActivity.h
//  NeteaseLottery
//
//  Created by 延晋 张 on 16/6/7.
//
//

#import "TTActivityProtocol.h"
#import "TTCopyContentItem.h"

extern NSString * const TTActivityTypePostToCopy;

@interface TTCopyActivity : NSObject <TTActivityProtocol>

@property (nonatomic,strong) TTCopyContentItem *contentItem;

@end
