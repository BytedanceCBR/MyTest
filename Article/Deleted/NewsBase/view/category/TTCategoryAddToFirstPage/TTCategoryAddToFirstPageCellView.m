//
//  TTCategoryAddToFirstPageCellView.m
//  Article
//
//  Created by xuzichao on 16/9/7.
//
//

#import "TTCategoryAddToFirstPageCellView.h"
#import "TTImageView.h"
#import "SSThemed.h"
#import "TTLabelTextHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTDeviceHelper.h"
#import "TTCategoryAddToFirstPageData.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTBusinessManager.h"
#import "TTImageView.h"
#import "TTArticleCategoryManager.h"
#import "TTIndicatorView.h"
#import "WDCommonLogic.h"
#import "UIButton+TTAdditions.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreMixListDefine.h"
#import "TTAlphaThemedButton.h"

#define  TTCategoryAddToFirstPageCellTextViewFix            [TTDeviceUIUtils tt_padding:20]
#define  TTCategoryAddToFirstPageCellRightPadding           [TTDeviceUIUtils tt_padding:12]
#define  TTCategoryAddToFirstPageCellViewHorizonalPaddding  [TTDeviceUIUtils tt_padding:15]
#define  TTCategoryAddToFirstPageCellViewVerticalPaddding   [TTDeviceUIUtils tt_padding:15]
#define  TTCategoryAddToFirstPageCellViewCloseButtonWidth   [TTDeviceUIUtils tt_padding:40]
#define  TTCategoryAddToFirstHint    @"+ 添加到首屏"

//字符串修改，都需要全局替换
NSString * const TTCategoryAddToFirstPageCellViewCloseNotice = @"TTCategoryAddToFirstPageCellViewCloseNotice";
NSString * const TTCategoryAddToFirstPageCellIndexPath = @"TTCategoryAddToFirstPageCellIndexPath";

@interface UITextView(MYTextView)

@end

@implementation UITextView (MYTextView)
- (void)_firstBaselineOffsetFromTop {
    
}

- (void)_baselineOffsetFromBottom {
    
}

@end

@interface TTCategoryAddToFirstPageCellView ()
@property(nonatomic,assign)BOOL isViewHighlighted;
@property (nonatomic, strong) TTCategoryAddToFirstPageData *modelData;
@property (nonatomic, strong) id originData;
@property (nonatomic, strong) SSThemedButton    *addActionButton;
@property (nonatomic, strong) SSThemedLabel     *tipTextLabel;
@property (nonatomic, strong) TTImageView       *iconImageView;
@property (nonatomic, strong) TTAlphaThemedButton    *closeButton;
@property (nonatomic, strong) SSThemedView       *footerView;

@end


@implementation TTCategoryAddToFirstPageCellView

#pragma mark - 重载函数

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //添加icon
        CGFloat radius = [TTDeviceUIUtils tt_padding:66];
        self.iconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, radius,radius)];
        self.iconImageView.layer.cornerRadius = radius/2;
        self.iconImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.iconImageView.borderColorThemeKey = kColorLine1;
        [self addSubview:self.iconImageView];
        
        //添加tips
        self.tipTextLabel = [[SSThemedLabel alloc] init];
        self.tipTextLabel.font = [UIFont systemFontOfSize:kCellTitleLabelFontSize];
        self.tipTextLabel.textColorThemeKey = kColorText1;
        [self addSubview:self.tipTextLabel];
        
        //添加button
        self.addActionButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_padding:111], [TTDeviceUIUtils tt_padding:28])];
        self.addActionButton.backgroundColor = [UIColor clearColor];
        self.addActionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        self.addActionButton.titleColorThemeKey = kColorText6;
        self.addActionButton.borderColorThemeKey = kColorLine3;
        self.addActionButton.layer.borderWidth = 2 * [TTDeviceHelper ssOnePixel];
        self.addActionButton.layer.cornerRadius = 6.0f;
        [self.addActionButton setTitle:TTCategoryAddToFirstHint forState:UIControlStateNormal];

        [self.addActionButton addTarget:self action:@selector(addToFirstPage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.addActionButton];
        
        //添加close
        self.closeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 17, 13)];
        self.closeButton.titleColorThemeKey = kColorText4;
        self.closeButton.imageName = @"add_textpage";
        [self.closeButton addTarget:self action:@selector(closeAddTipCell:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        //底部的灰色条
        self.footerView = [[SSThemedView alloc] init];
        if ([TTDeviceHelper isPadDevice]) {
            self.footerView.backgroundColorThemeKey = kColorLine1;
        }
        else {
            self.footerView.backgroundColorThemeKey = kColorBackground3;
        }
        [self addSubview:self.footerView];
        
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshUI];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    
    [self refreshUI];
}

