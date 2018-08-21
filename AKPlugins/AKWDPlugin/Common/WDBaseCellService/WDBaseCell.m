//
//  WDBaseCell.m
//  wenda
//
//  Created by xuzichao on 2017/2/8.
//

#import "WDBaseCell.h"
#import "WDBaseCellView.h"

#import "TTDeviceHelper.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTThemed/TTThemeManager.h>

@implementation WDBaseCell

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithTableView:(UITableView *)view reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tableView = view;
        self.frame = CGRectMake(0, 0, view.frame.size.width, 0);
        [self initSubViews];
    }
    return self;
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
    self.contentView.clipsToBounds = YES;
    
    self.cellView = [self createCellView];
    self.cellView.cell = self;
    self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.cellView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];

}

+ (Class)cellViewClass
{
    return [WDBaseCellView class];
}

- (WDBaseCellView *)createCellView
{
    Class cellViewCls = [[self class] cellViewClass];
    return [[cellViewCls alloc] initWithFrame:self.bounds];
}

- (void)refreshUI
{
    [self.cellView refreshUI];
}

- (void)willDisplay
{
}

- (void)willAppear
{
    [self.cellView willAppear];
}

- (void)willDisappear
{
    
    [self.cellView willDisappear];
}

- (void)didAppear
{
    [self.cellView didAppear];
}

- (void)didDisappear
{
    [self.cellView didDisappear];
}

- (void)refreshWithData:(id)data
{
    [self.cellView refreshWithData:data];
}

- (void)themedChanged:(NSNotification *)notification
{
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([TTDeviceHelper isPadDevice]) {
        CGRect rect = [TTUIResponderHelper splitViewFrameForView:self];
        CGFloat topPadding = [self paddingTopBottomForCellView];
        CGFloat leftPadding = [self paddingForCellView];
        self.cellView.frame = CGRectMake(leftPadding, topPadding, rect.size.width, rect.size.height - topPadding * 2);
    }
    
    [self refreshUI];
}

- (id)cellData
{
    return [self.cellView cellData];
}

- (void)fontSizeChanged
{
    [self.cellView fontSizeChanged];
}

- (void)willDisplaying:(UIView *)listView
{
    [self.cellView willDisplaying:listView];
}
    
- (void)didEndDisplaying:(UIView *)listView
{
    [self.cellView didEndDisplaying:listView];
}

- (void)didSelected:(id)data apiParam:(NSString *)apiParam
{
    [self.cellView didSelected:data apiParam:apiParam];
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(NSInteger)listType;
{
    return [[self cellViewClass] heightForData:data cellWidth:width listType:listType];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.cellView setHighlighted:highlighted animated:animated];
}

- (CGFloat)paddingTopBottomForCellView {
    return 0;
}

- (CGFloat)paddingForCellView {
    return [TTUIResponderHelper paddingForViewWidth:0];
}

@end
