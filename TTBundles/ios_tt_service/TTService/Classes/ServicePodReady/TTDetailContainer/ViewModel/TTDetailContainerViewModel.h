//
//  TTDetailContainerViewModel.h
//  Article
//
//  Created by Ray on 16/3/31.
//
//

#import <Foundation/Foundation.h>
#import "ArticleDetailHeader.h"
#import "TTVArticleProtocol.h"
#import "TTRoute.h"
//#import "ExploreDetailManager.h"

typedef NS_ENUM(NSUInteger, ExploreDetailManagerFetchResultType)
{
    ExploreDetailManagerFetchResultTypeFailed = 0,
    ExploreDetailManagerFetchResultTypeDone,
    ExploreDetailManagerFetchResultTypeEndLoading,
    ExploreDetailManagerFetchResultTypeNoNetworkConnect,
};

typedef void(^FetchRemoteContentBlock)(ExploreDetailManagerFetchResultType type);

@class TTDetailModel;
@class Article;
@interface TTDetailContainerViewModel : NSObject <TTRouteInitializeProtocol>

@property (nonatomic, assign) NewsGoDetailFromSource fromSource;
@property (nonatomic, strong, nullable) TTDetailModel * detailModel;
@property(nonatomic, strong, nullable) NSString * categoryID;
@property(nonatomic, copy, nullable) FetchRemoteContentBlock fetchContentBlock;

- (nullable id)initWithArticle:(nullable id<TTVArticleProtocol>)tArticle
               source:(NewsGoDetailFromSource)source
            condition:(nullable NSDictionary *)condition;

- (nullable NSString *)classNameForSpecificDetailViewController:(NSError *_Nullable*_Nullable)error isFromNet:(BOOL)isFromNet;

- (void)fetchContentFromRemoteIfNeededWithComplete:(nullable FetchRemoteContentBlock)block;

- (BOOL)isImageDetail;
@end
