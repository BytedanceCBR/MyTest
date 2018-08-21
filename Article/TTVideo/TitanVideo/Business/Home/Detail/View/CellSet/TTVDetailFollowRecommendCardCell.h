//
//  TTVDetailFollowRecommendCardCell.h
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//
#import <Foundation/Foundation.h>
@class TTAlphaThemedButton;
@class TTFollowThemeButton;
@protocol TTVDetailRelatedRecommendCellViewModelProtocol;
@class TTVDetailFollowRecommendCardCell;

@protocol TTVDetailFollowRecommendCardCellDelegate <NSObject>

- (void) onClickFollow:(TTVDetailFollowRecommendCardCell*)cell;
- (void) onClickDislike:(TTVDetailFollowRecommendCardCell*)cell;
@end

extern NSString *const TTVDetailFollowRecommendCellIdentifier;
@interface TTVDetailFollowRecommendCardCell : UICollectionViewCell

@property (nonatomic, strong) id<TTVDetailRelatedRecommendCellViewModelProtocol> model;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *dislikeButton;
@property (nonatomic, weak) id<TTVDetailFollowRecommendCardCellDelegate> delegate;
@property (nonatomic, strong, readonly) TTFollowThemeButton *subscribeButton;

//配置model以及UI
- (void)configWithModel:(id<TTVDetailRelatedRecommendCellViewModelProtocol> )model;

@end

