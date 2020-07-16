//
//  FHDetailFeedbackButton.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/9.
//

#import "FHDetailFeedbackButton.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "FHUserTracker.h"
#import "FHEnvContext.h"
#import "FHURLSettings.h"
#import "TTSandBoxHelper.h"
#import "TTRouteDefine.h"
#import "TTRoute.h"

@interface FHDetailFeedbackButton ()

@property (nonatomic, strong) NSDictionary *detailTracerDic;
@property (nonatomic, strong) NSDictionary *listLogPB;
@property (nonatomic, copy)   NSString *reportUrl;
@property (nonatomic, strong) NSDictionary *jsonDic;

@end

@implementation FHDetailFeedbackButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self setImage:[UIImage imageNamed:@"reportimage"] forState:UIControlStateNormal];
    [self setTitle:@"举报" forState:UIControlStateNormal];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:@"举报" attributes:@{
                                        NSFontAttributeName: [UIFont themeFontRegular:12],
                                        NSForegroundColorAttributeName: [UIColor themeGray3],
    }];
    [self setAttributedTitle:attriStr forState:UIControlStateNormal];
    [self addTarget:self action:@selector(feedBackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    
}

- (void)feedBackButtonClick:(UIButton *)button {
    NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.listLogPB ? self.listLogPB : @"be_null";
    [FHUserTracker writeEvent:@"click_feedback" params:tracerDic];
    [self gotoReportVC];
}

- (void)updateWithDetailTracerDic:(NSDictionary *)detailTracerDic listLogPB:(NSDictionary *)listLogPB jsonDic:(NSDictionary *)jsonDic reportUrl:(NSString *)reportUrl {
    self.detailTracerDic = detailTracerDic;
    self.listLogPB = listLogPB;
    self.jsonDic = jsonDic;
    self.reportUrl = reportUrl;
}

// 二手房-房源问题反馈
- (void)gotoReportVC {
    if (self.reportUrl.length > 0 && self.jsonDic) {
        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{ @"data": self.jsonDic };
        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        if (commonParams == nil) {
            commonParams = @{};
        }
        NSDictionary *commonParamsData = @{ @"data": commonParams };
        NSDictionary *jsParams = @{ @"requestPageData": pageData,
                                    @"getNetCommonParams": commonParamsData };
        NSString *host = [FHURLSettings baseURL] ? : @"https://i.haoduofangs.com";
        if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults]boolForKey:@"BOE_OPEN_KEY"]) {
            host = @"http://i.haoduofangs.com.boe-gateway.byted.org";
        }
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", host, self.reportUrl];
        NSDictionary *info = @{ @"url": urlStr, @"fhJSParams": jsParams, @"title": @"房源问题反馈" };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}

@end
