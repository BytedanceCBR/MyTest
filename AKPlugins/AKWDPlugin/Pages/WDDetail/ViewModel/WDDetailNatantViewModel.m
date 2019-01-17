//
//  WDDetailNatantViewModel.m
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//  详情页浮层VM

#import "WDDetailNatantViewModel.h"
#import "WDDetailUserPermission.h"
#import "WDDetailNatantRelateArticleGroupView.h"
#import "WDDetailNatantRelateArticleGroupViewModel.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "WDMonitorManager.h"
#import "WDDefines.h"
#import "WDNetWorkPluginManager.h"
#import "WDSettingHelper.h"
#import "WDAnswerService.h"
#import "WDDetailNatantViewBase.h"
#import "WDDetailNatantHeaderPaddingView.h"
#import "WDDetailNatantLayout.h"
#import "WDDetailFullContentManager.h"
#import "WDDetailNatantRewardView.h"

#import "TTModuleBridge.h"
#import "TTActionSheetController.h"
#import "TTIndicatorView.h"
#import "TTGroupModel.h"
#import "DetailActionRequestManager.h"
#import <TTBaseLib/JSONAdditions.h>

#import <TTAccountBusiness.h>

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT

@interface WDDetailNatantViewModel ()

@property (nonatomic, strong) WDDetailModel *detailModel;
@property (nonatomic, strong) DetailActionRequestManager *itemActionManager;
@property (nonatomic, assign) BOOL infoIsRequesting;

@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@property (nonatomic, copy) NSDictionary *parameter;

@end

@implementation WDDetailNatantViewModel

- (instancetype)initWithDetailModel:(WDDetailModel *)detailModel
{
    self = [super init];
    if (self) {
        _detailModel = detailModel;
    }
    return self;
}

#pragma mark - public

- (void)tt_startFetchInformationWithFinishBlock:(WDDetailFetchInfoBlock)finishBlock
{
    if (self.infoIsRequesting) {
        return;
    }
    self.infoIsRequesting = YES;
    NSString *groupID = self.detailModel.answerEntity.ansid;
    if (isEmptyString(groupID)) {
        return;
    }
    NSString *gdExtJson = [self.detailModel.gdExtJsonDict tt_JSONRepresentation];
    NSString *apiParam = [self.detailModel.apiParam tt_JSONRepresentation];
    // 接口有问题，传1的时候nexAid = aid
    // BOOL showMode = [[WDSettingHelper sharedInstance_tt] wdDetailShowMode];
    WeakSelf;
    [WDDetailNatantViewModel startFetchArticleInfoWithAnswerID:groupID gdExtJson:gdExtJson apiParameter:apiParam showMode:@([[WDSettingHelper sharedInstance_tt] wdDetailShowMode])  finishBlock:^(WDWendaAnswerInformationResponseModel *responseModel, NSError *error) {
        StrongSelf;
        self.infoIsRequesting = NO;
        if (error) {
            
            if (finishBlock) {
                finishBlock(self.detailModel, error);
            }
            
            
            [[TTMonitor shareManager] trackService:WDDetailInfoService
                                            status:WDRequestNetworkStatusFailed
                                             extra:[WDMonitorManager extraDicWithAnswerId:self.detailModel.answerEntity.ansid error:error]];
            
        } else {
            [self.detailModel updateDetailModelWith:responseModel];
            
            if (finishBlock) {
                finishBlock(self.detailModel, error);
            }
            
            [[TTMonitor shareManager] trackService:WDDetailInfoService status:WDRequestNetworkStatusCompleted extra:[WDMonitorManager extraDicWithAnswerId:self.detailModel.answerEntity.ansid error:error]];
        }
    }];
}


- (void)tt_preloadNextWithAnswerID:(NSString *)answerID
{
    if (isEmptyString(answerID)) {
        return;
    }
    WDAnswerEntity *answerEntity = [WDAnswerEntity generateAnswerEntityFromAnsid:answerID];
    if (!answerEntity) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:answerID forKey:@"ansid"];
        answerEntity = [WDAnswerEntity objectWithDictionary:dict];
        [answerEntity save];
    }
    
    if ((isEmptyString(answerEntity.content) && !answerEntity.detailWendaExtra.allKeys.count) ||
        answerEntity.answerDeleted) {
        [[WDDetailFullContentManager sharedManager] fetchDetailForAnswerEntity:answerEntity
                                                                        useCDN:self.detailModel.useCDN];
    }
}

