//
//  FHEnterpriseGuaranteeController.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/7/1.
//

#import "FHEnterpriseGuaranteeController.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHEnterpriseGuaranteeController ()

@end

@implementation FHEnterpriseGuaranteeController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
      
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
}

- (NSMutableDictionary *)getAddtionParams {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(screenFrame.size.width * 347/375) forKey:@"top_image_height"];
    return params;
}

@end
