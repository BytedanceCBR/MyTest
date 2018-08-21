//
//  TTThreadOnlyOperateContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTThreadOnlyOperateContentItem.h"
#import "TTThreadOnlyOperateActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityContentItemTypeThreadOnlyOperate = @"com.toutiao.ActivityContentItem.ThreadOnlyOperate";

@interface TTThreadOnlyOperateContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTThreadOnlyOperateContentItem

+ (void)initialize {
    if (self == [TTThreadOnlyOperateContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTThreadOnlyOperateActivity new]];
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
    return TTActivityContentItemTypeThreadOnlyOperate;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
