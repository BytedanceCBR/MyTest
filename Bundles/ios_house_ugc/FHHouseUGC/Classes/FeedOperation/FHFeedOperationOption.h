//
//  FHFeedOperationOption.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/16.
//

#import <Foundation/Foundation.h>
#import "FHFeedOperationWord.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHFeedOperationOptionType) {
    FHFeedOperationOptionTypeOther = 0,
    FHFeedOperationOptionTypeReport,
    FHFeedOperationOptionTypeDelete,
    FHFeedOperationOptionTypeTop,
    FHFeedOperationOptionTypeCancelTop,
    FHFeedOperationOptionTypeGood,
    FHFeedOperationOptionTypeCancelGood,
    FHFeedOperationOptionTypeSelfLook,
    FHFeedOperationOptionTypeEdit,
};

@interface FHFeedOperationOption : NSObject

@property (nonatomic) FHFeedOperationOptionType type;
@property (nonatomic, strong) NSArray<FHFeedOperationWord *> *words;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subTitle;

+ (FHFeedOperationOptionType)optionTypeForKeyword:(FHFeedOperationWord *)keyword;

@end

NS_ASSUME_NONNULL_END
