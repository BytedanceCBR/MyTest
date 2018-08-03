//
//  TTUGCSearchHashtagViewController.h
//  Article
//  搜索话题 Hashtag 列表
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//



#import "SSViewControllerBase.h"

@class FRPublishPostSearchHashtagStructModel;

/**
 * Hashtag 推荐排序策略
 */
typedef NS_ENUM(NSUInteger, TTHashtagSuggestOption) {
    TTHashtagSuggestOptionNormal     = 1,     // 出正常的UGC话题
    TTHashtagSuggestOptionShortVideo = 2,     // 小视频话题优先
};

@protocol TTUGCSearchHashtagTableViewDelegate <NSObject>

@optional

- (void)searchHashtagTableViewWillDismiss;
- (void)searchHashtagTableViewDidDismiss;
- (void)searchHashtagTableViewDidSelectedHashtag:(FRPublishPostSearchHashtagStructModel *)hashtagModel;

@end


@interface TTUGCSearchHashtagViewController : SSViewControllerBase

@property (nonatomic, weak) id <TTUGCSearchHashtagTableViewDelegate> delegate;
@property (nonatomic, assign) TTHashtagSuggestOption hashtagSuggestOption;

@end
