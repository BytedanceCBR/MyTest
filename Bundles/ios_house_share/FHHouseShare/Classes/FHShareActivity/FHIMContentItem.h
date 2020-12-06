//
//  FHIMContentItem.h
//  FHHouseShare
//
//  Created by bytedance on 2020/11/9.
//

#import "BDUGShareBaseContentItem.h"

@class FHDetailImShareInfoModel;
NS_ASSUME_NONNULL_BEGIN

static NSString * const FHActivityContentItemTypeIM = @"com.f100.ActivityContentItem.IM";

@interface FHIMContentItem : BDUGShareBaseContentItem

@property (nonatomic,strong) FHDetailImShareInfoModel* imShareInfo;
@property (nonatomic,strong) NSDictionary* tracer;
@property (nonatomic, strong) NSDictionary *extraInfo;

@end

@interface FHShareIMDataModel : NSObject

@property (nonatomic,strong) FHDetailImShareInfoModel* imShareInfo;
@property (nonatomic,strong) NSDictionary* tracer;
@property (nonatomic, strong) NSDictionary *extraInfo;

@end
NS_ASSUME_NONNULL_END