- (void)fontSizeChanged
{
    [super fontSizeChanged];
    
    self.tipTextLabel.font = [UIFont systemFontOfSize:kCellTitleLabelFontSize];
    
    [self refreshUI];
}

- (void)refreshWithData:(id)data
{
    self.originData = data;
    
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.modelData = (TTCategoryAddToFirstPageData *)((ExploreOrderedData *)data).originalData;
    }
    else if ([data isKindOfClass:[TTCategoryAddToFirstPageData class]])
    {
       self.modelData = data;
    }
    
    
    if (!isEmptyString(self.modelData.iconUrl)) {
        [self.iconImageView setImageWithURLString:self.modelData.iconUrl];
    }
    
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithDictionary:self.modelData.recommendImage];
    if (imageModel) {
        [self.iconImageView setImageWithModel:imageModel];
    }
    
    self.tipTextLabel.text = self.modelData.text;
    [self.addActionButton setTitle:self.modelData.buttonText forState:UIControlStateNormal];
    
    [self refreshUI];
}

- (id)cellData
{
    return self.modelData;
}

- (void)refreshUI
{
    [self refreshLayOutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted)
    {
        if (!self.isViewHighlighted) {
            
            self.tipTextLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            
            self.tipTextLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
            self.isViewHighlighted = YES;
        }
    }
    else
    {
        if (self.isViewHighlighted) {
            self.tipTextLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            self.isViewHighlighted = NO;
        }
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    TTCategoryAddToFirstPageData *modelData;
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        modelData = (TTCategoryAddToFirstPageData *)((ExploreOrderedData *)data).originalData;
    }
    else if ([data isKindOfClass:[TTCategoryAddToFirstPageData class]])
    {
        modelData = data;
    }
    
    return [TTCategoryAddToFirstPageCellView cellViewHeightWithModel:modelData constraintWidth:width];
}


- (void)refreshLayOutSubviews
{
    
    self.closeButton.right = self.width - [TTDeviceUIUtils tt_padding:15];
    self.closeButton.top = [TTDeviceUIUtils tt_padding:15];
    
    CGFloat height = [TTDeviceUIUtils tt_padding:27];//顶部间距
    
    self.iconImageView.centerX = self.centerX;
    self.iconImageView.top = height;
    
    height += self.iconImageView.height; //图标高度
    
    height += [TTDeviceUIUtils tt_padding:10]; //图标下间距
    
    [self.tipTextLabel sizeToFit];
    self.tipTextLabel.centerX = self.centerX;
    self.tipTextLabel.top = height;

    
    height += self.tipTextLabel.height; //提示文字高度
    
    height += [TTDeviceUIUtils tt_padding:10]; //文字下间距
    
    self.addActionButton.centerX = self.centerX;
    self.addActionButton.top = height;
    
    height += self.addActionButton.height; //按钮高度
    
    height += [TTDeviceUIUtils tt_padding:27]; //底部间距
    
    //底部条
    self.footerView.left = [TTDeviceUIUtils tt_padding:15];
    self.footerView.top = height;
    self.footerView.width = self.width - 2*[TTDeviceUIUtils tt_padding:15];
    self.footerView.height = [TTCategoryAddToFirstPageCellView footerViewHeight:self.modelData];

}

