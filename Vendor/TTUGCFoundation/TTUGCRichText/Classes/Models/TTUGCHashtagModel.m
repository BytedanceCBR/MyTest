//
//  TTUGCHashtagModel.m
//  TTUGCFoundation
//
//  Created by zoujianfeng on 2019/1/8.
//

#import "TTUGCHashtagModel.h"
#import <TTBaseLib/TTBaseMacro.h>

NSString * const TTUGCSelfCreateHashtagLinkURLString = @"TTUGCSelfCreateHashtagLinkURLString";

@implementation TTUGCHashtagHeaderModel

@end

@implementation TTUGCHashtagModel

- (instancetype)initWithSearchHashtagStructModel:(FRPublishPostSearchHashtagStructModel *)searchHashtagModel {
    self = [super init];
    if (self) {
        _highlight = searchHashtagModel.highlight;
        _forum = searchHashtagModel.forum;
    }

    return self;
}

+ (TTUGCHashtagModel *)hashtagModelSelfCreateWithSearchHashtagStructModel:(FRPublishPostSearchHashtagStructModel *)searchHashtagModel {
    TTUGCHashtagModel *hashtagModel = [[TTUGCHashtagModel alloc] initWithSearchHashtagStructModel:searchHashtagModel];
    hashtagModel.canBeCreated = YES;
    hashtagModel.forum.schema = TTUGCSelfCreateHashtagLinkURLString;
    return hashtagModel;
}

+ (NSArray<TTUGCHashtagModel *> *)hashtagModelsWithSearchHashtagModels:(NSArray<FRPublishPostSearchHashtagStructModel *> *)searchHashtagModels {
    __block NSMutableArray *hashtagModels = [NSMutableArray array];
    if (!SSIsEmptyArray(searchHashtagModels)) {
        [searchHashtagModels enumerateObjectsUsingBlock:^(FRPublishPostSearchHashtagStructModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [hashtagModels addObject:[[TTUGCHashtagModel alloc] initWithSearchHashtagStructModel:obj]];
        }];
    }

    return [hashtagModels copy];
}

@end
