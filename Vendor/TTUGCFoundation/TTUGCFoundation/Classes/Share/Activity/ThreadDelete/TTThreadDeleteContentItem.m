//
//  TTThreadDeleteContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTThreadDeleteContentItem.h"
#import "TTThreadDeleteActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityContentItemTypeThreadDelete = @"com.toutiao.ActivityContentItem.ThreadDelete";

@interface TTThreadDeleteContentItem ()

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * imageName;

@end

@implementation TTThreadDeleteContentItem

+ (void)initialize {
    if (self == [TTThreadDeleteContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTThreadDeleteActivity new]];
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
    return TTActivityContentItemTypeThreadDelete;
}

- (NSString *)contentTitle {
    return self.title;
}

- (NSString *)activityImageName {
    return self.imageName;
}

@end
