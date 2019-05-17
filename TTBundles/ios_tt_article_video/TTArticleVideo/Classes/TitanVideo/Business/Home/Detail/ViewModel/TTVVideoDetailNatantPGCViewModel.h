//
//  TTVVideoDetailNatantPGCViewModel.h
//  Article
//
//  Created by lishuangyang on 2017/5/24.
//
//

#import <Foundation/Foundation.h>
#import "TTVVideoDetailNatantPGCModelProtocol.h"
#import "TTVVideoDetailNatantPGCViewController.h"
#import "FriendDataManager.h"
#import <JSONModel/JSONModel.h>
@protocol TTVDetailRelatedRecommendCellViewModelProtocol;
@class TTVDetailPGCUserRecommendResponseModel;
@interface TTVVideoDetailNatantPGCViewModel : NSObject

@property (nonatomic, strong ,nullable)id <TTVVideoDetailNatantPGCModelProtocol> pgcModel;
@property (nonatomic, strong ,nullable) TTVDetailPGCUserRecommendResponseModel *recommendResponse;
@property (nonatomic, strong ,nullable) NSMutableArray<id<TTVDetailRelatedRecommendCellViewModelProtocol>> *recommendArray;


- (instancetype _Nonnull )initWithPGCModel:(id <TTVVideoDetailNatantPGCModelProtocol> _Nullable) GPCInfo;

- (BOOL)isVideoSourceUGCVideo;

- (void)didSelectSubscribeButton: (FriendActionType) actionType andFinishBlock:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))comleteBLC;

- (void)fetchRecommendArray:(void (^ __nullable)(NSError * _Nullable error ))comleteBLC;

@end

@interface TTVDetailPGCUserRecommendResponseModel : JSONModel

@property (strong, nonatomic, nullable) NSNumber *err_no;
@property (strong, nonatomic, nullable) NSString<Optional> *err_tips;
@property (strong, nonatomic, nullable) NSArray<Optional>  *user_cards;
@property (strong, nonatomic, nullable) NSNumber<Optional> *has_more;

@end



