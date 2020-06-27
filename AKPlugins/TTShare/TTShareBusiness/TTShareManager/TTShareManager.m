//
//  TTShareManager.m
//  Pods
//
//  Created by 延晋 张 on 16/6/1.
//
//

#import "TTShareManager.h"
#import "TTActivitiesManager.h"
#import "TTShareAdapterSetting.h"
#import "FHIMShareActivity.h"

@interface  TTShareManager() <TTActivityPanelDelegate>

@property (nonatomic, strong) id<TTActivityPanelControllerProtocol> panelController;
@property (nonatomic, copy) NSString *panelClassName;

@end

@implementation TTShareManager

+ (void)addUserDefinedActivitiesFromArray:(NSArray *)activities
{
    TTActivitiesManager *manager = [TTActivitiesManager sharedInstance];
    [manager addValidActivitiesFromArray:[activities copy]];
}

+ (void)addUserDefinedActivity:(id <TTActivityProtocol>)activity
{
    TTActivitiesManager *manager = [TTActivitiesManager sharedInstance];
    [manager addValidActivity:activity];
}

+ (BOOL)checkContentIsValid:(NSArray *)contentArray
{
    TTActivitiesManager *manager = [TTActivitiesManager sharedInstance];
    NSArray *activities = [manager validActivitiesForContent:contentArray];
    if (activities.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)updateBizTraceExtraInfo:(NSDictionary *)extraInfo activity:(id <TTActivityProtocol>)activity{
    TTActivitiesManager *manager = [TTActivitiesManager sharedInstance];
   id <TTActivityProtocol> activityShow = [manager getActivityByItem:activity];
    if ([activityShow isKindOfClass:[FHIMShareActivity class]]) {
        TTActivitiesManager *manager = [TTActivitiesManager sharedInstance];
        FHIMShareActivity *activityHouse =  (FHIMShareActivity *)activityShow;
        if (activityHouse) {
              activityHouse.extraInfo = extraInfo;
        }
    }
}

- (void)displayActivitySheetWithContent:(NSArray *)contentArray
{
    NSArray *activities = [[TTActivitiesManager sharedInstance] validActivitiesForContent:contentArray];
    if (![[activities firstObject] isKindOfClass:[NSArray class]]) {
        activities = @[activities];
    }
    Class panelClass = NSClassFromString(self.panelClassName);
    if (Nil == panelClass) {
        panelClass = NSClassFromString([[TTShareAdapterSetting sharedService] getPanelClassName]);
    }
    if (panelClass && [panelClass conformsToProtocol:@protocol(TTActivityPanelControllerProtocol)]) {
        id<TTActivityPanelControllerProtocol> panelC = [[panelClass alloc]
                                                        initWithItems:activities cancelTitle:@"取消"];
        self.panelController = panelC;
        panelC.delegate = self;
        [panelC show];
    } else {
        NSLog(@"无可用的ui组件！");
    }
}

- (void)displayForwardSharePanelWithContent:(NSArray *)contentArray
{
    NSArray *activities = [[TTActivitiesManager sharedInstance] validActivitiesForContent:contentArray];
    if (![[activities firstObject] isKindOfClass:[NSArray class]]) {
        activities = @[activities];
    }
    Class  panelClass = NSClassFromString([[TTShareAdapterSetting sharedService] getForwardSharePanelClassName]);
    if (panelClass && [panelClass conformsToProtocol:@protocol(TTActivityPanelControllerProtocol)]) {
        id<TTActivityPanelControllerProtocol> panelC = [[panelClass alloc]
                                                        initWithItems:activities cancelTitle:@"取消"];
        self.panelController = panelC;
        panelC.delegate = self;
        [panelC show];
    } else {
        NSLog(@"无可用的ui组件！");
    }
}

- (void)shareToActivity:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController
{
    id <TTActivityProtocol> activity = [[TTActivitiesManager sharedInstance] getActivityByItem:contentItem];
    if ([self.delegate respondsToSelector:@selector(shareManager:clickedWith:sharePanel:)]) {
        [self.delegate shareManager:self clickedWith:activity sharePanel:nil];
    }
    [activity shareWithContentItem:contentItem presentingViewController:presentingViewController onComplete:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
        if ([self.delegate respondsToSelector:@selector(shareManager:completedWith:sharePanel:error:desc:)]) {
            [self.delegate shareManager:self completedWith:activity sharePanel:nil error:error desc:desc];
        }
    }];
}

- (void)setPanelClassName:(NSString *)panelClassName {
    _panelClassName = panelClassName;
}

#pragma mark - TTActivityPanelDelegate

- (void)activityPanel:(id<TTActivityPanelControllerProtocol>)panel
          clickedWith:(id<TTActivityProtocol>)activity
{
    if ([self.delegate respondsToSelector:@selector(shareManager:clickedWith:sharePanel:)]) {
        [self.delegate shareManager:self clickedWith:activity sharePanel:panel];
    }
}

- (void)activityPanel:(id<TTActivityPanelControllerProtocol>)panel
        completedWith:(id<TTActivityProtocol>)activity
                error:(NSError *)error
                 desc:(NSString *)desc
{
    if ([self.delegate respondsToSelector:@selector(shareManager:completedWith:sharePanel:error:desc:)]) {
        [self.delegate shareManager:self completedWith:activity sharePanel:panel error:error desc:desc];
    }
}

@end
