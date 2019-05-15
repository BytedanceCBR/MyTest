//
//  TTLayOutCellViewBase+UFCell.h
//  Article
//
//  Created by 王双华 on 16/11/11.
//
//

#import "TTLayOutCellViewBase.h"

@interface TTLayOutCellViewBase()
@property (nonatomic, strong) SSThemedLabel *newsTitleLabel;
@property (nonatomic, strong) SSThemedLabel *userNameLabel;
@property (nonatomic, strong) SSThemedLabel *userVerifiedLabel;
@property (nonatomic, strong) SSThemedLabel *recommendLabel;
@property (nonatomic, strong) SSThemedView *verticalLineView;   //竖线 评论cell左边1pi线
@property (nonatomic, strong) SSThemedView *actionSepLine;      // 赞按钮 评论按钮上方的分割线
@end

@interface TTLayOutCellViewBase (UFCell)

- (void)setupSubviewsForUFCell;

- (void)layoutComponentsForUFCell;
@end
