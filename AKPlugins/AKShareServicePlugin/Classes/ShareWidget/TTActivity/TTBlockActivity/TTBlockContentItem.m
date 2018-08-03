//
//  TTBlockContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTBlockContentItem.h"
#import "TTBlockActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityContentItemTypeBlock = @"com.toutiao.ActivityContentItem.Block";

@interface TTBlockContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTBlockContentItem

+ (void)initialize {
    if (self == [TTBlockContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTBlockActivity new]];
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
    return TTActivityContentItemTypeBlock;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