- (void)tt_opanAnswerCommentForAnswerIDFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock
{
    WDOPCommentType commentType = self.detailModel.answerEntity.banComment ? WDOPCommentTypeUnForbidComment : WDOPCommentTypeForbidComment;
    [WDAnswerService opAnswerCommentForAnswerID:self.detailModel.answerEntity.ansid objectType:commentType apiParameter:self.detailModel.apiParam finishBlock:^(WDWendaOpanswerCommentResponseModel *responseModel, NSError *error) {
        if ((error.code != TTNetworkErrorCodeSuccess) || ([responseModel.err_no integerValue] != 0)) {
            NSString * tip = [[error userInfo] objectForKey:@"description"];
            if (isEmptyString(tip)) {
                tip = responseModel.err_tips;
            }
            if (isEmptyString(tip)) {
                tip = @"操作失败";
            }
            finishBlock(tip, error);
        } else {
            self.detailModel.answerEntity.banComment = !self.detailModel.answerEntity.banComment;
            NSString *tips = self.detailModel.answerEntity.banComment ? @"已禁止用户评论" : @"已允许用户评论";
            finishBlock(tips, nil);
        }
    }];
    
    NSString *label = commentType == WDOPCommentTypeUnForbidComment ? @"allow_comment" : @"ban_comment";
    NSMutableDictionary *dict = [self.detailModel.gdExtJsonDict mutableCopy];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:kWDDetailViewControllerUMEventName forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
    [TTTracker eventData:[dict copy]];
}

- (void)tt_removeAnswerForAnswerIDFinishBlock:(void(^)(NSString *tips, NSError *error))finishBlock
{
    NSMutableDictionary *dict = [self.detailModel.gdExtJsonDict mutableCopy];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:kWDDetailViewControllerUMEventName forKey:@"tag"];
    [dict setValue:@"delete_answer" forKey:@"label"];
    [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
    [TTTracker eventData:[dict copy]];
    
    [WDAnswerService deleteWithAnswerID:self.detailModel.answerEntity.ansid apiParam:self.detailModel.apiParam finishBlock:^(WDWendaCommitDeleteanswerResponseModel *responseModel, NSError *error) {
        if ((error.code != TTNetworkErrorCodeSuccess) || [responseModel.err_no integerValue] != 0) {
            NSString *tip = [[error userInfo] objectForKey:@"description"];
            if (isEmptyString(tip)) {
                tip = responseModel.err_tips;
            }
            if (isEmptyString(tip)) {
                tip = @"删除失败，请稍后重试";
            }
            finishBlock(tip, error);
        } else {
            self.detailModel.answerEntity.answerDeleted = YES;
            finishBlock(nil, nil);
        }
    }];
}

- (BOOL)canDeleteComment
{
    return [self.detailModel.userPermission canDeleteComment];
}

- (NSString *)etag
{
    return self.detailModel.etag;
}

- (void)tt_sendDetailLogicTrackWithLabel:(NSString *)label
{
    TTGroupModel *model = [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
    [self trackEventCategory:@"umeng" tag:kWDDetailViewControllerUMEventName label:label value:self.detailModel.answerEntity.ansid  extValue:nil fromGID:nil adID:nil params:self.detailModel.gdExtJsonDict groupModel:model];
}

- (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue fromGID:(NSNumber *)fromGID adID:(NSNumber *)adID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel {
    NSMutableDictionary * dict;
    if ([params isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:params];
    } else {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    [dict setValue:c forKey:@"category"];
    [dict setValue:t forKey:@"tag"];
    [dict setValue:l forKey:@"label"];
    if (!isEmptyString(groupModel.itemID)) {
        [dict setValue:groupModel.itemID forKey:@"item_id"];
        [dict setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    }
    [dict setValue:v forKey:@"value"];
    [dict setValue:eValue forKey:@"ext_value"];
    [dict setValue:fromGID forKey:@"from_gid"];
    if (adID.longLongValue > 0) {
        [dict setValue:adID forKey:@"ad_id"];
    }
    [TTTracker eventData:dict];
}
#pragma mark - fav

- (void)tt_willChangeArticleFavoriteState
{
    
    NSString *label;
    DetailActionRequestType type;
    if (!self.detailModel.answerEntity.userRepined) {
        label = @"favourite_button";
        type = DetailActionTypeFavourite;
    }
    else {
        label = @"unfavorite_button";
        type = DetailActionTypeUnFavourite;
    }
    
    self.detailModel.answerEntity.userRepined = !self.detailModel.answerEntity.userRepined;
    [self.detailModel.answerEntity save];
    
    //由于分享面板在pod中，暂时使用string构造class
    __block UIWindow * activityPanelControllerWindow = nil;
    Class activityPanelControllerWindowClass = NSClassFromString(@"TTActivityPanelControllerWindow");
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:activityPanelControllerWindowClass]) {
            activityPanelControllerWindow = obj;
            *stop = YES;
        }
    }];
    if(self.detailModel.answerEntity.userRepined) {
        TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                            indicatorText:NSLocalizedString(@"收藏成功", nil)
                                                                           indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                                                           dismissHandler:nil];
        [indicatorView showFromParentView:activityPanelControllerWindow];
    }
    else {
        TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                            indicatorText:NSLocalizedString(@"取消收藏", nil)
                                                                           indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                                                           dismissHandler:nil];
        [indicatorView showFromParentView:activityPanelControllerWindow];
    }
    
   
    if (!self.detailModel.answerEntity.userRepined) {
         [self tt_sendDetailLogicTrackWithLabel:label];
    }
    else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.detailModel.answerEntity.ansid forKey:@"group_id"];
        [params setValue:self.detailModel.answerEntity.ansid forKey:@"ansid"];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:[self.detailModel.gdExtJsonDict tta_stringForKey:@"enter_from"]  forKey:@"enter_from"];
        [params setValue:[self.detailModel.gdExtJsonDict tta_stringForKey:@"category_name"]  forKey:@"category_name"];
        [params setValue:[self.detailModel.gdExtJsonDict tta_stringForKey:@"qid"]  forKey:@"qid"];
        [params setValue:[self.detailModel.gdExtJsonDict tt_objectForKey:@"log_pb"]  forKey:@"log_pb"];
        [params setValue:@"detail" forKey:@"position"];
        [TTTracker eventV3:@"rt_favourite" params:params];
       
    }
}

