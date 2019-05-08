//
//  TTAdDetailViewHelper.m
//  Article
//
//  Created by carl on 2017/6/12.
//
//

#import "TTAdDetailViewHelper.h"

#import "ArticleDetailADModel.h"
#import "TTAdMonitorManager.h"

const NSErrorDomain tt_adDetailNatantErrorDomain = @"toutiao.ad.natantView";

@interface TTAdDetailViewHelper ()
@end

static NSMutableDictionary<NSString *, Class> *adViewClasses;

@implementation TTAdDetailViewHelper

+ (void)registerViewClass:(Class)viewClass withKey:(NSString *)key forArea:(TTAdDetailViewArea)area {
    NSParameterAssert(viewClass != nil);
    NSParameterAssert(key != nil && key.length > 0);
    
    if (!adViewClasses) {
        adViewClasses = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    NSString *viewKey = [NSString stringWithFormat:@"%@_%@", @(area), key];
    [adViewClasses setValue:viewClass forKey:viewKey];
}

+ (Class)classForKey:(NSString *)key forArea:(TTAdDetailViewArea)area {
    NSString *viewKey = [NSString stringWithFormat:@"%@_%@", @(area), key];
    return adViewClasses[viewKey];
}

+ (NSDictionary *)classesForArea:(TTAdDetailViewArea)area {
    NSMutableDictionary<NSString *, Class> *mapper = [NSMutableDictionary dictionary];
    NSString *prefix = [NSString stringWithFormat:@"%@_", @(area)];
    [adViewClasses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key hasPrefix:prefix]) {
            key = [key substringFromIndex:prefix.length];
            mapper[key] = obj;
        }
    }];
    return mapper;
}

#pragma mark -