#pragma mark 辅助函数

+ (CGFloat)footerViewHeight:(TTCategoryAddToFirstPageData *)data
{
    CGFloat height = [TTDeviceHelper ssOnePixel];
    if (!data.showBottomSeparator.boolValue) {
        height = 0;
    }
    return [TTDeviceUIUtils tt_padding:height];
}

+ (CGFloat)cellViewHeightWithModel:(TTCategoryAddToFirstPageData *)modelData  constraintWidth:(CGFloat)width
{
    CGFloat height = [TTDeviceUIUtils tt_padding:27];//顶部间距
    
    height += [TTDeviceUIUtils tt_padding:66]; //图标高度
    
    height += [TTDeviceUIUtils tt_padding:10]; //图标下间距
    
    SSThemedLabel *tipTextLabel = [[SSThemedLabel alloc] init];
    tipTextLabel.font = [UIFont systemFontOfSize:kCellTitleLabelFontSize];
    tipTextLabel.text = TTCategoryAddToFirstHint;
    [tipTextLabel sizeToFit];
    
    height += tipTextLabel.height; //提示文字高度
    
    height += [TTDeviceUIUtils tt_padding:10]; //文字下间距
    
    height += [TTDeviceUIUtils tt_padding:28]; //按钮高度
    
    height += [TTDeviceUIUtils tt_padding:27]; //底部间距
    
    height += [TTCategoryAddToFirstPageCellView footerViewHeight:modelData]; //分割线间距
    
    return height;
}

- (void)addToFirstPage:(UIButton *)btn
{
    NSString *categoryId = [self.modelData.action stringValueForKey:@"category" defaultValue:@""];
    TTCategory *model = [TTArticleCategoryManager categoryModelByCategoryID:categoryId];
    if (model && !isEmptyString(categoryId)) {
        
        //在其他频道出，翻页过去或者进入对应的频道控制器
        if (self.modelData.jumpType.integerValue == 1) {
            NSArray *categories = [[TTArticleCategoryManager sharedManager] preFixedAndSubscribeCategories];
            BOOL isPreFixedOrSubscribe = NO;
            for (TTCategory *category in categories) {
                if ([category.categoryID isEqualToString:categoryId]) {
                    isPreFixedOrSubscribe = YES;
                }
            }
            
            if (isPreFixedOrSubscribe) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:model forKey:@"model"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryManagementViewCategorySelectedNotification object:self userInfo:userInfo];
            }
            else {
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.modelData.openUrl]];
            }
        }
        
        //在自己频道出，就跳转到首屏
        else if (self.modelData.jumpType.integerValue == 0) {
            
            NSDictionary *userInfo = @{kTTInsertCategoryNotificationCategoryKey:model};
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTInsertCategoryToLastPositionNotification object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryTipNewChangedNotification object:nil];
            
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"已放到首屏", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            
            wrapperTrackEvent(@"channel_detail", @"add");
        }
        
        
        [self closeAddTipCell:btn];
    }
}

- (void)closeAddTipCell:(UIButton *)btn
{
    
    NSIndexPath *indexPath = [self.cell.tableView indexPathForCell:self.cell];
    if (indexPath) {
        
        if ([self.originData isKindOfClass:[TTCategoryAddToFirstPageData class]]) {

            NSDictionary *userInfo = @{TTCategoryAddToFirstPageCellIndexPath:indexPath};
            [[NSNotificationCenter defaultCenter] postNotificationName:TTCategoryAddToFirstPageCellViewCloseNotice object:nil userInfo:userInfo];
        }
        else if ([self.originData  isKindOfClass:[ExploreOrderedData class]]) {
            NSArray *filterWords = @[];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
            [userInfo setValue:self.originData forKey:kExploreMixListNotInterestItemKey];
            if (filterWords.count > 0) {
                [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
        }
        
        //关闭添加到首屏的cell
        [WDCommonLogic closeAddToFirstPageCell:YES];
    }
}

@end
