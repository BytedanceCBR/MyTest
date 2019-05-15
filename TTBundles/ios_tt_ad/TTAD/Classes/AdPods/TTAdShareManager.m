//
//  TTAdShareManager.m
//  Article
//
//  Created by yin on 2016/11/11.
//
//

#import "TTAdShareManager.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTBaseLib/UIDevice+TTAdditions.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTTracker/TTTrackerProxy.h>
#import "TTURLTracker.h"
#import "SSSimpleCache.h"
#import "NetworkUtilities.h"
#import "TTAdMonitorManager.h"
#import "TTAdCommonUtil.h"
#import "TTAdTrackManager.h"
#import "TTAdUrlSetting.h"

#define kTTAdShareManagerModelKey @"kTTAdShareManagerModelKey" //保存分享广告key

@interface TTAdShareManager ()

@property (nonatomic, strong) TTAdShareBoardModel* model;
@property (nonatomic, assign) BOOL inAdPage;
@property (nonatomic, strong) NSString* groupId;

@end

@implementation TTAdShareManager

Singleton_Implementation(TTAdShareManager)

+ (void)load
{
    [[TTAdSingletonManager sharedManager] registerSingleton:[TTAdShareManager sharedManager] forKey:NSStringFromClass([self class])];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inAdPage = NO;
    }
    return self;
}

- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("ad.share.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), concurrentQueue, ^{
        [self requestShareAdData];
    });
}

- (void)requestShareAdData
{
    TTAdShareBoardModel* model = [TTAdShareManager getShareBoardModel];
    [TTAdShareManager predownloadModel:model];
    if (model&&model.data.requestTime&&[model.data.requestTime isKindOfClass:[NSDate class]]) {
        //现在时间早于请求时间
        if ([[NSDate date] compare:model.data.requestTime] == NSOrderedAscending) {
            return;
        }
    }
    [self requestData];
}

- (void)requestData
{
    NSString* url = [TTAdUrlSetting shareAdURLString];
    NSDictionary *params = [TTAdCommonUtil  generalDeviceInfo];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        StrongSelf;
        NSError* jsonError = nil;
        self.model = [[TTAdShareBoardModel alloc] initWithDictionary:jsonObj error:&jsonError];
        if (self.model == nil||self.model.data == nil) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            if (jsonError&&!isEmptyString(jsonError.description)) {
                [dict setValue:jsonError.description forKey:@"jsonerror"];
            }
            [TTAdMonitorManager trackService:@"shareboard_apierror" status:0 extra:dict];
        }
        
        //读取缓存更新model
        TTAdShareBoardModel* localModel = [TTAdShareManager getShareBoardModel];
        TTAdShareBoardDataModel* dataModel = self.model.data;
        
        [dataModel readShowCloseTime:localModel];
        [dataModel updateDate];
        
        if (self.model.data.ad_item&&self.model.data.ad_item.count>0) {
            
            TTAdShareBoardItemModel* itemModel = self.model.data.ad_item.firstObject;
            [itemModel updateDate];
        }
        if (self.model) {
            [TTAdShareManager saveShareBoardModel:self.model];
            [TTAdShareManager predownloadModel:self.model];
        }
    }];
}

+ (void)predownloadModel:(TTAdShareBoardModel*)model
{
    if (!model) {
        return;
    }
    
    if (model.data.ad_item&&model.data.ad_item.count>0) {
        TTAdShareBoardItemModel* itemModel = model.data.ad_item.firstObject;
        [TTAdShareManager predownloadImage:itemModel];
    }
    
}

+ (void)predownloadImage:(TTAdShareBoardItemModel*)model
{
    TTNetworkFlags flag = TTAdNetworkGetFlags();
    if (!(flag & model.predownload.integerValue)){
        return;
    }
    
    if (model.image_list&&model.image_list.count>0) {
        TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithDictionary:[model.image_list.firstObject toDictionary]];
        [TTAdShareManager startDownloadImageWithImageInfoModel:imageModel index:0];
    }
}

