//
//  FHRealtorDetailWebViewController.m
//  Article
//
//  Created by leo on 2019/1/7.
//

#import "FHRealtorDetailWebViewController.h"
#import <TTRJSBForwarding.h>
#import <TTRStaticPlugin.h>
#import "Bubble-Swift.h"
#import "TTRoute.h"

@interface FHRealtorDetailWebViewController ()
{
    FHPhoneCallViewModel* _phoneCallViewModel;
    HouseRentTracer* _tracerModel;
}
@end

@implementation FHRealtorDetailWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _phoneCallViewModel = [[FHPhoneCallViewModel alloc] init];
    _tracerModel = [self.userInfo allInfo][@"trace"];
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        NSString* realtorId = params[@"realtor_id"];
        NSString* phone = params[@"phone"];
        if (realtorId != nil && phone != nil) {
            [_phoneCallViewModel requestVirtualNumberAndCallWithRealtorId:realtorId
                                                               traceModel:_tracerModel
                                                                    phone:phone
                                                                  houseId:_tracerModel.groupId
                                                                 searchId:_tracerModel.searchId
                                                                   imprId: _tracerModel.imprId];
        }
        completion(TTRJSBMsgSuccess, @{});
    } forMethodName:@"phoneSwitch"];
}

@end
