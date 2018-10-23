//
//  TTAdPhotoAlbumManager.m
//  Article
//
//  Created by yin on 16/8/4.
//
//

#import "TTAdPhotoAlbumManager.h"
#import "TTURLTracker.h"
#import "SSADActionManager.h"
#import <TTImage/TTWebImageManager.h>
#import "TTAdTrackManager.h"
#import "TTAdMonitorManager.h"
#import <TTTracker/TTTrackerProxy.h>

@interface TTAdPhotoAlbumManager()

@property (nonatomic, strong, readwrite) TTPhotoDetailAdModel* photoDetailAdModel;
@property (nonatomic, strong, readwrite) UIImage* adImage; //预下载的广告图片
@property (nonatomic, assign)            BOOL isNativePhotoAlbum;
@end

@implementation TTAdPhotoAlbumManager

+ (void)load
{
    [[TTAdSingletonManager sharedManager] registerSingleton:[TTAdPhotoAlbumManager sharedManager] forKey:NSStringFromClass([self class])];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isNativePhotoAlbum = YES;
    }
    return self;
}

+ (instancetype)sharedManager{
    static TTAdPhotoAlbumManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)isNativePhotoAlbum:(BOOL)isNative
{
    self.isNativePhotoAlbum = isNative;
}

-(void)fetchPhotoDetailAdModel:(TTPhotoDetailAdModel*)model;
{
    //每次进图集都讲缓存的adImage置为空
    if (self.photoDetailAdModel) {
        self.photoDetailAdModel = nil;
    }
    
    if (self.adImage) {
        self.adImage = nil;
    }
    
    if (model && model.image_recom) {
        
        if ([TTDeviceHelper isPadDevice] && model.image_recom.display_type.longValue != TTPhotoDetailAdDisplayType_Default) {
            return;
        }
        
        self.photoDetailAdModel = model;
        //加载新的广告时，先清除之前广告图片
        self.adImage = nil;
        //如果不是native图则不下载图片
        if (self.isNativePhotoAlbum == NO) {
            return;
        }
        [self downloadPageImage];
    }
}

- (void)fetchPhotoDetailAdModelDict:(NSDictionary *)dict
{
    //每次进图集都将缓存的adImage置为空
    if (self.photoDetailAdModel) {
        self.photoDetailAdModel = nil;
    }
    
    if (self.adImage) {
        self.adImage = nil;
    }
    
    TTPhotoDetailAdModel* model = [[TTPhotoDetailAdModel alloc] initWithDictionary:dict error:nil];
    if (model && model.image_recom) {
        if ([TTDeviceHelper isPadDevice] && model.image_recom.display_type.longValue != TTPhotoDetailAdDisplayType_Default) {
            return;
        }
        
        self.photoDetailAdModel = model;
        //加载新的广告时，先清除之前广告图片
        self.adImage = nil;
        //如果不是native图则不下载图片
        if (self.isNativePhotoAlbum == NO) {
            return;
        }
        [self downloadPageImage];
    }
}

-(void)downloadPageImage
{
    //用url请求Image,url_list的三次失败重试机制
    NSMutableArray* imageUrlList = [[NSMutableArray alloc] init];

    TTAdImageModel* imageModel;
    if (self.photoDetailAdModel.image_recom.image_list && self.photoDetailAdModel.image_recom.image_list.count > 0) {
        imageModel = [self.photoDetailAdModel.image_recom.image_list objectAtIndex:0];
    }
    else if (self.photoDetailAdModel.image_recom.image){
        imageModel = self.photoDetailAdModel.image_recom.image;
    }
    
    if (imageModel && !isEmptyString(imageModel.url)) {
        [imageUrlList addObject:imageModel.url];
    }
    for (TTPhotoDetailAdUrlListModel* urlItem in imageModel.url_list) {
        if (!isEmptyString(urlItem.url)) {
            [imageUrlList addObject:urlItem.url];
        }
    }
    
    [self downloadPageImage:imageUrlList index:0];
}

