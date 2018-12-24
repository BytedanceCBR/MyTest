//
//  FHHomeSearchPanelViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeSearchPanelViewModel.h"
#import "FHMainApi.h"
#import "FHHomeConfigManager.h"
#import "FHEnvContext.h"
#import "ReactiveObjC.h"
#import "TTRoute.h"

@interface FHHomeSearchPanelViewModel ()

@property(nonatomic, strong) FHHomeSearchPanelView *suspendSearchBar;
@property(nonatomic, strong) NSString *currentCityName;

@end

@implementation FHHomeSearchPanelViewModel

- (instancetype)initWithSearchPanel:(FHHomeSearchPanelView *)panel
{
    self = [super init];
    if (self) {
        self.suspendSearchBar = panel;
        [self bindCountryBtnClickAction];
        [self bindSearchBtnClickAction];
        [self addListenerHomePullDown];
        [self addListenerConfigChanged];
    }
    return self;
}

- (void)bindCountryBtnClickAction
{
    [[[self.suspendSearchBar.changeCountryBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x)
    {
        NSString *url = [NSString stringWithFormat:@"sslocal://relation/following?uid=%@",@"xxx"];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
        
        NSLog(@"tap Country btn");

    }];
}

- (void)bindSearchBtnClickAction
{
    [[[self.suspendSearchBar.searchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x)
      {
          NSLog(@"tap search btn");
      }];
}

- (void)addListenerHomePullDown
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPullDown:) name:@"kHomePagePullDownNotification" object:nil];
}

- (void)addListenerConfigChanged
{
    WeakSelf;
    [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        [self fetchSearchPanelRollData];
    }];
}

- (void)userPullDown:(NSNotification *)notification
{
    if (kIsNSDictionary(notification.userInfo)) {
        if (notification.userInfo[@"needPullDownData"]) {
            [self fetchSearchPanelRollData];
        }
    }
}

- (void)fetchSearchPanelRollData
{
    NSMutableDictionary *requestDict = [NSMutableDictionary new];

    [requestDict setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    [requestDict setValue:@"app" forKey:@"source"];

    WeakSelf;
    [self requestPanelRollScreen:requestDict completion:^(FHHomeRollModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        if (kIsNSArray(model.data.data)) {
            //to do
            NSArray<FHHomeRollDataDataModel> *listData = model.data.data;
            
            NSMutableArray <NSString *> * titleArrays = [NSMutableArray new];
            
            for (FHHomeRollDataDataModel *dataModel in listData) {
                if (kIsNSString(dataModel.text)) {
                    [titleArrays addObject:dataModel.text];
                }
            }
            self.suspendSearchBar.searchTitles = titleArrays;
        }
    }];
    
    self.suspendSearchBar.countryLabel.text = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
}

- (void)requestPanelRollScreen:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeRollModel *model, NSError *error))completion
{
    [FHMainApi requestHomeSearchRoll:param completion:^(FHHomeRollModel * _Nonnull model, NSError * _Nonnull error) {
        if (!completion) {
            return ;
        }
        completion(model,error);
    }];
}


@end
