//
//  TTArticleSearchCell.m
//  Article
//
//  Created by yangning on 2017/4/17.
//
//

#import "TTArticleSearchCell.h"
#import "TTAlphaThemedButton.h"
#import "Masonry.h"
#import "TTArticleSearchViewModel.h"

@interface TTArticleSearchItemView : SSThemedView

@property (nonatomic) SSThemedLabel *textLabel;
@property (nonatomic) TTAlphaThemedButton *deleteButton;
@property (nonatomic, copy) void(^actionBlock)(BOOL isEditing);

@property (nonatomic, getter=isEditing) BOOL editing;

- (void)configureWithViewModel:(TTArticleSearchCellItemViewModel *)viewModel;

@end

@implementation TTArticleSearchItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setup
{
    [self addSubview:self.textLabel];
    [self addSubview:self.deleteButton];
    self.deleteButton.hidden = YES;
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15.0);
        make.top.bottom.equalTo(self);
    }];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.textLabel.mas_trailing).offset([TTDeviceUIUtils tt_newPadding:10.0]);
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-[TTDeviceUIUtils tt_newPadding:15.0]);
        make.width.height.mas_equalTo([TTDeviceUIUtils tt_newPadding:12.0]);
    }];
    
    [self.deleteButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.deleteButton setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
}

- (SSThemedLabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [SSThemedLabel new];
        _textLabel.textColors = SSThemedColors(@"222222", @"707070");
        _textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15.0]];
    }
    return _textLabel;
}

- (TTAlphaThemedButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [[TTAlphaThemedButton alloc] init];
        _deleteButton.imageName = @"detail_close_icon";
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (void)tap:(UIGestureRecognizer *)gesture
{
    if (self.actionBlock) {
        self.actionBlock(self.isEditing);
    }
}

- (void)deleteButtonClicked:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(self.isEditing);
    }
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    [self updateAppearance];
}

- (void)updateAppearance
{
    self.textLabel.textColors = SSThemedColors(@"222222", @"707070");
    self.deleteButton.hidden = !self.isEditing;
}

- (void)configureWithViewModel:(TTArticleSearchCellItemViewModel *)viewModel
{
    self.textLabel.text = viewModel.text;
    self.editing = viewModel.isEditing;
    self.actionBlock = viewModel.actionBlock;
}

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchCell ()

@property (nonatomic) TTArticleSearchItemView *leftView;
@property (nonatomic) TTArticleSearchItemView *rightView;
@property (nonatomic) SSThemedView *middleLine;
@property (nonatomic) SSThemedView *bottomLine;

@end

@implementation TTArticleSearchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)configureWithItemViewModel:(TTArticleSearchCellItemViewModel *)viewModel atSubIndex:(NSInteger)subIndex
{
    NSCParameterAssert(subIndex < 2);
    if (0 == subIndex) {
        [self.leftView configureWithViewModel:viewModel];
    } else if (1 == subIndex) {
        [self.rightView configureWithViewModel:viewModel];
    }
}

- (void)setup
{
    [self.contentView addSubview:self.leftView];
    [self.contentView addSubview:self.middleLine];
    [self.contentView addSubview:self.rightView];
    [self.contentView addSubview:self.bottomLine];
    [self setupConstaints];
}

- (void)setupConstaints
{
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.contentView);
    }];
    
    [self.middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.leading.equalTo(self.leftView.mas_trailing);
        make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.middleLine.mas_trailing);
        make.trailing.top.bottom.equalTo(self.contentView);
        make.width.equalTo(self.leftView);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
}

- (TTArticleSearchItemView *)leftView
{
    if (!_leftView) {
        _leftView = [TTArticleSearchItemView new];
    }
    return _leftView;
}

- (TTArticleSearchItemView *)rightView
{
    if (!_rightView) {
        _rightView = [TTArticleSearchItemView new];
    }
    return _rightView;
}

- (UIView *)middleLine
{
    if (!_middleLine) {
        _middleLine = [SSThemedView new];
        _middleLine.backgroundColorThemeKey = kColorLine1;
    }
    return _middleLine;
}

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [SSThemedView new];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLine;
}

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchHeaderCell ()

@property (nonatomic) SSThemedButton *titleButton;
@property (nonatomic) SSThemedView *placeholdView;
@property (nonatomic) SSThemedButton *actionButton;
@property (nonatomic) SSThemedView *bottomLine;
@property (nonatomic, copy) void(^titleBlock)();
@property (nonatomic, copy) void(^actionBlock)();
@property (nonatomic) BOOL closing;

@end

@implementation TTArticleSearchHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        [self themeChanged:nil];
    }
    return self;
}

- (void)setup
{
    [self.contentView addSubview:self.titleButton];
    [self.contentView addSubview:self.actionButton];
    [self.contentView addSubview:self.bottomLine];
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo([TTDeviceUIUtils tt_newPadding:15.0]);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo([TTDeviceUIUtils tt_newPadding:42.0]);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleButton);
        make.height.equalTo(self.titleButton);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-[TTDeviceUIUtils tt_newPadding:15.0]);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [self.actionButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [self.actionButton setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
}

- (SSThemedButton *)titleButton
{
    if (!_titleButton) {
        _titleButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _titleButton.titleColors = SSThemedColors(@"999999", @"707070");
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.0]];
        [_titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleButton;
}

- (SSThemedView *)placeholdView
{
    if (!_placeholdView) {
        _placeholdView = [SSThemedView new];
    }
    return _placeholdView;
}

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.titleColors = SSThemedColors(@"999999", @"707070");
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.0]];
        _actionButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -15, 0, -15);
        [_actionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [SSThemedView new];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLine;
}

