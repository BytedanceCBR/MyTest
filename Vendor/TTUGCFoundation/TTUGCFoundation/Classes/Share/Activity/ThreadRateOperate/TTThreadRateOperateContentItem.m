//
//  TTThreadRateOperateContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTThreadRateOperateContentItem.h"
#import "TTThreadRateOperateActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityContentItemTypeThreadRateOperate = @"com.toutiao.ActivityContentItem.ThreadRateOperate";

@interface TTThreadRateOperateContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTThreadRateOperateContentItem

+ (void)initialize {
    if (self == [TTThreadRateOperateContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTThreadRateOperateActivity new]];
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
    return TTActivityContentItemTypeThreadRateOperate;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
