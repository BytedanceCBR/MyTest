//
//  FHHouseDetailContactViewModel.m
//  Pods
//
//  Created by 张静 on 2019/2/13.
//

#import "FHHouseDetailContactViewModel.h"
#import "TTRoute.h"

@interface FHHouseDetailContactViewModel ()

@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;

@end

@implementation FHHouseDetailContactViewModel

-(instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar
{
    self = [super init];
    if (self) {
        
        _navBar = navBar;
        _bottomBar = bottomBar;
        
        __weak typeof(self)wself = self;
        _bottomBar.bottomBarContactBlock = ^{
            [wself contactAction];
        };
        _bottomBar.bottomBarLicenseBlock = ^{
            [wself licenseAction];
        };
        _bottomBar.bottomBarRealtorBlock = ^{
            [wself jump2RealtorDetail];
        };
    }
    return self;
}

- (void)setContactPhone:(FHDetailOldDataContactModel *)contactPhone
{
    _contactPhone = contactPhone;
    NSString *contactTitle = @"电话咨询";
    if (contactPhone.phone.length < 1) {
        if (self.houseType == FHHouseTypeNeighborhood) {
            contactTitle = @"咨询经纪人";
        }else {
            contactTitle = @"询底价";
        }
    }
    [self.bottomBar refreshBottomBar:contactPhone contactTitle:contactTitle];
}

- (void)contactAction
{
    if (self.contactPhone.phone.length < 1) {
        // 填表单
    }else {
        // 拨打电话
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", self.contactPhone.phone];
        NSURL *url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    }
    // 关注功能
}

- (void)licenseAction
{
    
}

- (void)jump2RealtorDetail
{
    
    
//    if let realtorId = contactPhone.realtorId ,
//        let traceModel = self.detailPageViewModel?.tracerModel {
//            traceModel.elementFrom = "old_detail_button"
//            let reportParams = getRealtorReportParams(traceModel: traceModel, rank: "0")
//            let openUrl = "fschema://realtor_detail"
//            let jumpUrl = "\(EnvContext.networkConfig.host)/f100/client/realtor_detail?realtor_id=\(realtorId)&report_params=\(reportParams)"
//            let theTraceModel = traceModel.copy() as? HouseRentTracer
//            theTraceModel?.elementFrom = "old_detail_button"
//            theTraceModel?.enterFrom = "old_detal"
//            let info: [String: Any] = ["url": jumpUrl,
//                                       "title": "经纪人详情页",
//                                       "realtorId": realtorId,
//                                       "delegate": delegate,
//                                       "trace": theTraceModel]
//            let userInfo = TTRouteUserInfo(info: info)
//            TTRoute.shared()?.openURL(byViewController: URL(string: openUrl), userInfo: userInfo)
}

@end