-(void)downloadPageImage:(NSArray*)urlList index:(NSInteger)index
{
    WeakSelf;
    __block NSInteger newIndex = index;
    if (newIndex >= urlList.count) {
        return;
    }
    [[TTWebImageManager shareManger] downloadImageWithURL:urlList[index] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
        StrongSelf;
        if (error) {
            //递归重试
            [self downloadPageImage:urlList index:++newIndex];
            if (newIndex == urlList.count-1) {
                TTPhotoDetailAdImageRecomModel* model = self.photoDetailAdModel.image_recom;
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
                [dict setValue:model.log_extra forKey:@"log_extra"];
                [dict setValue:model.ID forKey:@"ad_id"];
                
                [TTAdMonitorManager trackService:@"ad_photoAlbum_imageDownload_fail" status:0 extra:dict];
            }
        }
        else //递归结束
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                StrongSelf;
                self.adImage = image;
                if (self.delegate && [self.delegate respondsToSelector: @selector(photoAlbum_downloadAdImageFinished)]) {
                    [self.delegate photoAlbum_downloadAdImageFinished];
                }
                [self trackAdImageFinishLoad];
            });
        }
    }];
}


-(TTPhotoDetailAdModel*)photoDetailAdModel
{
    return _photoDetailAdModel;
}

-(TTPhotoDetailAdDisplayType)getPhotoDetailADDisplayType{
    
    if (_photoDetailAdModel && _photoDetailAdModel.image_recom ) {
        if (_photoDetailAdModel.image_recom.display_type.longValue == 1) {
            return TTPhotoDetailAdDisplayType_SmallImage;
        }
        
        else if (_photoDetailAdModel.image_recom.display_type.longValue == 2){
            return TTPhotoDetailAdDisplayType_BigImage;
        }
        
        else if (_photoDetailAdModel.image_recom.display_type.longValue == 3){
            return TTPhotoDetailAdDisplayType_GroupImage;
        }
    }
    return TTPhotoDetailAdDisplayType_Default;
    
}


-(BOOL)hasFinishDownloadAdImage
{
    return (self.adImage == nil)? NO:YES;
}


//请先提前判断hasFinishDownloadAdImage
-(UIImage*)getAdImage
{
    if ([TTDeviceHelper isPadDevice] && self.photoDetailAdModel && self.photoDetailAdModel.image_recom && self.photoDetailAdModel.image_recom.display_type.longValue!= TTPhotoDetailAdDisplayType_Default) {
        
        return nil;
    }
   
    if (self.adImage) {
        return self.adImage;
    }
    else return nil;
}

-(NSString*)getImagePageTitle
{
    NSString* title = self.photoDetailAdModel.image_recom.label;
    return isEmptyString(title)? @"广告": title;
}

-(BOOL)hasPhotoDetailAd
{
    if ([TTDeviceHelper isPadDevice] && self.photoDetailAdModel && self.photoDetailAdModel.image_recom && self.photoDetailAdModel.image_recom.display_type.longValue!= TTPhotoDetailAdDisplayType_Default) {
        
        return NO;
    }
    
    return self.adImage == nil? NO:YES;
}

-(TTPhotoDetailAdCollectionCell*)cellForPhotoDetailAd
{
    return nil;
}

- (void)adImageClickWithResponder:(UIResponder*)responder
{
 
    if (!self.photoDetailAdModel || !self.photoDetailAdModel.image_recom) {
        return;
    }
    

    if (self.photoDetailAdModel.image_recom.adActionType == TTPhotoDetailAdActionType_App) {
        
        [[SSADActionManager sharedManager] handlePhotoAlbumAppActionForADModel:self.photoDetailAdModel];
        
    }
    
    else {
        
        [[SSADActionManager sharedManager] handlePhotoAlbumBackgroundWebModel:self.photoDetailAdModel WithResponder:responder];
        
    }
    

     [self trackAdImageClick];
   
}

-(void)adCreativeButtonClickWithModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder{
    
    if (!adModel || !adModel.image_recom) {
        return;
    }

    if (adModel.image_recom.adActionType == TTPhotoDetailAdActionType_App) {
        
        [[SSADActionManager sharedManager] handlePhotoAlbumAppActionForADModel:adModel];
        [self trackDownloadClick];
        
        
    }
    else if (adModel.image_recom.adActionType == TTPhotoDetailAdActionType_Action) {

        [[SSADActionManager sharedManager] handlePhotoAlbumPhoneActionModel:adModel];
        [self trackPhoneCallButtonClick];
        
    }
    else if (adModel.image_recom.adActionType == TTPhotoDetailAdActionType_Web){
        
        //此处为容错处理，没有上报event事件
        [[SSADActionManager sharedManager] handlePhotoAlbumButtondWebModel:adModel WithResponder:responder];
    }
    
    else {
        
        [TTAdMonitorManager trackService:@"ad_photoAlbum_url_dataActionType_Error" status:0 extra:self.photoDetailAdModel.image_recom.mointerInfo];
    }
    
//    TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
//    adBaseModel.ad_id = [self photoDetailAdModel].image_recom.ID;
//    adBaseModel.log_extra = [self photoDetailAdModel].image_recom.log_extra;
//    ssTrackURLsModel([self photoDetailAdModel].image_recom.click_track_url_list,adBaseModel);
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self photoDetailAdModel].image_recom.ID logExtra:[self photoDetailAdModel].image_recom.log_extra];
    ttTrackURLsModel([self photoDetailAdModel].image_recom.click_track_url_list, trackModel);
    
}

- (void)trackAdImageShow
{
    //新增图集广告show事件
    if (self.photoDetailAdModel && self.photoDetailAdModel.image_recom && self.photoDetailAdModel.image_recom.display_type.longValue != TTPhotoDetailAdDisplayType_Default) {
        
        //拨打电话创意广告show事件
        if (self.photoDetailAdModel && self.photoDetailAdModel.image_recom && self.photoDetailAdModel.image_recom.adActionType == TTPhotoDetailAdActionType_Action) {
            [self trackAdWithTag:@"detail_call" label:@"show"];
        }
        
        //其他类型show事件
        else {
            [self trackAdWithTag:@"detail_ad" label:@"show"];
        }
        
    }
    
    //原图集广告show事件
    else {
         [self trackAdWithTag:@"embeded_ad" label:@"show"];
    }
    
    //发送track_url请求
//    TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
//    adBaseModel.ad_id = [self photoDetailAdModel].image_recom.ID;
//    adBaseModel.log_extra = [self photoDetailAdModel].image_recom.log_extra;
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self photoDetailAdModel].image_recom.ID logExtra:[self photoDetailAdModel].image_recom.log_extra];
    if ([self photoDetailAdModel].image_recom.track_url_list && [self photoDetailAdModel].image_recom.track_url_list.count > 0) {
        ttTrackURLsModel([self photoDetailAdModel].image_recom.track_url_list, trackModel);
//        ssTrackURLsModel([self photoDetailAdModel].image_recom.track_url_list,adBaseModel);
    }
    else {
        if ([self photoDetailAdModel].image_recom.track_url) {
//            ssTrackURLsModel([NSArray arrayWithObject:[self photoDetailAdModel].image_recom.track_url],adBaseModel);
            ttTrackURLModel([self photoDetailAdModel].image_recom.track_url, trackModel);
        }
    }
    
}

- (void)trackAdImageFinishLoad
{
    if (self.photoDetailAdModel && self.photoDetailAdModel.image_recom && self.photoDetailAdModel.image_recom.display_type.longValue != TTPhotoDetailAdDisplayType_Default) {
        //不添加load_finish事件
    }
    else {
        [self trackAdWithTag:@"embeded_ad" label:@"load_finish"];
    }
}

