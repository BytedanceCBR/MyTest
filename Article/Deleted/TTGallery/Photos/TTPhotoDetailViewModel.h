//
//  TTPhotoDetailViewModel.h
//  Article
//
//  Created by yuxin on 4/19/16.
//
//

#import <Foundation/Foundation.h>
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"

@interface TTPhotoDetailViewModel : NSObject

- (instancetype _Nonnull)initViewModel:(TTDetailModel * _Nonnull)model;

@property(nonatomic, strong ) ArticleInfoManager * _Nullable articleInfoManager;

- (void)tt_startFetchInformationWithFinishBlock:(TTArticleDetailFetchInformationBlock _Nonnull)block;

- (nullable NSURLRequest *)tt_requstForWebContentPhotoView:(UIView * _Nonnull)view;


/**
 info下发的反劫持 广告JS

 @return js
 */
- (nullable NSString *)infomationAntiHijackJS;

- (void)sendEvent4ImageRecommendShow;

- (void)sendEvent4ImageRecommendClick:(NSDictionary *)queryitems;
@end
