//
//  FRForumLocationLoadMoreCell.h
//  Article
//
//  Created by 王霖 on 15/7/16.
//
//

#import "SSThemed.h"

#define kForumLocationLoadMoreCell 44
typedef NS_ENUM(NSInteger, FRForumLocationLoadMoreCellState) {
    FRForumLocationLoadMoreCellStateLoading = 0,
    FRForumLocationLoadMoreCellStateFailed,
    FRForumLocationLoadMoreCellStateNoMore
};

@interface FRForumLocationLoadMoreCell : SSThemedTableViewCell

@property (nonatomic, assign)FRForumLocationLoadMoreCellState state;


- (void)startAnimating;
- (void)stopAnimating;

@end
