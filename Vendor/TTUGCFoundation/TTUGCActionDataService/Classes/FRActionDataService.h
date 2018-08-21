//
//  FRActionDataService.h
//  Article
//
//  Created by 柴淞 on 17/10/24.
//
//

#import "TTServiceCenter.h"

typedef enum: int {
    FRActionDataModelTypeUnknow = 0,
    FRActionDataModelTypeArticle,
    FRActionDataModelTypeThread,
    FRActionDataModelTypeComment,
} FRActionDataModelType;

@protocol FRActionDataProtocol<NSObject>

/**
 Thread对应threadID，Article对应groupID，评论对应commentID
 后台确认几种id都是id生成器统一生成，确认不会重复
 */
@property (nonatomic, strong) NSString *uniqueID;

@property (nonatomic, assign) NSUInteger repostCount;
@property (nonatomic, assign) NSUInteger diggCount;
@property (nonatomic, assign) NSUInteger readCount;
@property (nonatomic, assign) NSUInteger commentCount;
@property (nonatomic, assign) NSUInteger articleLikeCount;

@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL hasDigg;
@property (nonatomic, assign) BOOL hasDelete;
@property (nonatomic, assign) BOOL showOrigin;
@property (nonatomic, assign) BOOL articleHasLike;

@property (nonatomic, assign) FRActionDataModelType modelType;
@end

@interface FRActionDataService : NSObject<TTService>

/**
 获取FRActionDataProtocol实例

 @param uniqueID 文章id、帖子id、评论id
 @param type 类型
 @return 本地不存在会init
 */
- (id<FRActionDataProtocol>)modelWithUniqueID:(NSString *)uniqueID type:(FRActionDataModelType)type;

//以unknow形式调用上述方法
- (id<FRActionDataProtocol>)modelWithUniqueID:(NSString *)uniqueID;
@end
