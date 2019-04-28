//
//  TTRecommendUserCollectionView.h
//  Article
//
//  Created by SongChai on 04/06/2017.
//
//

#import <UIKit/UIKit.h>
#import "FRApiModel.h"
#import "TTNetworkManager.h"
#import "TTFriendRelation_Enums.h"

@protocol TTRecommendUserCollectionViewDelegate <NSObject>
//埋点
- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic;

//impression携带参数
- (NSDictionary *)impressionParams;

//服务器携带参数
@optional
//处理delete
- (void)onRemoveModel:(FRRecommendCardStructModel*)model originalModels:(NSArray<FRRecommendCardStructModel*>*)models;
- (void)onReplaceModel:(FRRecommendCardStructModel*)oldModel newModel:(FRRecommendCardStructModel *)newModel originalModels:(NSArray<FRRecommendCardStructModel*>*)models;
//为空时候的一些处理
- (void)onCardEmpty;

- (NSString *)categoryID;
@end

@interface TTRecommendUserCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong, readonly) NSArray<FRRecommendCardStructModel*>* allUserModels;
@property(nonatomic, weak) id<TTRecommendUserCollectionViewDelegate> recommendUserDelegate;
@property(nonatomic, assign) TTFollowNewSource followSource; //主要标记来自于哪里，用于埋点
@property (nonatomic, assign) BOOL needSupplementCard;
@property (nonatomic, assign) BOOL disableDislike;

+ (instancetype) collectionView;

- (void)configUserModels:(NSArray<FRRecommendCardStructModel *> *)userModels
           requesetModel:(FRUserRelationUserRecommendV1SupplementRecommendsRequestModel *)requestModel;

- (void)willDisplay;
- (void)didEndDisplaying;

//complete不为空则成功，返回值会强校验数据类型
+ (TTHttpTask *)requestDataWithSource:(NSString *)source
                                scene:(NSString *)scene
                          sceneUserId:(NSString *)userId
                              groupId:(NSString *)groupId
                             complete:(void (^)(NSArray<FRRecommendCardStructModel *> *))block;
@end
