//
//  TTAdDetailViewHelper.h
//  Article
//
//  Created by carl on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ArticleDetailADModel.h"

typedef NS_ENUM(NSInteger, TTAdDetailViewArea) {
    TTAdDetailViewAreaGloabl    = 1,   //所有详情页可以共用视图
    TTAdDetailViewAreaArticle   = TTAdDetailViewAreaGloabl,
    TTAdDetailViewAreaVideo     = 2,
    TTAdDetailViewAreaWenDa     = TTAdDetailViewAreaArticle,
    TTAdDetailViewAreaUGC       = TTAdDetailViewAreaArticle
};

@interface TTAdDetailViewHelper : NSObject

+ (void)registerViewClass:(Class _Nonnull )viewClass withKey:(NSString *_Nonnull)key forArea:(TTAdDetailViewArea)area;
+ (Class _Nullable )classForKey:(NSString *_Nonnull)key forArea:(TTAdDetailViewArea)area;
+ (NSDictionary *_Nonnull)classesForArea:(TTAdDetailViewArea)area;


+ (NSString *_Nullable)viewKeyByAdModel:(ArticleDetailADModel *_Nullable)adModel with:(NSString *_Nullable)adName;
+ (NSString *_Nullable)articleViewKeyByModel:(ArticleDetailADModel *_Nullable)adModel with:(NSString *_Nullable)adName;
+ (NSString *_Nullable)videoViewKeyByModel:(ArticleDetailADModel *_Nullable)adModel with:(NSString *_Nullable)adName;

+ (NSInteger)typeWithADKey:(NSString *_Nullable)adName;
+ (NSArray<ArticleDetailADModel *> *_Nullable)detailAdModelsWithDictionary:(NSDictionary *_Nullable)JSONData error:(NSError *_Nullable *_Nullable)error;


+ (BOOL)detailBannerIsUnityAd:(NSDictionary *_Nullable)adData;
@end



