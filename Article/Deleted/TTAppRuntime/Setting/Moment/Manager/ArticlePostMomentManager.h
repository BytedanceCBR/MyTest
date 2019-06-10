//
//  ArticlePostMomentManager.h
//  Article
//
//  Created by Huaqing Luo on 13/1/15.
//
//

#import <Foundation/Foundation.h>
#import "ArticlePostMomentViewController.h"
#import "ExploreMomentDefine.h"


@protocol ArticlePostMomentManagerDelegate;

@interface ArticlePostMomentManager : NSObject

@property(nonatomic, weak)id<ArticlePostMomentManagerDelegate> delegate;

- (void)PostMomentWithContent:(NSString *)content ForumID:(long long)forumID AssetsImages:(NSArray *)assetsImages FromSource:(PostMomentSourceType)fromSource NeedForward:(NSInteger)needForward;
- (void)cancelAllOperations;
- (BOOL)isPosting;

@end

@protocol ArticlePostMomentManagerDelegate <NSObject>

@optional

- (void)postMomentManager:(ArticlePostMomentManager *)manager postFinishWithError:(NSError *)error;
- (void)postMomentManager:(ArticlePostMomentManager *)manager uploadImagesProgress:(NSNumber *)progress;

@end
