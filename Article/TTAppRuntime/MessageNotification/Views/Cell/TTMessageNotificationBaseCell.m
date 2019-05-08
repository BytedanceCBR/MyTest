//
//  TTMessageNotificationBaseCell.m
//  Article
//
//  Created by lizhuoli on 2017/3/31.
//
//

#import "TTMessageNotificationBaseCell.h"
#import "TTMessageNotificationModel.h"
#import "TTMessageNotificationBaseCellView.h"


@interface TTMessageNotificationBaseCell ()

@end

@implementation TTMessageNotificationBaseCell

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    return [[self cellViewClass] heightForData:data cellWidth:width];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    self.cellView = [self createCellView];
    self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.cellView];
}

+ (Class)cellViewClass
{
    return [TTMessageNotificationBaseCellView class];
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
    CGRect rect = [TTUIResponderHelper splitViewFrameForView:self];
    
    self.cellView.frame = CGRectMake(0, 0, self.width, rect.size.height);
    
    if ([TTDeviceHelper isPadDevice])
    {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        self.cellView.frame = CGRectMake(padding, 0, self.width - 2 * padding, self.height);
        
    }
    
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

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.contentView.backgroundColor = self.backgroundColor;
}


@end