- (void)sendFavoriteAction:(DetailActionRequestType)type entity:(WDAnswerEntity *)entity
{
    if (!self.itemActionManager) {
        self.itemActionManager = [[DetailActionRequestManager alloc] init];
    }
    self.itemActionManager.finishBlock = ^(id userInfo, NSError *error) {
        if (error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"失败，请重试", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
        }
    };
    
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:entity.ansid];
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    [self.itemActionManager setContext:context];
    
    [self.itemActionManager startItemActionByType:type];
}

#pragma mark - report

- (void)tt_willShowReportInNatantRewardView {
    [self showReportSheetController];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"answer_detail" forKey:@"tag"];
    [dict setValue:@"info_report" forKey:@"label"];
    [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
    [TTTracker eventData:dict];
}

- (void)tt_willShowReport
{
    [self showReportSheetController];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"answer_detail" forKey:@"tag"];
    [dict setValue:@"report" forKey:@"label"];
    [TTTracker eventData:dict];
}

- (void)showReportSheetController {
    if (!self.actionSheetController) {
        self.actionSheetController = [[TTActionSheetController alloc] init];
    }
    [self.actionSheetController insertReportArray:[[WDSettingHelper sharedInstance_tt] wendaAnswerReportSetting]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeWendaAnswer completion:^(NSDictionary * _Nonnull parameters) {
        StrongSelf;
        if ([self.parameter isEqualToDictionary:parameters]) {
            return;
        }
        BOOL modify = NO;
        if (!SSIsEmptyDictionary(self.parameter)) {
            modify = YES;
        }
        NSString *alertHeader = modify ? @"修改" : @"反馈";
        [WDAnswerService reportWithAnswerID:self.detailModel.answerEntity.ansid
                               reportParams:parameters
                                        gid:self.detailModel.answerEntity.ansid
                                   apiParam:[self.detailModel.apiParam tt_JSONRepresentation]
                                finishBlock:^(NSError *error, NSString *tips) {
                                    if (error) {
                                        NSString *alertText = [NSString stringWithFormat:@"%@失败", alertHeader];
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:alertText indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                    } else {
                                        NSString *alertText = [NSString stringWithFormat:@"%@成功", alertHeader];
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:alertText indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                        self.parameter = parameters;
                                    }
                                }];
    }];
}

#pragma mark - Util Methods

