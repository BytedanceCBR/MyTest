//
//  TTLayOutCellViewBase+UGCCell.h
//  Article
//
//  Created by 王双华 on 16/11/10.
//
//

#import "TTLayOutCellViewBase.h"
@interface TTLayOutCellViewBase ()
@property (nonatomic, strong) SSThemedLabel             *likeLabel;         //喜欢
@property (nonatomic, strong) SSThemedLabel             *subscriptLabel;    //关注
@property (nonatomic, strong) SSThemedLabel             *entityLabel;       //实体词
@property (nonatomic, strong) SSThemedImageView         *moreImageView;     //更多
@property (nonatomic, strong) SSThemedButton            *moreButton;        //更多按钮
@property (nonatomic, strong) SSThemedLabel             *timeLabel;         //时间
@end

@interface TTLayOutCellViewBase (UGCCell)
- (void)setupSubviewsForUGCCell;
- (void)layoutComponentsForUGCCell;
@end
