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
