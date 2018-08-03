//
//  TTReportUserContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTReportUserContentItem.h"
#import <TTShareManager.h>
#import "TTReportUserActivity.h"

NSString * const TTActivityContentItemTypeReportUser = @"com.toutiao.ActivityContentItem.ReportUser";

@interface TTReportUserContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTReportUserContentItem

+ (void)initialize {
    if (self == [TTReportUserContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTReportUserActivity new]];
    }
}


- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName {
    self = [super init];
    _title = [title copy];
    _imageName = [imageName copy];
    return self;
}

- (instancetype)init {
    self = [self initWithTitle:@"" imageName:@""];
    return self;
}

- (NSString *)contentItemType {
    return TTActivityContentItemTypeReportUser;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
