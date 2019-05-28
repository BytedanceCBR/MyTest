//
//  TTUGCHashtagModel.h
//  TTUGCFoundation
//
//  Created by zoujianfeng on 2019/1/8.
//

#import <Foundation/Foundation.h>
#import "FRApiModel.h"

extern NSString * const TTUGCSelfCreateHashtagLinkURLString;

@interface TTUGCHashtagHeaderModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL showTopSeparator;

@end

@interface TTUGCHashtagModel : NSObject

- (instancetype)initWithSearchHashtagStructModel:(FRPublishPostSearchHashtagStructModel *)searchHashtagModel;
+ (TTUGCHashtagModel *)hashtagModelSelfCreateWithSearchHashtagStructModel:(FRPublishPostSearchHashtagStructModel *)searchHashtagModel;
+ (NSArray <TTUGCHashtagModel *> *)hashtagModelsWithSearchHashtagModels:(NSArray <FRPublishPostSearchHashtagStructModel *> *)searchHashtagModels;

@property (nonatomic, strong) FRPublishPostSearchHashtagItemStructModel *forum;
@property (nonatomic, strong) FRPublishPostHashtagHighlightStructModel<Optional> *highlight;
@property (nonatomic, assign) BOOL canBeCreated; // 是否能被用户创建，但还取决于 FRPublishPostSearchHashtagItemStructModel 中 status：1有效，0无效

@end