- (NSMutableArray <WDDetailNatantViewBase *> *)p_newItemsBuildInNatantWithDetailModel:(WDDetailModel *)detailModel relatedView:(UIView *)view{
    NSMutableArray *natantItems = [NSMutableArray array];
    CGFloat natantWidth = [TTUIResponderHelper splitViewFrameForView:view].size.width-[[WDDetailNatantLayout sharedInstance_tt] leftMargin]-[[WDDetailNatantLayout sharedInstance_tt] rightMargin];
    NSArray * classNameList = detailModel.classNameList;
    [natantItems addObject:[self p_natantSpacingItemForClass:@"topMargin" view:view]];
    [classNameList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * className = (NSString *)obj;
        WDDetailNatantViewBase * natantView = [(WDDetailNatantViewBase *)[NSClassFromString(className) alloc] initWithWidth:natantWidth];
        if ([className isEqualToString:@"WDCommentReposNatantHeaderView"]) {
            natantView.left = 0.0f;
            natantView.width = [TTUIResponderHelper splitViewFrameForView:view].size.width;
        } else {
            natantView.left = [[WDDetailNatantLayout sharedInstance_tt] leftMargin];
        }
        if (natantView) {
            if ([natantView isKindOfClass:[WDDetailNatantRelateArticleGroupView class]]) {
                WDDetailNatantRelateArticleGroupView *groupView = (WDDetailNatantRelateArticleGroupView *)natantView;
                groupView.viewModel.answerEntity = self.detailModel.answerEntity;
            }
            if ([natantView isKindOfClass:[WDDetailNatantRewardView class]]) {
                WDDetailNatantRewardView *relatedView = (WDDetailNatantRewardView *)natantView;
                WeakSelf;
                [relatedView setClickReportBlock:^{
                    StrongSelf;
                    [self tt_willShowReportInNatantRewardView];
                }];
            }
            if ([className isEqualToString:@"WDCommentReposNatantHeaderView"]) {
                WDDetailNatantHeaderPaddingView *paddingView = [self p_natantSpacingItemForClass:className view:view];
                paddingView.backgroundColorThemeKey = kColorBackground3;
                paddingView.backgroundColors = nil;
                [natantItems addObject:paddingView];
            }
            [natantItems addObject:natantView];
            if (![className isEqualToString:@"WDCommentReposNatantHeaderView"]) {
                [natantItems addObject:[self p_natantSpacingItemForClass:className view:view]];
            }
        }
    }];
    return natantItems;
}

- (WDDetailNatantHeaderPaddingView *)p_natantSpacingItemForClass:(NSString *)className view:(UIView *)view{
    CGFloat paddingHeight = 0;
    SWITCH (className) {
        CASE (@"topMargin") {
            paddingHeight = [[WDDetailNatantLayout sharedInstance_tt] wd_topMargin];
            break;
        }
        CASE (@"WDDetailNatantTagsView") {
            paddingHeight = [[WDDetailNatantLayout sharedInstance_tt] spaceBeweenNantants];
            break;
        }
        CASE (@"WDDetailNatantRelateWendaView") {
            paddingHeight = [[WDDetailNatantLayout sharedInstance_tt] spaceBeweenNantants];
            break;
        }
        CASE (@"WDDetailNatantRelateArticleGroupView"){
            paddingHeight = [[WDDetailNatantLayout sharedInstance_tt] bottomMargin];
            break;
        }
        CASE(@"TTWDDetailADContainerView") {
            paddingHeight = [[WDDetailNatantLayout sharedInstance_tt] wd_bottomMargin];
            break;
        }
        CASE(@"WDCommentReposNatantHeaderView") {
            paddingHeight = 6.0f;
            break;
        }
        DEFAULT {
            paddingHeight = [[WDDetailNatantLayout sharedInstance_tt] spaceBeweenNantants];
            break;
        }
    }
    WDDetailNatantHeaderPaddingView *spacingItem = [[WDDetailNatantHeaderPaddingView alloc] initWithWidth:[TTUIResponderHelper splitViewFrameForView:view].size.width];
    spacingItem.height = paddingHeight;
    spacingItem.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return spacingItem;
}

@end

@implementation WDDetailNatantViewModel (NetWorkCategory)

+ (void)startFetchArticleInfoWithAnswerID:(NSString *)ansID
                                gdExtJson:(NSString *)gdExtJson
                             apiParameter:(NSString *)apiParameter
                                 showMode:(NSNumber *)showMode
                              finishBlock:(void(^)(WDWendaAnswerInformationResponseModel *responseModel, NSError *error))finishBlock
{
    WDWendaAnswerInformationRequestModel *requestModel = [[WDWendaAnswerInformationRequestModel alloc] init];
    requestModel.ansid = ansID;
    requestModel.api_param = apiParameter;
    requestModel.gd_ext_json = gdExtJson;
    
    
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTLocationCoordinate" object:nil withParams:nil complete:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *coordinate = (NSDictionary *)result;
            requestModel.latitude = [coordinate valueForKey:@"latitude"];
            requestModel.longitude = [coordinate valueForKey:@"longitude"];
        }
    }];
    
    [[WDNetWorkPluginManager sharedInstance_tt] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (finishBlock) {
            finishBlock((WDWendaAnswerInformationResponseModel *)responseModel, error);
        }
    }];
}

@end