- (void)configureWithViewModel:(TTArticleSearchHeaderCellViewModel *)viewModel
{
    self.titleLabel.text = viewModel.title;
    [self.titleButton setTitle:viewModel.title forState:UIControlStateNormal];
    // FIXME: 需要特殊处理一下，否则显示异常，和UIButton设置图片位置的方法有关系
    BOOL fixFlag = (viewModel.titleIcon == nil) && (self.titleButton.imageView.image != nil);
    [self.titleButton setImage:[UIImage imageNamed:viewModel.titleIcon] forState:UIControlStateNormal];
    [self.actionButton setTitle:viewModel.actionText forState:UIControlStateNormal];
    [self.actionButton setImage:[UIImage imageNamed:viewModel.actionIcon] forState:UIControlStateNormal];
    if (viewModel.closing) {
        [self.titleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.height.mas_equalTo([TTDeviceUIUtils tt_newPadding:42.0]);
        }];
        
        [self.titleButton layoutIfNeeded];
        [self.titleButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:[TTDeviceUIUtils tt_newPadding:5.0]];
        
        self.bottomLine.hidden = YES;
    } else {
        CGFloat leftMargin = fixFlag ? 15.0 + 16.0 : 15.0;
        [self.titleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(leftMargin);
            make.bottom.equalTo(self.contentView);
            make.height.mas_equalTo([TTDeviceUIUtils tt_newPadding:42.0]);
        }];
        
        [self.actionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleButton);
            make.height.equalTo(self.titleButton);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-[TTDeviceUIUtils tt_newPadding:15.0]);
        }];
        
        [self.titleButton layoutIfNeeded];
        [self.titleButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageRight imageTitlespace:0.0];
        
        self.bottomLine.hidden = NO;
    }
    
    self.titleBlock = viewModel.titleBlock;
    self.actionBlock = viewModel.actionBlock;
}

- (void)titleButtonClicked:(id)sender
{
    if (self.titleBlock) {
        self.titleBlock();
    }
}

- (void)actionButtonClicked:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchFooterCell ()

@property (nonatomic) SSThemedView *bottomLine;

@end

@implementation TTArticleSearchFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        [self themeChanged:nil];
    }
    return self;
}

- (void)setup
{
    [self.contentView addSubview:self.bottomLine];
}

- (SSViewBase *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0.0, self.contentView.height - [TTDeviceHelper ssOnePixel], self.contentView.width, [TTDeviceHelper ssOnePixel])];
        _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLine;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
}

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchInBoxItemView : TTArticleSearchItemView
@end

@implementation TTArticleSearchInBoxItemView

- (void)setupConstraints
{
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_greaterThanOrEqualTo(15.0);
        make.trailing.mas_greaterThanOrEqualTo(15.0);
        make.centerX.equalTo(self);
        make.top.bottom.equalTo(self);
    }];
}

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchInboxCell ()

@property (nonatomic) TTArticleSearchInBoxItemView *leftView;
@property (nonatomic) TTArticleSearchInBoxItemView *middleView;
@property (nonatomic) TTArticleSearchInBoxItemView *rightView;
@property (nonatomic) SSThemedView *leftLine;
@property (nonatomic) SSThemedView *rightLine;
@property (nonatomic) SSThemedView *bottomLine;

@end

@implementation TTArticleSearchInboxCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        [self themeChanged:nil];
    }
    return self;
}

- (void)configureWithItemViewModel:(TTArticleSearchCellItemViewModel *)viewModel atSubIndex:(NSInteger)subIndex
{
    NSCParameterAssert(subIndex < 3);
    if (0 == subIndex) {
        [self.leftView configureWithViewModel:viewModel];
    } else if (1 == subIndex) {
        [self.middleView configureWithViewModel:viewModel];
        self.rightLine.hidden = !viewModel ? YES : NO;
    } else if (2 == subIndex) {
        [self.rightView configureWithViewModel:viewModel];
    }
}

- (void)setup
{
    [self.contentView addSubview:self.leftView];
    [self.contentView addSubview:self.leftLine];
    [self.contentView addSubview:self.middleView];
    [self.contentView addSubview:self.rightLine];
    [self.contentView addSubview:self.rightView];
    [self.contentView addSubview:self.bottomLine];
    [self setupConstaints];
}

- (void)setupConstaints
{
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView).multipliedBy(0.333);
    }];
    
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.leading.equalTo(self.leftView.mas_trailing);
        make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.equalTo(self.contentView);
        make.width.equalTo(self.leftView);
    }];
    
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.rightView.mas_leading);
        make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
    
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.leftLine.mas_trailing);
        make.top.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.rightLine.mas_leading);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    }];
}

- (TTArticleSearchItemView *)leftView
{
    if (!_leftView) {
        _leftView = [TTArticleSearchInBoxItemView new];
    }
    return _leftView;
}

- (TTArticleSearchItemView *)middleView
{
    if (!_middleView) {
        _middleView = [TTArticleSearchInBoxItemView new];
    }
    return _middleView;
}

- (TTArticleSearchItemView *)rightView
{
    if (!_rightView) {
        _rightView = [TTArticleSearchInBoxItemView new];
    }
    return _rightView;
}

- (UIView *)leftLine
{
    if (!_leftLine) {
        _leftLine = [SSThemedView new];
        _leftLine.backgroundColorThemeKey = kColorLine1;
    }
    return _leftLine;
}

- (UIView *)rightLine
{
    if (!_rightLine) {
        _rightLine = [SSThemedView new];
        _rightLine.backgroundColorThemeKey = kColorLine1;
    }
    return _rightLine;
}

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [SSThemedView new];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLine;
}

@end
