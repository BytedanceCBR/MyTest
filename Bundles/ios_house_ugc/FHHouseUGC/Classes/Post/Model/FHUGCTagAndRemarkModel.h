//
//  FHUGCTagAndRemarkModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/2/26.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHUGCTagModel <NSObject>
@end
@interface FHUGCTagModel : JSONModel
@property (nonatomic, assign) long long tagId;
@property (nonatomic, copy) NSString *name;
@end

@protocol FHUGCRemarkModel <NSObject>
@end
@interface FHUGCRemarkModel : JSONModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger maxScore;
@property (nonatomic, assign) NSInteger step;
@end

@interface FHUGCTagAndRemarkDataModel : JSONModel
@property (nonatomic, strong) NSArray<FHUGCTagModel> *tags;
@property (nonatomic, strong) NSArray<FHUGCRemarkModel> *remarks;
@end

@interface FHUGCTagAndRemarkModel : JSONModel<FHBaseModelProtocol>
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) FHUGCTagAndRemarkDataModel *data;
@end

NS_ASSUME_NONNULL_END
