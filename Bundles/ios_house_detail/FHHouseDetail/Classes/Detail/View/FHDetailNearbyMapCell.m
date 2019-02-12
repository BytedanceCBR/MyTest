//
//  FHDetailNearbyMapCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/12.
//

#import "FHDetailNearbyMapCell.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import <HMSegmentedControl.h>
#import <FHEnvContext.h>

#import "FHMyMAAnnotation.h"


static const float kSegementedOneWidth = 50;
static const float kSegementedHeight = 35;
static const float kSegementedPadingTop = 5;

@interface FHDetailNearbyMapCell () <AMapSearchDelegate,MAMapViewDelegate>

@property(nonatomic , assign) NSInteger requestIndex;
@property(nonatomic , strong) HMSegmentedControl *segmentedControl;
@property(nonatomic , strong) UIImageView *mapImageView;
@property(nonatomic , strong) UIImageView *mapAnnotionImageView;
@property(nonatomic , strong) UITableView *locationList;
@property(nonatomic , strong) UIView *bottomLine;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) NSMutableArray <FHMyMAAnnotation *> *poiAnnotations;

@end

@implementation FHDetailNearbyMapCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpSegmentedControl];

    }
    return self;
}

- (void)setUpSegmentedControl
{
    self.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 35);
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.frame = CGRectMake(MAIN_SCREEN_WIDTH - (kSegementedOneWidth + 5) * 3, kSegementedPadingTop, kSegementedOneWidth * 3, kSegementedHeight);
    _segmentedControl.sectionTitles = @[@"交通",@"购物",@"医院",@"教育"];
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
      
    };
    [self addSubview:self.segmentedControl];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
