//
//  TTReportActivity.h
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"
#import "TTReportContentItem.h"

@interface TTReportActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTReportContentItem *contentItem;

@end
