//
//  ArticleDetailADModel.m
//  Article
//
//  Created by Zhang Leonardo on 14-2-20.
//
//

#import "ArticleDetailADModel.h"

#import "NSDictionary+TTAdditions.h"
#import "TTURLTracker.h"
#import "TTTrackerProxy.h"

const NSInteger GroupImageCount = 3;

@implementation ArticleDetailADModel
@dynamic adPlayTrackUrls;
@dynamic adPlayActiveTrackUrls;
@dynamic adPlayEffectiveTrackUrls;
@dynamic adPlayOverTrackUrls;
@dynamic effectivePlayTime;

- (instancetype)initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        self.labelString = [data tt_objectForKey:@"label"];
        self.titleString = [data tt_objectForKey:@"title"];
        self.imageURLString = [data tt_objectForKey:@"image"];
        self.descString = [data tt_objectForKey:@"description"];
        self.log_extra = [data tt_objectForKey:@"log_extra"];
        self.imageWidth = [data tt_floatValueForKey:@"image_width"];
        self.imageHeight = [data tt_floatValueForKey:@"image_height"];
        self.sourceString = [data tt_stringValueForKey:@"source_name"]; //5.5创意通投Mixed中加入该字段
        self.displaySubtype = [data tt_integerValueForKey:@"display_subtype"];
        self.isTongTouAd = [data tt_intValueForKey:@"is_tongtou_ad"];
        self.buttonText = [data tt_stringValueForKey:@"button_text"];
        self.adPlayTrackUrls = [data tt_arrayValueForKey:kPlayerTrackUrlList];
        self.adPlayActiveTrackUrls = [data tt_arrayValueForKey:kPlayerActiveTrackUrlList];
        self.adPlayEffectiveTrackUrls = [data tt_arrayValueForKey:kPlayerEffectiveTrackUrlList];
        self.adPlayOverTrackUrls = [data tt_arrayValueForKey:kPlayerOverTrackUrlList];
        self.effectivePlayTime = [data tt_floatValueForKey:kEffectivePlayTime];
        NSDictionary *videoDict = [data tt_dictionaryValueForKey:@"video_info"];
        if (videoDict) {
            self.videoInfo = [[ArticleDetailADVideoModel alloc] initWithDictionary:videoDict error:nil];
        }
        //added 5.7: 组图广告数据
        NSArray *imageList = [data tt_arrayValueForKey:@"image_list"];
        if (imageList) {
            self.imageList = imageList;
        }
        self.filterWords = [data tt_arrayValueForKey:@"filter_words"];
        self.showDislike = [data tt_integerValueForKey:@"show_dislike"];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)data detailADType:(ArticleDetailADModelType)type
{
    self = [self initWithDictionary:data];
    if (self) {
        self.detailADType = type;
        if (type == ArticleDetailADModelTypeApp) {
            //app下载类型广告
            self.downloadCount = data[@"download_count"];
            self.appSize = data[@"app_size"];
        } else if (type == ArticleDetailADModelTypeCounsel) {
            self.formUrl = [data tt_stringValueForKey:@"form_url"];
        } else if (type == ArticleDetailADModelTypePhone) {
            self.mobile = [data tt_stringValueForKey:@"phone_number"];
            self.dailActionType = @([data tt_intValueForKey:@"dial_action_type"]);
        } else if (type == ArticleDetailADModelTypeMedia) {
            self.mediaID = [data tt_stringValueForKey:@"id"];
        } else if (type == ArticleDetailADModelTypeAppoint) {
            self.buttonText = [data tt_stringValueForKey:@"button_text"];
            self.formUrl = [data tt_stringValueForKey:@"form_url"];
            self.formSizeValid = @([data tt_integerValueForKey:@"use_size_validation"]);
            self.formHeight = @([data tt_integerValueForKey:@"form_height"]);
            self.formWidth = @([data tt_integerValueForKey:@"form_width"]);
        }
        if (data[@"image"]&&[data[@"image"] isKindOfClass:[NSDictionary class]]) {
            self.imageWidth = [[data[@"image"] objectForKey:@"width"] floatValue];
            self.imageHeight = [[data[@"image"] objectForKey:@"height"] floatValue];
            self.imageURLString = [[self tt_safeFirstObject:[data[@"image"] objectForKey:@"url_list"]] objectForKey:@"url"];
        }
    }
    return self;
}

