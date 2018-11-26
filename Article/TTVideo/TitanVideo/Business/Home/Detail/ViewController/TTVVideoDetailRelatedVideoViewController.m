//
//  TTVVideoDetailRelatedVideoViewController.m
//  Article
//
//  Created by pei yun on 2017/5/9.
//
//

#import "TTVVideoDetailRelatedVideoViewController.h"
#import "TLIndexPathController.h"
#import "TTVDetailRelatedVideoItem.h"
#import "NSArray+BlocksKit.h"
#import "UIViewController+TTVFetchedResultsTableDataSourceAndDelegate.h"
#import "TTVFetchedResultsTableDataSourceProtocol.h"
#import "UIView+TTVNestedScrollViewSupport.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTVideoService/VideoInformation.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTVDetailRelatedVideoItem.h"
#import "TTVVideoDetailRelatedAdItem.h"
#import "TTVRelatedVideoItem+TTVDetailRelatedVideoInfoDataProtocolSupport.h"
#import "TTVRelatedVideoItem+TTVDetailRelatedADInfoDataProtocol.h"
#import "TTVRelatedVideoADPic+TTVDetailRelatedADInfoDataProtocol.h"
#import "TTVRelatedVideoADPic+TTVComputedProperties.h"
#import "TTVDetailRelatedMoreItem.h"
#import "TTVRelatedItem+TTVArticleProtocolSupport.h"
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"
#import "ArticleDetailHeader.h"
#import "TTDetailContainerViewController.h"
#import "TTUIResponderHelper.h"
#import "TTVideoAlbumView.h"
#import "TTVVideoDetailAlbumView.h"
#import "NewsDetailConstant.h"
#import "TTURLTracker.h"
#import "TTVRelatedItem+TTVConvertToArticle.h"
#import "TTVRelatedItem+TTVComputedProperties.h"
#import "Article+TTVArticleProtocolSupport.h"
#import "ExploreVideoDetailImpressionHelper.h"
#import "TTVVideoDetailRelatedAdActionService.h"
#import "TTTrackerProxy.h"
#import <objc/runtime.h>

@interface TTVDetailRelatedTableViewItem (sourceRelatedItemCarried)

@property (nonatomic, strong) TTVRelatedItem *relatedItem;

@end

@implementation TTVDetailRelatedTableViewItem (sourceRelatedItemCarried)

- (TTVRelatedItem *)relatedItem
{
   return objc_getAssociatedObject(self, @selector(relatedItem));
}

- (void)setRelatedItem:(TTVRelatedItem *)relatedItem
{
   objc_setAssociatedObject(self, @selector(relatedItem), relatedItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface TTVVideoDetailRelatedVideoViewController () <TTVFetchedResultsTableDataSourceProtocol, TLIndexPathControllerDelegate>

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, assign) BOOL hasAlreadyClickShowMoreButton;
@property (nonatomic, strong) NSArray *allRelatedItems;
@property (nonatomic, assign) BOOL hasVideoAdShowSend;
@property (nonatomic, assign) BOOL hasRelatedShowSend;
@property (nonatomic, strong) TTVVideoDetailRelatedAdActionService *adActionService;
@property (nonatomic, strong) NSMutableDictionary *traceIdDict;


@end

@implementation TTVVideoDetailRelatedVideoViewController

@synthesize indexPathController = _indexPathController;

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _adActionService = [[TTVVideoDetailRelatedAdActionService alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    self.protocolInterceptor = [[TTVTableViewProtocolInterceptor alloc] init];
    self.fetchedResultsTableDataSource = [[TTVFetchedResultsTableDataSourceAndDelegate alloc] init];
    self.protocolInterceptor.middleMan = self;
    self.protocolInterceptor.receiver = self.fetchedResultsTableDataSource;
    self.indexPathController = [[TLIndexPathController alloc] init];
    self.indexPathController.delegate = self;
    self.traceIdDict = [NSMutableDictionary dictionary];
    
    self.tableView.dataSource = self.protocolInterceptor;
    self.tableView.delegate = self.protocolInterceptor;
    self.fetchedResultsTableDataSource.item_configCell = ^(TTVTableViewItem *item, TTVTableViewCell *cell, NSIndexPath *indexPath) {
        if ([item isKindOfClass:[TTVDetailRelatedVideoItem class]]) {
            TTVDetailRelatedVideoItem *itemA = (TTVDetailRelatedVideoItem *)item;
            if (![itemA.article isKindOfClass:[TTVRelatedVideoItem class]]) {
                return;
            }
            TTVRelatedVideoItem *videoItem = (TTVRelatedVideoItem *)itemA.article;
            NSString *relatedVideoTypeStr = videoItem.relatedVideoExtraInfo.cardType;
            if ([relatedVideoTypeStr isEqualToString:@"album"] || [relatedVideoTypeStr isEqualToString:@"video_subject"]) {
                if (videoItem.hasAlbum) {
                    itemA.isVideoAlbum = YES;
                    TTVVideoAlbum *album = videoItem.album;
                    NSString *col_no = [NSString stringWithFormat:@"%lld", album.colNo];
                    NSString *media_id = album.mediaId;
                    if (col_no) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:media_id forKey:@"media_id"];
                        wrapperTrackEventWithCustomKeys(@"video", @"detail_album_show", col_no, nil, dic);
                    }
                    else if (!isEmptyString(videoItem.article.videoDetailInfo.videoSubjectId)) {
                        wrapperTrackEventWithCustomKeys(@"video", @"detail_album_show", nil, nil, @{@"video_subject_id" : videoItem.article.videoDetailInfo.videoSubjectId});
                    }
                }
            }
        }
    };
}

