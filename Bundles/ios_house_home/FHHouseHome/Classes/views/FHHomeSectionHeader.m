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

static const float kSegementedOneWidth = 50;
static const float kSegementedHeight = 35;
static const float kSegementedPadingTop = 10;

@interface FHHomeSectionHeader ()
@property (nonatomic, strong) UILabel * categoryLabel;
@property (nonatomic, strong) NSArray <NSString *> * sectionTitleArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *topStyleContainer;
@end

@implementation FHHomeSectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.categoryLabel = [UILabel new];
        self.categoryLabel.font = [UIFont themeFontMedium:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 14];
        self.categoryLabel.textColor = [UIColor themeGray1];
        self.categoryLabel.text = @"为你推荐";
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.categoryLabel];
        self.categoryLabel.frame = CGRectMake(20, 22, 100, 20);
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
    _segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff5869"];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentedControl.isNeedNetworkCheck = YES;
    
    
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 12],NSFontAttributeName,
                                     [UIColor themeGray3],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontMedium:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 12],NSFontAttributeName,
                                      [UIColor themeRed1],NSForegroundColorAttributeName,nil];
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
    [_topStyleContainer setBackgroundColor:[UIColor redColor]];
    [self addSubview:_topStyleContainer];
}

- (void)showOriginStyle:(BOOL)isOrigin
{
    if (isOrigin) {
        _topStyleContainer.hidden = YES;
        [self sendSubviewToBack:_topStyleContainer];
    }else
    {
        _topStyleContainer.hidden = NO;
        [self bringSubviewToFront:_topStyleContainer];
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
        _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth + 5) * titles.count - leftPading, kSegementedPadingTop, (kSegementedOneWidth  + 5) * titles.count, kSegementedHeight);
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

}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
