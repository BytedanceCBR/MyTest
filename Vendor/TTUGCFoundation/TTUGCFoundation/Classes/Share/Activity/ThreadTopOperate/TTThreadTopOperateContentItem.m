//
//  TTThreadTopOperateContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import "TTThreadTopOperateContentItem.h"
#import <TTShareManager.h>
#import "TTThreadTopOperateActivity.h"

NSString * const TTActivityContentItemTypeThreadTopOperate = @"com.toutiao.ActivityContentItem.ThreadTopOperate";

@interface TTThreadTopOperateContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTThreadTopOperateContentItem

+ (void)initialize {
    if (self == [TTThreadTopOperateContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTThreadTopOperateActivity new]];
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
    return TTActivityContentItemTypeThreadTopOperate;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
