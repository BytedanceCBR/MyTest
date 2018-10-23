//
//  TTReportContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTReportContentItem.h"

NSString * const TTActivityContentItemTypeReport         =
@"com.toutiao.ActivityContentItem.Report";

@implementation TTReportContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeReport;
}

@end
