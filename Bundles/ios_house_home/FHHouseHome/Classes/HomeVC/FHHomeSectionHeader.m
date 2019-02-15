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
static const float kSegementedPadingTop = 5;

@interface FHHomeSectionHeader ()
@property (nonatomic, strong) UILabel * categoryLabel;
@property (nonatomic, strong) NSArray <NSString *> * sectionTitleArray;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FHHomeSectionHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.categoryLabel = [UILabel new];
        self.categoryLabel.font = [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 14];
        self.categoryLabel.textColor = [UIColor themeBlack];
        self.categoryLabel.text = @"为你推荐";
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.categoryLabel];
        self.categoryLabel.frame = CGRectMake(20, 15, 100, 20);
        [self setUpSegmentedControl];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.categoryLabel = [UILabel new];
        self.categoryLabel.font = [UIFont themeFontRegular:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 14];
        self.categoryLabel.textColor = [UIColor themeBlack];
        self.categoryLabel.text = @"为你推荐";
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.categoryLabel];
        self.categoryLabel.frame = CGRectMake(20, 15, 100, 20);
        [self setUpSegmentedControl];
    }
    return self;
}

- (void)setUpSegmentedControl
{
    self.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 35);
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth + 5) * 3, kSegementedPadingTop, kSegementedOneWidth * 3, kSegementedHeight);
    _segmentedControl.sectionTitles = @[@"",@"",@""];
    _segmentedControl.selectionIndicatorHeight = 0;
    _segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff5869"];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentedControl.isNeedNetworkCheck = YES;
    
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:14],NSFontAttributeName,
                                     [UIColor colorWithHexString:@"#a1aab3"],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontMedium:14],NSFontAttributeName,
                                     [UIColor colorWithHexString:@"#ff5869"],NSForegroundColorAttributeName,nil];
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
}

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles
{
    if (titles.count == 0) {
        return;
    }
    _segmentedControl.sectionTitles = titles;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - kSegementedOneWidth * titles.count - 10, kSegementedPadingTop, kSegementedOneWidth * titles.count, kSegementedHeight);
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
    CGFloat leftPading = 0;
    
    if (titles.count == 1) {
        leftPading = 8;
    }
    
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - kSegementedOneWidth * titles.count - (titles.count == 1 ? 20 : 10) + leftPading, kSegementedPadingTop, kSegementedOneWidth * titles.count, kSegementedHeight);
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