- (void)trackAdImageClick
{
    //新增图集广告点击事件
    if (self.photoDetailAdModel && self.photoDetailAdModel.image_recom && self.photoDetailAdModel.image_recom.display_type.longValue != TTPhotoDetailAdDisplayType_Default) {
        
        //点击下载背景,此处为click事件，其他事件在处理内部已上报
        if (self.photoDetailAdModel.image_recom.adActionType == TTPhotoDetailAdActionType_App) {
            [self trackDownloadClick];
        }
        //点击打电话背景
        else if (self.photoDetailAdModel.image_recom.adActionType == TTPhotoDetailAdActionType_Action){
            
            [self trackAdWithTag:@"detail_call" label:@"click"];
            [self trackAdWithTag:@"detail_call" label:@"detail_show"];
        }
        
        //点击普通图片背景
        else {
            
            [self trackAdWithTag:@"detail_ad" label:@"click"];
            [self trackAdWithTag:@"detail_ad" label:@"ad_content"];
            [self trackAdWithTag:@"detail_ad" label:@"detail_show"];
            
        }
    }
    
    //原先图集广告点击事件
    else {
        [self trackAdWithTag:@"embeded_ad" label:@"click"];
    }
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self photoDetailAdModel].image_recom.ID logExtra:[self photoDetailAdModel].image_recom.log_extra];
//    TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
//    adBaseModel.ad_id = [self photoDetailAdModel].image_recom.ID;
//    adBaseModel.log_extra = [self photoDetailAdModel].image_recom.log_extra;
//    ssTrackURLsModel([self photoDetailAdModel].image_recom.click_track_url_list,adBaseModel);
    ttTrackURLsModel([self photoDetailAdModel].image_recom.click_track_url_list, trackModel);
}

//点击创意下载按钮
-(void)trackDownloadClick{
    [self trackRealTimeDownload];
    [self trackAdWithTag:@"detail_ad" label:@"click" extraValue:@{@"has_v3": @"1"}];
}

//点击创意下载按钮／背景，走appstore
-(void)trackDownloadClickToAppstore{
    [self trackAdWithTag:@"detail_download_ad" label:@"click_start" ];
}


//点击创意下载按钮／背景，走应用打开
-(void)trackDownloadClickToOpenApp{
    [self trackAdWithTag:@"detail_download_ad" label:@"open"];
}

//点击创意拨打电话按钮
-(void)trackPhoneCallButtonClick{
    [self trackAdWithTag:@"detail_call" label:@"click"];
    [self trackAdWithTag:@"detail_call" label:@"click_call"];
}

-(void)trackAdWithTag:(NSString*)tag
                label:(NSString*)label
{
    TTPhotoDetailAdImageRecomModel* recomModel = self.photoDetailAdModel.image_recom;
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:recomModel.log_extra forKey:@"log_extra"];
    [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    [dict setValue:recomModel.ID forKey:@"ad_id"];
    if (!isEmptyString(recomModel.ID)) {
        [TTAdTrackManager trackWithTag:tag label:label value:recomModel.ID extraDic:dict];
    }
}

-(void)trackAdWithTag:(NSString*)tag
                label:(NSString*)label
           extraValue:(NSDictionary *)extra
{
    TTPhotoDetailAdImageRecomModel* recomModel = self.photoDetailAdModel.image_recom;
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:recomModel.log_extra forKey:@"log_extra"];
    [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    [dict setValue:recomModel.ID forKey:@"ad_id"];
    [dict addEntriesFromDictionary:extra];
    if (!isEmptyString(recomModel.ID)) {
        [TTAdTrackManager trackWithTag:tag label:label value:recomModel.ID extraDic:dict];
    }
}

-(void)trackWithTag:(NSString *)tag
              label:(NSString *)label
              value:(NSString *)value
           extraDic:(NSDictionary *)dic
{
    wrapperTrackEventWithCustomKeys(tag, label, value, nil, dic);
}

- (void)trackRealTimeDownload
{
    TTPhotoDetailAdImageRecomModel* recomModel = self.photoDetailAdModel.image_recom;
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:recomModel.ID forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:recomModel.log_extra forKey:@"log_extra"];
    [params setValue:@"2" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

@end
