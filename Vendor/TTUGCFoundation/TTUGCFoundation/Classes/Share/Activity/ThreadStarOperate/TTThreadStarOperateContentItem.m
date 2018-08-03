//
//  TTThreadStarOperateContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import "TTThreadStarOperateContentItem.h"
#import <TTShareManager.h>
#import "TTThreadStarOperateActivity.h"

NSString * const TTActivityContentItemTypeThreadStarOperate = @"com.toutiao.ActivityContentItem.ThreadStarOperate";

@interface TTThreadStarOperateContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTThreadStarOperateContentItem

+ (void)initialize {
    if (self == [TTThreadStarOperateContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTThreadStarOperateActivity new]];
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
    return TTActivityContentItemTypeThreadStarOperate;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
