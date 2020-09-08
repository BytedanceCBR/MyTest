//
//  FHHomeSectionHeader.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/24.
//

#import "FHHomeSectionHeader.h"
#import "UIFont+House.h"
#import "TTDeviceHelper.h"
#import "UIColor+Theme.h"
#import "FHEnvContext.h"
#import "UIViewAdditions.h"
#import "ToastManager.h"

static const float kSegementedOneWidth = 50;
static const float kSegementedHeight = 30;
static const float kSegementedPadingTop = 0;

static const NSInteger kTopScrollViewTag = 100;

@interface FHHomeSectionHeader ()
@property (nonatomic, strong) UILabel * categoryLabel;
@property (nonatomic, strong) NSArray <NSString *> * sectionTitleArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *topStyleContainer;
@property (nonatomic, strong) UIImageView *topStyleBottomLineImage;
@property (nonatomic, assign) CGFloat leftCenterX;
@property (nonatomic, assign) CGFloat rightCenterX;
@property (nonatomic, assign) CGFloat totalCenterXWidth;
@property (nonatomic, strong) UILabel * currentLabel;
@end

@implementation FHHomeSectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.categoryLabel = [UILabel new];
        self.categoryLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 18 : 14];
        self.categoryLabel.textColor = [UIColor themeGray1];
        self.categoryLabel.text = @"为你推荐";
        self.backgroundColor = [UIColor themeHomeColor];
        [self addSubview:self.categoryLabel];
        self.categoryLabel.frame = CGRectMake(15, 0, 100, 30);
        [self setUpSegmentedControl];
    }
    return self;
}

- (void)setUpSegmentedControl
{
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth + 5) * 3, kSegementedPadingTop, (kSegementedOneWidth + 5) * 3, kSegementedHeight);
    _segmentedControl.sectionTitles = @[@"",@"",@""];
    _segmentedControl.selectionIndicatorHeight = 0;
    _segmentedControl.selectionIndicatorColor = [UIColor themeOrange4]; //[UIColor colorWithHexString:@"#ff5869"];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentedControl.isNeedNetworkCheck = YES;
    [_segmentedControl setBackgroundColor:[UIColor themeHomeColor]];
    
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 12],NSFontAttributeName,
                                     [UIColor themeGray1],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 12],NSFontAttributeName,
                                     [UIColor colorWithHexStr:@"#fe5500"],NSForegroundColorAttributeName,nil];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(5, 15, 0, 0);
    WeakSelf;
    _segmentedControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        if (self.clickIndexCallBack) {
            self.clickIndexCallBack(index);
        }
    };
    [self addSubview:self.segmentedControl];
    
    _topStyleContainer = [[UIView alloc] initWithFrame:self.frame];
    _topStyleContainer.hidden = YES;
    [self addSubview:_topStyleContainer];
}

- (void)refreshSelectionIconFromOffsetX:(CGFloat)offsetX
{
    if (_segmentedControl.sectionTitles.count <= 1) {
        return;
    }
    CGFloat ratio = offsetX / (MAIN_SCREEN_WIDTH * (_segmentedControl.sectionTitles.count - 1));
    _topStyleBottomLineImage.centerX = ratio * self.totalCenterXWidth + self.leftCenterX;
    
    NSInteger scrollIndex = (NSInteger)((offsetX + MAIN_SCREEN_WIDTH/2)/MAIN_SCREEN_WIDTH);
    
    if (_segmentedControl.sectionTitles.count > scrollIndex) {
        UILabel *labelCurrent = [self getTopScrollLabelFromIndex:scrollIndex];
        if (self.currentLabel != labelCurrent) {
            [self.currentLabel setFont:[UIFont themeFontRegular:16]];
            [self.currentLabel setTextColor:[UIColor themeGray3]];
        }
        
        [labelCurrent setFont:[UIFont themeFontMedium:16]];
        [labelCurrent setTextColor:[UIColor themeGray1]];
        self.currentLabel = labelCurrent;
        self.segmentedControl.selectedSegmentIndex = scrollIndex;
    }
    
}

- (void)showOriginStyle:(BOOL)isOrigin
{
    if (isOrigin) {
        
        _topStyleContainer.hidden = YES;
        [self sendSubviewToBack:_topStyleContainer];
    }else
    {
        _topStyleContainer.hidden = YES;
    }
}

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles
{
    if (titles.count == 0) {
        return;
    }
    
    CGFloat leftPading = 2;
    
    if (titles.count == 1) {
        leftPading = 6;
    }
    
    if (titles.count == 2) {
        leftPading = 8;
    }
    
    _segmentedControl.sectionTitles = titles;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth + 5) * titles.count - leftPading, kSegementedPadingTop, (kSegementedOneWidth  + 5) * titles.count, kSegementedHeight);
