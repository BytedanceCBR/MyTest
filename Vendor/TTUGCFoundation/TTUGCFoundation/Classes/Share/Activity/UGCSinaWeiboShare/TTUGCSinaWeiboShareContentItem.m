//
//  TTUGCSinaWeiboShareContentItem.m
//  Article
//
//  Created by 王霖 on 17/2/28.
//
//

#import "TTUGCSinaWeiboShareContentItem.h"
#import "TTUGCSinaWeiboShareActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityContentItemTypeUGCSinaWeiboShare = @"com.toutiao.ActivityContentItem.UGCSinaWeiboShare";

@interface TTUGCSinaWeiboShareContentItem()

@property (nonatomic, copy, readwrite) NSString * uniqueID;
@property (nonatomic, copy, readwrite) NSString * shareText;
@property (nonatomic, assign, readwrite) TTUGCShareSourceType shareSourceType;

@end

@implementation TTUGCSinaWeiboShareContentItem

+ (void)initialize {
    if (self == [TTUGCSinaWeiboShareContentItem class]) {
        [TTShareManager addUserDefinedActivity:[TTUGCSinaWeiboShareActivity new]];
    }
}

- (NSString *)contentItemType {
    return TTActivityContentItemTypeUGCSinaWeiboShare;
}

- (instancetype)initWithUniqueID:(NSString *)uniqueID
                       shareText:(nullable NSString *)shareText
                 shareSourceType:(TTUGCShareSourceType)shareSourceType {
    self = [super init];
    if (self) {
        _uniqueID = uniqueID.copy;
        _shareText = shareText.copy;
        _shareSourceType = shareSourceType;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithUniqueID:@"" shareText:nil shareSourceType:TTUGCShareSourceTypeConcern];
    return self;
}

@end