//不关注predownload字段,直接下载
+ (void)downloadImage:(TTAdShareBoardItemModel*)model
{
    if (model.image_list&&model.image_list.count>0) {
        TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithDictionary:[model.image_list.firstObject toDictionary]];
        [TTAdShareManager startDownloadImageWithImageInfoModel:imageModel index:0];
    }
}

+ (void)startDownloadImageWithImageInfoModel:(TTImageInfosModel *)imageInfoModel index:(NSUInteger)index {
    
    NSString *urlString = [imageInfoModel urlStringAtIndex:index];
    if (isEmptyString(urlString)) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
        [extra setValue:imageInfoModel.URI forKey:@"image_uri"];
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:imageInfoModel.urlWithHeader options:0 error:&error];
        NSString *urlsJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [extra setValue:urlsJSON forKey:@"image_urls"];
        [extra setValue:@"ad_sharePanel" forKey:@"source"];
        [TTAdMonitorManager trackService:@"ad_splashpreload_imagefailure" status:3 extra:extra];
        return;
    }
    if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageInfoModel]) {
        return;
    }
    __block NSUInteger _index = index;
   
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
       
        if (error) {
            [TTAdShareManager startDownloadImageWithImageInfoModel:imageInfoModel index:++_index];
            return;
        }
        
        if (obj && [obj isKindOfClass:[NSData class]]) {
            [[SSSimpleCache sharedCache] setData:(NSData *)obj forImageInfosModel:imageInfoModel];
        }
    }];
}


+ (void)saveShareBoardModel:(TTAdShareBoardModel*)model
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:model];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:data forKey:kTTAdShareManagerModelKey];
    [userDefault synchronize];
}

+ (void)clearShareCache
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:kTTAdShareManagerModelKey];
    [userDefault synchronize];
}

+ (TTAdShareBoardModel*)getShareBoardModel
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSData* data = [userDefault objectForKey:kTTAdShareManagerModelKey];
    if (!data) {
        return nil;
    }
    TTAdShareBoardModel* model = nil;
    @try {
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        NSLog(@"TTAdShareManager unarchieve:%@",exception.description);
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        if (exception&&!isEmptyString(exception.description)) {
            [dict setValue:exception.description forKey:@"unarchiveerror"];
        }
        [TTAdMonitorManager trackService:@"shareboard_unarchiveerror" status:0 extra:dict];
    } @finally {
        
    }
    
    if (!model||![model isKindOfClass:[TTAdShareBoardModel class]]) {
        return nil;
    }
    return model;
}

+ (BOOL)showShareAd
{
    //1.判断是ipad,或者小屏,则不出广告
    if ([TTDeviceHelper isPadDevice]||[UIScreen mainScreen].bounds.size.height==480) {
        return NO;
    }
    //2.判断是横屏,则不出广告
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation) == YES) {
        return NO;
    }
    //3.判断在广告详情页,不出分享板广告
    if ([TTAdShareManager sharedManager].inAdPage == YES) {
        return NO;
    }
    TTAdShareBoardModel* model = [self getShareBoardModel];
    TTAdShareBoardDataModel* dataModel = model.data;
    //4.缓存清除不出
    if (!model||!dataModel) {
        return NO;
    }
    if (model.data.ad_item&&model.data.ad_item.count>0) {
        TTAdShareBoardItemModel* itemModel = model.data.ad_item.firstObject;
        //5.字段异常的保护
        if (!itemModel.image_list||itemModel.image_list.count==0) {
            return NO;
        }
        if (![itemModel.image_list.firstObject isKindOfClass:[TTAdImageModel class]]) {
            return NO;
        }
        
        TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithDictionary:[itemModel.image_list.firstObject toDictionary]];
        //6.无图片缓存不出
        if (![[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageModel]) {
            [TTAdShareManager downloadImage:itemModel];
            return NO;
        }
        
        NSDate* date = [NSDate date];
        //7.判断未过用户删除广告的静默期
        if (!dataModel.closeShowTime) {
            //开始时间晚于现在
            if ([itemModel.startTime compare:date] == NSOrderedDescending){
                return NO;
            }
            //8.判断是否在开始结束的展现期内
            //结束早于现在
        if ([itemModel.endTime compare:date] == NSOrderedAscending){
                return NO;
            }
            return YES;
        }
        else{
            //静默解除时间晚于现在
            if ([dataModel.closeShowTime compare:date] == NSOrderedDescending) {
                return NO;
            }
            else
            {
                //开始晚于现在
                if ([itemModel.startTime compare:date] == NSOrderedDescending) {
                    return NO;
                }
                //结束早于现在
                if ([itemModel.endTime compare:date] == NSOrderedAscending) {
                    return NO;
                }
                return YES;
            }
        }
        
    }
    return NO;
}

