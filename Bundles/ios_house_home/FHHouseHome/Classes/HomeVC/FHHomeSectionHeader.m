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
#import "HMSegmentedControl.h"
#import "FHEnvContext.h"

@interface FHHomeSectionHeader ()
@property (nonatomic, strong) UILabel * categoryLabel;
@property (nonatomic, strong) NSArray <NSString *> * sectionTitleArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

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

- (void)setUpSegmentedControl
{
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - 55 * 3, 15, 55 * 3, 20);
    _segmentedControl.sectionTitles = @[@"二手房",@"租房",@"新房"];
    _segmentedControl.selectionIndicatorHeight = 0;
    _segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#f85959"];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:14],NSFontAttributeName,
                                     [UIColor colorWithHexString:@"#979fac"],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:14],NSFontAttributeName,
                                     [UIColor colorWithHexString:@"#299cff"],NSForegroundColorAttributeName,nil];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 15, 0, 0);
    [self addSubview:self.segmentedControl];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end