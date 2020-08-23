//
//  FHUGCToolView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import <UIKit/UIKit.h>
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCToolView : UIView

@property(nonatomic , strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic , strong) UIButton *shareButton;
@property(nonatomic , strong) UIButton *collectionButton;
@property(nonatomic , strong) UIButton *commentButton;
@property(nonatomic , strong) UIButton *diggButton;

- (void)refreshWithdata:(id)data;

- (void)updateCollectionButton;

- (void)updateCommentButton;

- (void)updateDiggButton;

@end

NS_ASSUME_NONNULL_END
