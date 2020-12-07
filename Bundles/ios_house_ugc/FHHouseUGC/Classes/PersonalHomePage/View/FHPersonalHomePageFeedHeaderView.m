//
//  FHPersonalHomePageFeedHeaderView.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/7.
//

#import "FHPersonalHomePageFeedHeaderView.h"
#import "HMSegmentedControl.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonDefines.h"

@interface FHPersonalHomePageFeedHeaderView ()
@property(nonatomic,strong) HMSegmentedControl *segmentedControl;
@end

@implementation FHPersonalHomePageFeedHeaderView
-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 34)];
        _segmentedControl.type = HMSegmentedControlTypeText;
        
        NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                NSForegroundColorAttributeName: [UIColor themeGray1]};
        _segmentedControl.titleTextAttributes = titleTextAttributes;

        NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:18],
                NSForegroundColorAttributeName: [UIColor themeGray1]};
        _segmentedControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
        
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
        _segmentedControl.isNeedNetworkCheck = NO;
        _segmentedControl.firstLeftMargain = 42;
        _segmentedControl.lastRightMargin = 42;
        _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(5, 14, 0, 14);
        
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectionIndicatorWidth = 20.0f;
        _segmentedControl.selectionIndicatorHeight = 4.0f;
        _segmentedControl.selectionIndicatorCornerRadius = 2.0f;
        _segmentedControl.shouldFixedSelectPosition = YES;
        _segmentedControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
        _segmentedControl.bounces = NO;
        
        [self addSubview:_segmentedControl];
    }
    return self;
}

-(void)updateWithTitles:(NSArray<NSString *> *)titles {
    self.segmentedControl.sectionTitles = titles;
}


@end