+ (NSString *)viewKeyByAdModel:(ArticleDetailADModel *)adModel with:(NSString *)adName {
    ArticleDetailADModelType type = adModel.detailADType;
    NSString *viewKey = adName;
    const NSArray<NSString *> * const diplayTypes = @[@"leftPic", @"video", @"largePic", @"groupPic"];
    //const BOOL *is_tongtou = adModel.isTongTouAd; 视频
    
    if (type == ArticleDetailADModelTypeMixed) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) { // displaySubtype = 1 , 2, 3, 4
            viewKey = [NSString stringWithFormat:@"mixed_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    } else if (type == ArticleDetailADModelTypeCounsel ||
               type == ArticleDetailADModelTypeApp ||
               type == ArticleDetailADModelTypePhone ||
               type == ArticleDetailADModelTypeAppoint) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) {
            viewKey = [NSString stringWithFormat:@"unify_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    }
    return viewKey;
}

+ (NSString *)articleViewKeyByModel:(ArticleDetailADModel *)adModel with:(NSString *)adName {
    ArticleDetailADModelType type = adModel.detailADType;
    NSString *viewKey = adName;
    const NSArray<NSString *> * const diplayTypes = @[@"leftPic", @"video", @"largePic", @"groupPic"];
    if(type == ArticleDetailADModelTypeMixed) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) { // displaySubtype = 1 , 2, 3, 4
            viewKey = [NSString stringWithFormat:@"mixed_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    } else if (type == ArticleDetailADModelTypeApp) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) { // displaySubtype = 1 , 2, 3, 4
            viewKey = [NSString stringWithFormat:@"app_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    } else if (type == ArticleDetailADModelTypePhone) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) { // displaySubtype = 1 , 2, 3, 4
            viewKey = [NSString stringWithFormat:@"phone_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    } else if (type == ArticleDetailADModelTypeAppoint) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1)
        { // displaySubtype = 1 , 2, 3, 4
            viewKey = [NSString stringWithFormat:@"appoint_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    } else if (type == ArticleDetailADModelTypeCounsel) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) {
            viewKey = [NSString stringWithFormat:@"unify_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    }
    return viewKey;
}

+ (NSString *)videoViewKeyByModel:(ArticleDetailADModel *)adModel with:(NSString *)adName {
    NSInteger type = adModel.detailADType;
    NSString *viewKey = adName;
    const NSArray<NSString *> * const diplayTypes = @[@"leftPic", @"video", @"largePic", @"groupPic"];
    if(type == ArticleDetailADModelTypeMixed) {
        switch (adModel.displaySubtype) {
            case 1:
                viewKey = @"video_mixed_leftPic";
                break;
            case 2:
                viewKey = @"mixed_video";
                break;
            case 3:
                viewKey = adModel.isTongTouAd ? @"video_mixed_largePic" : @"video_mixed_ununify_largePic";
                break;
            case 4:
                viewKey = @"video_mixed_groupPic";
                break;
            default:
                break;
        }
    } else if (type == ArticleDetailADModelTypeApp) {
        switch (adModel.displaySubtype) {
            case 1:
                viewKey = @"video_app_leftPic";
                break;
            case 2:
                viewKey = @"app_video";
                break;
            case 3:
                viewKey = @"video_app_largePic";
                break;
            case 4:
                viewKey = @"video_app_groupPic";
                break;
            default:
                break;
        }
    } else if (type == ArticleDetailADModelTypePhone) {
        switch (adModel.displaySubtype) {
            case 1:
                viewKey = @"video_phone_leftPic";
                break;
            case 2:
                viewKey = @"phone_video";
                break;
            case 3:
                viewKey = @"video_phone_largePic";
                break;
            case 4:
                viewKey = @"video_phone_groupPic";
                break;
            default:
                break;
        }
    } else if (type == ArticleDetailADModelTypeCounsel) {
        if (adModel.displaySubtype <= diplayTypes.count && adModel.displaySubtype >= 1) {
            viewKey = [NSString stringWithFormat:@"video_unify_%@", diplayTypes[adModel.displaySubtype - 1]];
        }
    }
    return viewKey;
}

+ (NSInteger)typeWithADKey:(NSString *)adName {
   const NSDictionary * const mappings = @{
                               @"banner"    :@(ArticleDetailADModelTypeBanner),
                               @"image"     :@(ArticleDetailADModelTypeImage),
                               @"app"       :@(ArticleDetailADModelTypeApp),
                               @"mixed"     :@(ArticleDetailADModelTypeMixed),
                               @"media"     :@(ArticleDetailADModelTypeMedia),
                               @"phone"     :@(ArticleDetailADModelTypePhone),
                               @"form"      :@(ArticleDetailADModelTypeAppoint),
                               @"counsel"   :@(ArticleDetailADModelTypeCounsel)
                               };
    if ([mappings valueForKey:adName]) {
        return [mappings[adName] integerValue];
    }
    return NSNotFound;
}

+ (NSArray<ArticleDetailADModel *> *)detailAdModelsWithDictionary:(NSDictionary *)JSONData error:(NSError **)error {
    if (!([JSONData isKindOfClass:[NSDictionary class]] || JSONData.count <= 0)) {
        if (*error) {
            *error = [NSError errorWithDomain:tt_adDetailNatantErrorDomain code:401 userInfo:@{NSLocalizedDescriptionKey : @"数据内容为空 或者 nil"}];
        }
        return nil;
    }
    NSMutableArray *adModels = [NSMutableArray arrayWithCapacity:JSONData.count];
    [JSONData enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]] && obj.count > 0) {
            BOOL isValidModel = NO;
            NSInteger type = [TTAdDetailViewHelper typeWithADKey:key];
            if (type != NSNotFound) {
                ArticleDetailADModel *adModel = [[ArticleDetailADModel alloc] initWithDictionary:obj detailADType:(ArticleDetailADModelType)type];
                adModel.key = [TTAdDetailViewHelper viewKeyByAdModel:adModel with:key];
                
                if ([adModel isModelAvailable]) {
                    [adModels addObject:adModel];
                    isValidModel = YES;
                }
            }
        }
    }];
    
    if (adModels.count < 1) {
        if (*error) {
            NSString *metaData = [NSString stringWithFormat:@"%@ ", JSONData];
            *error = [NSError errorWithDomain:tt_adDetailNatantErrorDomain code:401 userInfo:@{NSLocalizedDescriptionKey : metaData}];
        }
    }
    return [adModels copy];
}

+ (BOOL)detailBannerIsUnityAd:(NSDictionary *)adData {
    return [self newADModelsWithJSONData:adData];
}

+ (BOOL)newADModelsWithJSONData:(NSDictionary *)JSONData {
    if (![JSONData isKindOfClass:[NSDictionary class]] || JSONData.count <= 0) {
        return NO;
    }
    __block BOOL isUnity = NO;
    [JSONData enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]] && obj.count > 0) {
            NSInteger type = [TTAdDetailViewHelper typeWithADKey:key];
            if (type != NSNotFound) {
                ArticleDetailADModel *adModel = [[ArticleDetailADModel alloc] initWithDictionary:obj detailADType:(ArticleDetailADModelType)type];
                if(type == ArticleDetailADModelTypeMixed) {
                    switch (adModel.displaySubtype) {
                        case 1:
                            isUnity = YES;
                            break;
                        case 2:
                            isUnity = NO;
                            break;
                        case 3:{
                            isUnity = adModel.isTongTouAd;
                        }
                            break;
                        case 4:
                            isUnity = YES;
                            break;
                        default:
                            break;
                    }
                } else if (type == ArticleDetailADModelTypeApp ||
                           type == ArticleDetailADModelTypePhone||
                           type == ArticleDetailADModelTypeAppoint) {
                    switch (adModel.displaySubtype) {
                        case 1:
                            isUnity = YES;
                            break;
                        case 2:
                            isUnity = NO;
                            break;
                        case 3:
                            isUnity = YES;
                            break;
                        case 4:
                            isUnity = YES;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }];
    return isUnity;
}

@end