+ (TTAdShareBoardView*)createShareViewFrame:(CGRect)frame
{
    TTAdShareBoardModel* model = [self getShareBoardModel];
    if ([self showShareAd] == YES) {
        if (model.data&&model.data.ad_item&&model.data.ad_item.count>0) {
            TTAdShareBoardItemModel* itemModel = model.data.ad_item[0];
            TTAdShareBoardView* shareView = [[TTAdShareBoardView alloc] initWithFrame:frame model:model.data];
            if (shareView) {
                [[TTAdShareManager sharedManager] trackShareAdWithTag:@"share_ad" label:@"show"];
                TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[itemModel.ID stringValue] logExtra:itemModel.log_extra];
                ttTrackURLsModel(itemModel.track_url_list, trackModel);
            }
            return shareView;
        }
    }
    return nil;
}

+ (void)closeShareAd:(BOOL)close
{
    if (close == YES) {
        TTAdShareBoardModel* model = [self getShareBoardModel];
        if (model.data) {
            [model.data updateShowCloseTime];
            [self saveShareBoardModel:model];
        }
        [[TTAdShareManager sharedManager] trackShareAdWithTag:@"share_ad" label:@"close"];
    }
}

- (void)showInAdPage:(NSString*)adId groupId:(NSString*)groupId
{
    if (!isEmptyString(adId)&&adId.longLongValue>0) {
        self.inAdPage = YES;
    }
    else
    {
        self.inAdPage = NO;
    }
    self.groupId = groupId;
}

- (void)hideInPage
{
    self.inAdPage = NO;
    self.groupId = nil;
}

//注意,实时回收分享广告,会清除整条广告数据
+ (void)realTimeRemoveAd:(NSArray*)adIds
{
    if (SSIsEmptyArray(adIds)) {
        return;
    }
    TTAdShareBoardModel* model = [TTAdShareManager getShareBoardModel];
    [adIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* adId = (NSString*)obj;
        if (!isEmptyString(adId)) {
            if (model.data.ad_item&&model.data.ad_item.count>0) {
                TTAdShareBoardItemModel* itemModel = model.data.ad_item.firstObject;
                if ([itemModel.ID.stringValue isEqualToString:adId]) {
                    [TTAdShareManager clearShareCache];
                    return;
                }
            }
        }
    }];
}


-(void)trackShareAdWithTag:(NSString*)tag label:(NSString*)label
{
    if (self.model.data.ad_item&&self.model.data.ad_item.count>0) {
        TTAdShareBoardItemModel* itemModel = self.model.data.ad_item.firstObject;
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:itemModel.log_extra forKey:@"log_extra"];
        [dict setValue:!isEmptyString(self.groupId)? self.groupId:@"0" forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        if (!isEmptyString(itemModel.ID.stringValue)&&!isEmptyString(itemModel.log_extra)) {
            [TTAdTrackManager trackWithTag:tag label:label value:itemModel.ID.stringValue extraDic:dict];
            
        }
    }
}


@end