- (void)setIndexPathController:(TLIndexPathController *)indexPathController
{
    _indexPathController = indexPathController;
    self.fetchedResultsTableDataSource.indexPathController = indexPathController;
}

- (void)setVideoInfo:(TTVVideoInformationResponse *)videoInfo
{
    _videoInfo = videoInfo;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (TTVRelatedItem *item in videoInfo.relatedVideoArray) {
        if (item.hasVideoItem) {
            TTVDetailRelatedVideoItem *videoItem = [[TTVDetailRelatedVideoItem alloc] init];
            videoItem.relatedItem = item;
            videoItem.article = item.videoItem;
            videoItem.fromArticle = videoInfo.article;
            videoItem.pushAnimation = NO;
            [items addObject:videoItem];
        } else if (item.hasAdPic) {
            if ([item.adPic isValidAd]) {
                TTVVideoDetailRelatedAdItem *adItem = [[TTVVideoDetailRelatedAdItem alloc] init];
                adItem.relatedItem = item;
                adItem.relatedADInfo = item.adPic;
                [items addObject:adItem];
            }
        } else {
            NSAssert(NO, @"TTVVideoInformationResponse.relatedVideoArray has error");
        }
    }
    self.allRelatedItems = [items copy];
    NSArray *displayedItems = [self getDisplayedItems];
    @weakify(self);
    if (self.indexPathController) {
       self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:displayedItems];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self directShowVideoSubjectIfNeeded];
        });
    } else {
        [[[RACObserve(self, indexPathController) distinctUntilChanged] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:displayedItems];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self directShowVideoSubjectIfNeeded];
            });
        }];
    }
    
    if (!self.hasRelatedShowSend) {
        if (!isEmptyString(self.videoInfo.groupModel.groupID)) {
            [TTTrackerWrapper category:@"umeng"
                                 event:@"detail"
                                 label:@"related_video_show"
                                  dict:@{@"value":self.videoInfo.groupModel.groupID}];
            self.hasRelatedShowSend = YES;
        }
    }
}

- (void)directShowVideoSubjectIfNeeded
{
    BOOL detailVCFromList = NO;
    if (_homeActionDelegate && [_homeActionDelegate respondsToSelector:@selector(detailVCIsFromList)]) {
        detailVCFromList = [_homeActionDelegate detailVCIsFromList];
    }
    if (detailVCFromList) {
        for (TTVRelatedItem *relatedItem in self.videoInfo.relatedVideoArray) {
            if ([relatedItem shouldDirectShowVideoSubject]) {
                [self didSelectVideoAlbum:relatedItem];
                break;
            }
        }
    }
}

- (NSArray *)getDisplayedItems
{
    NSInteger displayedItemsCount = self.hasAlreadyClickShowMoreButton ? self.allRelatedItems.count : MIN(self.videoInfo.relatedVideoSection > 0 ? self.videoInfo.relatedVideoSection : 5, self.allRelatedItems.count);
    NSMutableArray *displayedItems = [[self.allRelatedItems subarrayWithRange:NSMakeRange(0, displayedItemsCount)] mutableCopy];
    if (displayedItems.count < self.allRelatedItems.count) {
        TTVDetailRelatedMoreItem *moreItem = [[TTVDetailRelatedMoreItem alloc] init];
        [displayedItems addObject:moreItem];
    }
    return [displayedItems copy];
}