//    [self addScrollTopSection:titles andSelectIndex:0];
}

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles andSelectIndex:(NSInteger)index
{
    _segmentedControl.sectionTitles = titles;
    if (titles.count > index) {
        _segmentedControl.selectedSegmentIndex = index;
    }else
    {
        _segmentedControl.selectedSegmentIndex = _segmentedControl.selectedSegmentIndex;
    }
    CGFloat leftPading = 2;
    
    
    if (titles.count == 1) {
        if ([titles.firstObject isKindOfClass:[NSString class]]) {
            NSString *titleSeg = (NSString *)titles.firstObject;
            if (titleSeg.length == 3) {
                leftPading = 14;
            }else
            {
                leftPading = 4;
            }
        }else
        {
            leftPading = 6;
        }
    }
    
    if (titles.count == 2) {
        leftPading = 8;
    }
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth + 5) * titles.count - leftPading, kSegementedPadingTop, (kSegementedOneWidth  + 5) * titles.count + (titles.count == 1 ? 10 : 0), kSegementedHeight);
    }else
    {
        if (titles.count < 3) {
            leftPading = 8;
        }else
        {
            leftPading = -3;
        }
        
        CGFloat kSegementedOneWidth5s = 40;
        _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth5s + 5) * titles.count - leftPading, kSegementedPadingTop, (kSegementedOneWidth  + 5) * titles.count, kSegementedHeight);
    }
    
    [self addScrollTopSection:titles andSelectIndex:index];
}

- (void)addScrollTopSection:(NSArray <NSString *> *)titles andSelectIndex:(NSInteger)index
{
    
    for (UIView *subView in _topStyleContainer.subviews) {
        [subView removeFromSuperview];
    }
    
    _topStyleBottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_top_scroll_selection"]];
    [_topStyleBottomLineImage setFrame:CGRectMake(0.0f, 32, 24, 13)];
    [_topStyleContainer addSubview:_topStyleBottomLineImage];
    
    if (titles.count != 0) {
        CGFloat lableWidth = MAIN_SCREEN_WIDTH / titles.count;
        for (NSInteger i = 0; i < titles.count; i++) {
            UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * lableWidth, 9, lableWidth, 24)];
            sectionLabel.text = titles[i];
            sectionLabel.tag = kTopScrollViewTag + i;
            if (i == 0) {
                self.leftCenterX = sectionLabel.centerX;
            }
            
            if (i == titles.count - 1) {
                self.rightCenterX = sectionLabel.centerX;
            }
            
            if (index == i) {
                sectionLabel.font = [UIFont themeFontMedium:16];
                sectionLabel.textColor = [UIColor themeGray1];
                _topStyleBottomLineImage.centerX = sectionLabel.centerX;
                self.currentLabel = sectionLabel;
            }else
            {
                sectionLabel.font = [UIFont themeFontRegular:16];
                sectionLabel.textColor = [UIColor themeGray3];
            }
            
            sectionLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollSectionLabelClick:)];
            [sectionLabel addGestureRecognizer:tapGes];
            sectionLabel.textAlignment = NSTextAlignmentCenter;
            [_topStyleContainer addSubview:sectionLabel];
            
            UIView *maskView = [UIView new];
            [maskView setFrame:CGRectMake(sectionLabel.frame.origin.x, 0.0f, sectionLabel.frame.size.width, 45)];
            [maskView setBackgroundColor:[UIColor clearColor]];
            maskView.tag = kTopScrollViewTag * 2 + i;
            maskView.userInteractionEnabled = YES;
            [_topStyleContainer addSubview:maskView];
            UITapGestureRecognizer *tapMaskGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollSectionLabelClick:)];
            [maskView addGestureRecognizer:tapMaskGes];
        }
    }
    
    self.totalCenterXWidth = self.rightCenterX - self.leftCenterX;
}

- (void)scrollSectionLabelClick:(UITapGestureRecognizer *)tap
{
    
    UIView *tapView = tap.view;
    NSInteger scrollIndex = tapView.tag - kTopScrollViewTag;
    
    if (tapView.tag >= (2 * kTopScrollViewTag)) {
        scrollIndex = tapView.tag - kTopScrollViewTag * 2;
    }
        
    if (_segmentedControl.sectionTitles.count > scrollIndex) {
        
        UILabel *labelCurrent = [self getTopScrollLabelFromIndex:scrollIndex];
        if (self.currentLabel != labelCurrent) {
            [self.currentLabel setFont:[UIFont themeFontRegular:16]];
            [self.currentLabel setTextColor:[UIColor themeGray3]];
        }else
        {
            //如果已经选中
            return;
        }
        
        [labelCurrent setFont:[UIFont themeFontMedium:16]];
        [labelCurrent setTextColor:[UIColor themeGray1]];
        self.currentLabel = labelCurrent;
        
        _topStyleBottomLineImage.centerX = labelCurrent.centerX;
        
        if (self.clickIndexCallBack) {
            self.segmentedControl.selectedSegmentIndex = scrollIndex;
            self.clickIndexCallBack(scrollIndex);
        }
    }
}

- (UILabel *)getTopScrollLabelFromIndex:(NSInteger)index
{
    UIView *labelView = [_topStyleContainer viewWithTag:index + kTopScrollViewTag];
    return labelView;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
