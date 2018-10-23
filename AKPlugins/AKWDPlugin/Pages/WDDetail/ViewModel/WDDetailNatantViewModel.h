//
//  WDDetailNatantViewModel.h
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//

#import <Foundation/Foundation.h>
#import "WDApiModel.h"

@class WDDetailModel;
@class WDDetailNatantViewBase;
@class WDDetailNatantViewModel;
@protocol WDActionSheetProtocol;

typedef void(^WDDetailFetchInfoBlock)(WDDetailModel *infoManager,
NSError *error);

@interface WDDetailNatantViewModel : NSObject

@property (nonatomic, assign) BOOL isShowDeleteAnswer;
@property (nonatomic, readonly, strong) WDDetailModel *detailModel;

- (instancetype)initWithDetailModel:(WDDetailModel *)detailModel;

- (void)tt_startFetchInformationWithFinishBlock:(WDDetailFetchInfoBlock)block;
- (void)tt_preloadNextWithAnswerID:(NSString *)answerID;

- (void)tt_removeAnswerForAnswerIDFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock;
- (void)tt_opanAnswerCommentForAnswerIDFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock;
- (void)tt_willChangeArticleFavoriteState;

//- (NSArray<TTActivity *> *)tt_custActivityItems;
- (void)tt_willShowReport;

- (NSMutableArray <WDDetailNatantViewBase *> *)p_newItemsBuildInNatantWithDetailModel:(WDDetailModel *)infoManager relatedView:(UIView *)view;

- (BOOL)canDeleteComment;
- (NSString *)etag;

- (void)tt_sendDetailLogicTrackWithLabel:(NSString *)label;

@end

@interface WDDetailNatantViewModel (NetWorkCategory)

+ (void)startFetchArticleInfoWithAnswerID:(NSString *)ansID
                                gdExtJson:(NSString *)gdExtJson
                             apiParameter:(NSString *)apiParameter
                                 showMode:(NSNumber *)showMode
                              finishBlock:(void(^)(WDWendaAnswerInformationResponseModel *responseModel, NSError *error))finishBlock;

@end