- (void)setupUI
{
    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    [self.view addSubview:self.tableView];
    self.view.ttvNestedScrollView = self.tableView;
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationNone completion:nil];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTVTableViewItem *item = (TTVTableViewItem *)[self.indexPathController.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(UITableViewDelegate)] && [item respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [(id <UITableViewDelegate>)item tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    if ([item isKindOfClass:[TTVDetailRelatedTableViewItem class]]) {
        TTVRelatedItem *relatedItem = ((TTVDetailRelatedTableViewItem *)item).relatedItem;
        [self sendAdImpressionForArticle:self.videoInfo rArticle:relatedItem status:SSImpressionStatusRecording];
        if ([item isKindOfClass:[TTVDetailRelatedVideoItem class]]) {
            TTVRelatedItem *item  = self.videoInfo.relatedVideoArray[indexPath.row];
            TTVVideoArticle *articleItem = (TTVVideoArticle *)(item.videoItem.article);
            
            NSString *itemId = [NSString stringWithFormat:@"%lld",(long long)articleItem.itemId];
            NSString *groupId = [NSString stringWithFormat:@"%lld",(long long)articleItem.groupId];
            
            TTVRelatedItem *article = relatedItem;
            article.savedConvertedArticle = [article ttv_convertedArticle];
//            NSString *categoryName = [NSString stringWithFormat:@"%lld",(long long)articleItem.];
            if (![self.traceIdDict[itemId] isEqual: @""]) {
                
                NSMutableDictionary *traceParams = [NSMutableDictionary dictionary];
                
        
                [traceParams setValue:@"house_app2c_v2" forKey:@"event_type"];
                
                [traceParams setValue:groupId forKey:@"group_id"];
                
                [traceParams setValue:itemId forKey:@"item_id"];
                
                [traceParams setValue:@"related" forKey:@"category_name"];
                
                [traceParams setValue:@"click_related" forKey:@"enter_from"];

                NSString *jsonLogPb = item.videoItem.logPb;
                if ([jsonLogPb isKindOfClass:[NSString class]])
                {
                    NSData *jsonData = [jsonLogPb dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err;
                    if (jsonData != nil) {
                        NSDictionary *dicLogPb = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&err];
                        if(err)
                        {
                            NSLog(@"json解析失败：%@",err);
                        }else
                        {
                            [traceParams setValue:dicLogPb forKey:@"log_pb"];
                        }
                    }
                }
                [traceParams setValue: @"be_null" forKey:@"cell_type"];
                [TTTracker eventV3:@"client_show" params:traceParams];

                [self.traceIdDict setObject:@"" forKey:itemId];
            }
            
            [self.class recordVideoDetailForArticle:self.videoInfo rArticle:relatedItem status:SSImpressionStatusRecording];
        } else if ([item isKindOfClass:[TTVVideoDetailRelatedAdItem class]]) {
        }
    }
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    TTVTableViewItem *item = (TTVTableViewItem *)[self.indexPathController.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(UITableViewDelegate)] && [item respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [(id <UITableViewDelegate>)item tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
    if ([item isKindOfClass:[TTVDetailRelatedVideoItem class]]) {
        TTVRelatedItem *relatedItem = ((TTVDetailRelatedVideoItem *)item).relatedItem;
        [self.class recordVideoDetailForArticle:self.videoInfo rArticle:relatedItem status:SSImpressionStatusEnd];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TTVTableViewItem *item = (TTVTableViewItem *)[self.indexPathController.dataModel itemAtIndexPath:indexPath];
    if ([item conformsToProtocol:@protocol(UITableViewDelegate)] && [item respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [(id <UITableViewDelegate>)item tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    if ([item isKindOfClass:[TTVDetailRelatedMoreItem class]]) {
        self.hasAlreadyClickShowMoreButton = YES;
        NSArray *displayedItems = [self getDisplayedItems];
        self.indexPathController.dataModel = [[TLIndexPathDataModel alloc] initWithItems:displayedItems];
    } else if ([item isKindOfClass:[TTVDetailRelatedVideoItem class]] || [item isKindOfClass:[TTVVideoDetailRelatedAdItem class]]) {
        TTVRelatedItem *relatedItem = ((TTVDetailRelatedVideoItem *)item).relatedItem;
        if ([item isKindOfClass:[TTVVideoDetailRelatedAdItem class]]) {
            TTVVideoDetailRelatedAdItem *adItem = (TTVVideoDetailRelatedAdItem *)item;
            [self.adActionService videoAdCell_didSelect:adItem.relatedADInfo uniqueIDStr:adItem.relatedADInfo.uniqueIDStr];
            return;
        }
        if (relatedItem.hasVideoItem && relatedItem.videoItem.hasAlbum) {
            [self didSelectVideoAlbum:relatedItem];
        } else {
            NewsGoDetailFromSource fromSource = NewsGoDetailFromSourceRelateReading;
            
            TTVRelatedItem *article = relatedItem;
            article.savedConvertedArticle = [article ttv_convertedArticle];
            TTVVideoInformationResponse *fromArticle = self.videoInfo;
            if ([self addAlbumViewWithArticle:article]) {
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kRelatedClickedNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"deallocMovie", nil]];

            [self openNextViewControllerWithArticle:article fromArticle:fromArticle fromSource:fromSource];
            
            //sendClickTrack
            NSString *label;
            if ([[article groupFlags] intValue] & kArticleGroupFlagsHasVideo) {
                label = @"click_related_video";
            }
            else {
                label = @"click_related";
            }
            
            if (!isEmptyString(fromArticle.groupModel.groupID)) {
                [TTTrackerWrapper category:@"umeng"
                              event:@"detail"
                              label:label
                               dict:@{@"value":fromArticle.groupModel.groupID}];
            }
            else {
                wrapperTrackEvent(@"detail", label);
            }
            CLS_LOG(@"didReceiveMemoryWarning");
            
            if (!article.hasVideoItem) {
                return;
            }
            NSString *relatedVideoTypeStr = article.videoItem.relatedVideoExtraInfo.cardType;
            if ([relatedVideoTypeStr isEqualToString:@"ad_video"] || [relatedVideoTypeStr isEqualToString:@"ad_textlink"]) {
                NSString *logExtra = [article relatedLogExtra];
                NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:0];
                if (!isEmptyString(logExtra)) {
                    extra[@"log_extra"] = logExtra;
                }
                
                TTVRelatedVideoAD *ad = article.videoItem.ad;
                if ([relatedVideoTypeStr isEqualToString:@"ad_video"] && [ad.creativeType isEqualToString:@"app"]) {
                    [[self.adActionService class] trackRealTimeAd:ad];
                    [extra setValue:@"1" forKey:@"has_v3"];
                }
                [extra setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
                
                NSString *value = article.videoItem.relatedVideoExtraInfo.adId;
                [extra setValue:@"1" forKey:@"is_ad_event"];
                wrapperTrackEventWithCustomKeys(@"detail_ad_list", @"click", value, nil, extra);
                if (!SSIsEmptyArray(article.ad.trackURL.clickTrackURLListArray)) {
                    
                    TTURLTrackerModel *trackModel = [[TTURLTrackerModel alloc] initWithAdId:article.ad.adId logExtra:article.ad.logExtra];
                    ttTrackURLsModel(article.ad.trackURL.clickTrackURLListArray, trackModel);
                }
            }
        }
        
    }
}

- (void)openNextViewControllerWithArticle:(TTVRelatedItem *)article fromArticle:(TTVVideoInformationResponse *)fromArticle fromSource:(NewsGoDetailFromSource)fromSource
{
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [condition setValue:@(fromArticle.uniqueID) forKey:kNewsDetailViewConditionRelateReadFromGID];
    [condition setValue:article.logPbDic forKey:@"logPb"];
    if (self.homeActionDelegate && [self.homeActionDelegate respondsToSelector:@selector(originalStatusBarHidden)]) {
        [condition setValue:@([self.homeActionDelegate originalStatusBarHidden]) forKey:kNewsDetailViewConditionOriginalStatusBarHidden];
    }
    if (self.homeActionDelegate && [self.homeActionDelegate respondsToSelector:@selector(originalStatusBarStyle)]) {
        [condition setValue:@([self.homeActionDelegate originalStatusBarStyle]) forKey:kNewsDetailViewConditionOriginalStatusBarStyle];
    }
    
    TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:article.savedConvertedArticle
                                                                                                          source:fromSource
                                                                                                       condition:condition];
    
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor: self];
    [nav pushViewController:detailController animated:NO];
    if (self.homeActionDelegate && [self.homeActionDelegate respondsToSelector:@selector(ttv_invalideMovieView)]) {
        [self.homeActionDelegate ttv_invalideMovieView];
    }
}

- (BOOL)addAlbumViewWithArticle:(TTVRelatedItem *)article
{
    if ([TTVVideoAlbumHolder holder].albumView) {
        if ([TTVVideoAlbumHolder holder].albumView.viewModel.currentPlayingArticle != article) {
            [TTVVideoAlbumHolder holder].albumView.viewModel.currentPlayingArticle = article;
            [[TTUIResponderHelper mainWindow] addSubview:[TTVVideoAlbumHolder holder].albumView];
            return YES;
        }
    }
    return NO;
}

- (void)didSelectVideoAlbum:(TTVRelatedItem *)article
{
    if (!(article.hasVideoItem && article.videoItem.hasAlbum)) {
        return;
    }
    if (_homeActionDelegate && [_homeActionDelegate respondsToSelector:@selector(_showVideoAlbumWithItem:)]) {
        [_homeActionDelegate _showVideoAlbumWithItem:article];
    }
    TTVVideoAlbum *album = article.videoItem.album;
    NSString *col_no = [NSString stringWithFormat:@"%lld", album.colNo];
    NSString *media_id = album.mediaId;
    if (col_no) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:media_id forKey:@"media_id"];
        wrapperTrackEventWithCustomKeys(@"video", @"detail_click_album", col_no, nil, dic);
    }
    else if (!isEmptyString(article.videoItem.article.videoDetailInfo.videoSubjectId)) {
        wrapperTrackEventWithCustomKeys(@"video", @"detail_click_album", nil, nil, @{@"video_subject_id": article.videoItem.article.videoDetailInfo.videoSubjectId});
    }
}

//单独发送广告的show、track_url_list 且只发一次
- (void)sendAdImpressionForArticle:(TTVVideoInformationResponse *)article rArticle:(TTVRelatedItem *)rArticle status:(SSImpressionStatus)status
{
    TTVRelatedVideoAD *relatedAD = rArticle.ad;
    if (!isEmptyString(relatedAD.adId) && status == SSImpressionStatusRecording) {
        //只允许广告事件发一次
        if (self.hasVideoAdShowSend == YES) {
            return;
        }
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:article.groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
        
        if ([article hasVideoSubjectID]) {
            [extra setValue:[article videoSubjectID] forKey:@"video_subject_id"];
        }
        if ([rArticle relatedLogExtra]) {
            extra[@"log_extra"] = [rArticle relatedLogExtra];
        }
        NSString *value = relatedAD.adId;
        NSMutableDictionary * adDict = [NSMutableDictionary dictionaryWithDictionary:extra];
        [adDict setValue:@"1" forKey:@"is_ad_event"];
        [adDict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        NSString* creativeType = rArticle.videoAdExtra.creative_type;
        wrapperTrackEventWithCustomKeys(@"detail_ad_list", @"show", value, nil, adDict);
        TTURLTrackerModel *trackModel = [[TTURLTrackerModel alloc] initWithAdId:relatedAD.adId logExtra:relatedAD.logExtra];
        ttTrackURLsModel(relatedAD.trackURL.trackURLListArray, trackModel);
        
        self.hasVideoAdShowSend = YES;
    }
}

+ (void)recordVideoDetailForArticle:(TTVVideoInformationResponse *)article
                           rArticle:(TTVRelatedItem *)rArticle
                             status:(SSImpressionStatus)status
{
    NSString *videoID = article.videoDetailInfo[VideoInfoIDKey];
    NSString *rVideoID = rArticle.videoDetailInfo[VideoInfoIDKey];
    if (isEmptyString(rVideoID) || isEmptyString(rArticle.groupModel.groupID) || !rArticle.hasVideoItem) {
        return;
    }
    NSString *keyName = [NSString stringWithFormat:@"%@_%@_%@", article.groupModel.groupID, article.groupModel.itemID, videoID];
    NSString *impressionItemID = [NSString stringWithFormat:@"%@_%@_%@", rArticle.groupModel.groupID, rArticle.groupModel.itemID, rVideoID];
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:article.groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
    
    if ([article hasVideoSubjectID]) {
        [extra setValue:[article videoSubjectID] forKey:@"video_subject_id"];
    }
    
    if (rArticle.videoItem.hasAd && status == SSImpressionStatusRecording) {
        if ([rArticle relatedLogExtra]) {
            extra[@"log_extra"] = [rArticle relatedLogExtra];
        }
    }
    
    [[SSImpressionManager shareInstance] recordVideoDetailImpressionWithKeyName:keyName itemID:impressionItemID status:status userInfo:@{@"extra":extra}];
}

@end
