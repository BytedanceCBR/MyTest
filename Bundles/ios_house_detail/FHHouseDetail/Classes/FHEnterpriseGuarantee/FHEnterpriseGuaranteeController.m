//
//  FHEnterpriseGuaranteeController.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/7/1.
//

#import "FHEnterpriseGuaranteeController.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUserTracker.h"

@interface FHEnterpriseGuaranteeController ()

@property(nonatomic, copy) NSString *enterFrom;

@end

@implementation FHEnterpriseGuaranteeController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.enterFrom = paramObj.allParams[@"enter_from"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.customNavBarView.title.text = @"企业担保";
    UIImage *backImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor blackColor]);
    [self.customNavBarView.leftBtn setBackgroundImage:backImage forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:backImage forState:UIControlStateHighlighted];
    [self addGoDetailLog];
}

- (NSMutableDictionary *)getAddtionParams {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(screenFrame.size.width * 347/375) forKey:@"top_image_height"];
    return params;
}

- (void)addGoDetailLog {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"page_type"] = @"guarantee_introduction";
    dic[@"enter_from"] = self.enterFrom ?: @"be_null";
    TRACK_EVENT(@"go_detail", dic);
}

@end
