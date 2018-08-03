//
//  TTVDetailFollowRecommendCollectionView.h
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import <UIKit/UIKit.h>
#import "FriendDataManager.h"
#import "TTNetworkManager.h"
#import "TTVDetailRelatedRecommendCellViewModel.h"
@protocol TTVDetailFollowRecommendCollectionViewDelegate <NSObject>
//埋点
- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic;

//impression携带参数
- (NSDictionary *)impressionParams;
@optional
- (void)onRemoveModel:(id<TTVDetailRelatedRecommendCellViewModelProtocol>)model originalModels:(NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *)models;
- (void)onReplaceModel:(id<TTVDetailRelatedRecommendCellViewModelProtocol>)oldModel newModel:(id<TTVDetailRelatedRecommendCellViewModelProtocol>)newModel originalModels:(NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *)models;

//为空时候的一些处理
- (void)onCardEmpty;
- (NSString *)categoryID;
- (NSString *)recommendViewPositon;
- (void)recordCollectionViewContentOffset:(CGPoint)point;

@end

@interface TTVDetailFollowRecommendCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong, readonly) NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> * allUserModels;
@property(nonatomic, weak) id<TTVDetailFollowRecommendCollectionViewDelegate> recommendUserDelegate;
@property(nonatomic, assign) TTFollowNewSource followSource; //主要标记来自于哪里，用于埋点
@property (nonatomic, assign) BOOL needSupplementCard;
@property (nonatomic, assign) BOOL disableDislike;

+ (instancetype) collectionView;

- (void)configUserModels:(NSArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *)userModels;

- (void)willDisplay;
- (void)didEndDisplaying;

@end