- (void)sendTrackEventWithLabel:(NSString *)label
{
    [super sendTrackEventWithLabel:label eventName:@"detail_ad"];
}

- (BOOL)isModelAvailable {
    if (!self.ad_id || self.ad_id.longLongValue == 0) {
        return NO;
    }
    
    if (_detailADType == ArticleDetailADModelTypeBanner) {
        if (isEmptyString(_titleString) || isEmptyString(_descString) || isEmptyString(_imageURLString)) {
            return NO;
        }
    }
    if (_detailADType == ArticleDetailADModelTypeImage) {
        if (isEmptyString(_imageURLString) || self.imageWidth * self.imageHeight <= 0) {
            return NO;
        }
    }
    if (_detailADType == ArticleDetailADModelTypeApp) {
        if (isEmptyString(self.appName)) {
            return NO;
        }
    }
        
    if (![self isModelSubTypeAvailable]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isModelSubTypeAvailable
{
    if (self.displaySubtype == 4) {
        //组图广告
        if (isEmptyString(self.titleString)) {
            return NO;
        }
        
        if (self.imageList.count < GroupImageCount) {
            return NO;
        }
        
        if (![self hasValidUrl]) {
            return NO;
        }
        
        if (![self hasValidName]) {
            return NO;
        }
        
        return YES;
    }
    return YES;
}

- (BOOL)hasValidUrl
{
    if (self.actionType == SSADModelActionTypeWeb) {
        return !isEmptyString(self.webURL);
    }
    else if (self.actionType == SSADModelActionTypeApp) {
        return !isEmptyString(self.download_url);
    }
    else {
        //TODO:check sdk adData
        return YES;
    }
}

- (BOOL)hasValidName
{
    if (self.actionType == SSADModelActionTypeWeb) {
        return !isEmptyString(self.sourceString);
    }
    else if (self.actionType == SSADModelActionTypeApp) {
        return !isEmptyString(self.appName);
    }
    else {
        //TODO:check sdk adData
        return YES;
    }
}

- (id)tt_safeFirstObject:(NSArray*)array
{
    if ([array isKindOfClass:[NSArray class]]&&array.count>0) {
        return array.firstObject;
    }
    return nil;
}

@end


@implementation ArticleDetailADModel (TTAdTracker)
- (void)sendTrackURLs:(NSArray<NSString *> *) urls {
    if (![urls isKindOfClass:[NSArray class]] || urls.count <= 0) {
        return;
    }
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.ad_id logExtra:self.log_extra];
    ttTrackURLsModel(urls, trackModel);
}

- (void)trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSCParameterAssert(tag != nil);
    NSCParameterAssert(label != nil);
    
    TTTrackerNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:self.ad_id forKey:@"value"];
    [events setValue:self.log_extra forKey:@"log_extra"];
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTrackerWrapper eventData:events];
}
@end

@implementation ArticleDetailADModel (TTDataHelper)

- (NSString *)sourceText {
     ArticleDetailADModelType creativeType = self.detailADType;
    if (creativeType == ArticleDetailADModelTypeApp) {
        return self.appName;
    }
    return self.sourceString;
}

- (NSString *)actionButtonText {
    if (!isEmptyString(self.buttonText)) {
        return self.buttonText;
    }
    ArticleDetailADModelType creativeType = self.detailADType;
    switch (creativeType) {
        case ArticleDetailADModelTypeCounsel:
            return NSLocalizedString(@"在线咨询", @"在线咨询");
            break;
        case ArticleDetailADModelTypeApp:
            return NSLocalizedString(@"立即下载", @"立即下载");
            break;
        case ArticleDetailADModelTypePhone:
            return NSLocalizedString(@"拨打电话", @"拨打电话");
            break;
        case ArticleDetailADModelTypeAppoint:
            return NSLocalizedString(@"立即预约", @"立即预约");
        case ArticleDetailADModelTypeMixed:
            return NSLocalizedString(@"查看详情", @"查看详情");
        default:
            break;
    }
    return nil;
}

- (NSString *)actionButtonIcon {
    ArticleDetailADModelType creativeType = self.detailADType;
    switch (creativeType) {
        case ArticleDetailADModelTypeCounsel:
            return @"detais_ad_counsel";
            break;
        case ArticleDetailADModelTypeApp:
            return @"download_ad_detais";
        default:
            break;
    }
    return nil;
}

@end

