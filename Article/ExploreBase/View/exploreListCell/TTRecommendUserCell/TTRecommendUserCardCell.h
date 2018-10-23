//
//  TTRecommendUserCardCell.h
//  Article
//
//  Created by SongChai on 02/06/2017.
//
//

#import <Foundation/Foundation.h>
@class TTAlphaThemedButton;
@class FRRecommendCardStructModel;
@class TTFollowThemeButton;

extern NSString *const TTRecommendUserCardCellIdentifier;

@class TTRecommendUserCardCell;
@protocol TTRecommendUserCardCellDelegate <NSObject>

- (void) onClickFollow:(TTRecommendUserCardCell*)cell;
- (void) onClickDislike:(TTRecommendUserCardCell*)cell;

@end

@interface TTRecommendUserCardCell : UICollectionViewCell

@property (nonatomic, strong) FRRecommendCardStructModel *model;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *dislikeButton;

@property (nonatomic, weak) id<TTRecommendUserCardCellDelegate> delegate;
//关注按钮
@property (nonatomic, strong, readonly) TTFollowThemeButton *subscribeButton;

//配置model以及UI
- (void)configWithModel:(FRRecommendCardStructModel *)model;

@end
