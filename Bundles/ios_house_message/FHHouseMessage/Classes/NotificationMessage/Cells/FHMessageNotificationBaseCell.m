//
//  FHMessageNotificationBaseCell.m
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import "FHMessageNotificationBaseCell.h"
#import "TTMessageNotificationModel.h"
#import "FHMessageNotificationBaseCellView.h"
#import "TTMessageNotificationBaseCellView.h"
#import "TTUIResponderHelper.h"
#import <FHCommonUI/UIColor+Theme.h>

@interface FHMessageNotificationBaseCell ()

@end

@implementation FHMessageNotificationBaseCell

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    return [[self cellViewClass] heightForData:data cellWidth:width];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.backgroundColor = self.contentView.backgroundColor;

    self.contentView.clipsToBounds = YES;

    self.cellView = [self createCellView];
    self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.cellView];
}

+ (Class)cellViewClass
{
    return [self class];
}

- (TTMessageNotificationBaseCellView *)createCellView
{
    Class cellViewCls = [[self class] cellViewClass];
    return [[cellViewCls alloc] initWithFrame:[TTUIResponderHelper splitViewFrameForView:self]];
}

- (void)refreshUI
{
    [self.cellView refreshUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.cellView.frame = self.bounds;
    if (self.cellData) {
        [self refreshUI];
    }
}

- (void)refreshWithData:(TTMessageNotificationModel *)data
{
    [self.cellView refreshWithData:data];
}

- (TTMessageNotificationModel *)cellData
{
    return [self.cellView cellData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
   
    [_cellView setHighlighted:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    [_cellView setHighlighted:highlighted animated:animated];
}

@end

