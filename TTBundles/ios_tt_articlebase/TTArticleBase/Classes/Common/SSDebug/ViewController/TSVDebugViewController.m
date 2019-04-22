//
//  TSVDebugViewController.m
//  News
//
//  Created by Zuyang Kou on 27/11/2017.
//
#if INHOUSE

#import "TSVDebugViewController.h"
#import <TSVDebugInfoConfig.h>
#import "AWEVideoConstants.h"
#import "TTSettingsManager+SaveSettings.h"

@interface TSVDebugViewController ()

@end

@implementation TSVDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *dataSource = [NSMutableArray array];

    NSMutableArray *itemArray = [NSMutableArray array];
    STTableViewCellItem *item_39 = [[STTableViewCellItem alloc] initWithTitle:@"第三个tab切换为小视频tab" target:self action:NULL];
    item_39.switchStyle = YES;
    item_39.switchAction = @selector(_switchToThirdTabHTS:);
    item_39.checked = [SSCommonLogic isThirdTabHTSEnabled];
    [itemArray addObject:item_39];

    STTableViewCellItem *item_40 = [[STTableViewCellItem alloc] initWithTitle:@"第四个tab切换为小视频tab" target:self action:NULL];
    item_40.switchStyle = YES;
    item_40.switchAction = @selector(_switchForthTabHtsTab:);
    item_40.checked = [SSCommonLogic isForthTabHTSEnabled];
    [itemArray addObject:item_40];

    STTableViewCellItem *item_43 = [[STTableViewCellItem alloc] initWithTitle:@"小视频开启上下滑动（进详情页前切换才生效）" target:self action:NULL];
    item_43.switchStyle = YES;
    item_43.switchAction = @selector(_switchToScrollDirectionVertical:);
    item_43.checked = [[SSCommonLogic shortVideoScrollDirection] isEqualToNumber:@(2)];
    [itemArray addObject:item_43];

    STTableViewCellItem *recommendDebugItem = [[STTableViewCellItem alloc] init];
    recommendDebugItem.title = @"推荐调试信息开关";
    recommendDebugItem.switchStyle = YES;
    recommendDebugItem.checked = [[TSVDebugInfoConfig config] debugInfoEnabled];
    recommendDebugItem.target = self;
    recommendDebugItem.switchAction = @selector(switchRecommendDebug:);
    [itemArray addObject:recommendDebugItem];
    
    STTableViewCellItem *item_44 = [[STTableViewCellItem alloc] initWithTitle:@"小视频使用自研播放器" target:self action:nil];
    item_44.switchStyle = YES;
    item_44.switchAction = @selector(_switchToShortVideoOwnPlayer:);
    item_44.checked = (IESVideoPlayerTypeSpecify == 1);
    [itemArray addObject:item_44];

    STTableViewCellItem *detailStyleItem = [[STTableViewCellItem alloc] initWithTitle:@"详情页 UI 切换" target:self action:nil];
    detailStyleItem.textFieldStyle = YES;
    detailStyleItem.textFieldAction = @selector(switchDetailUI:);
    [itemArray addObject:detailStyleItem];

    STTableViewSectionItem *section = [[STTableViewSectionItem alloc] initWithSectionTitle:@"小视频" items:itemArray];
    [dataSource addObject:section];

    self.dataSource = dataSource;
}

- (void)_switchToThirdTabHTS:(UISwitch *)uiswitch {
    [SSCommonLogic setHTSTabSwitch:uiswitch.isOn ? 2:0];
}

- (void)_switchForthTabHtsTab:(UISwitch *)uiswitch {
    [SSCommonLogic setHTSTabSwitch:uiswitch.isOn ? 1:0];
}

- (void)_switchToScrollDirectionVertical:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setShortVideoScrollDirection:@(2)];
    } else {
        [SSCommonLogic setShortVideoScrollDirection:@(1)];
    }
}

- (void)switchRecommendDebug:(UISwitch *)aSwitch
{
    [[TSVDebugInfoConfig config] setDebugInfoEnabled:aSwitch.on];
}

- (void)_switchToShortVideoOwnPlayer:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setHTSVideoPlayerType:1];
    } else {
        [SSCommonLogic setHTSVideoPlayerType:0];
    }
}

- (IBAction)switchDetailUI:(UITextField *)sender
{
    [[TTSettingsManager sharedManager] updateSetting:@([sender.text integerValue])
                                              forKey:@"tt_huoshan_detail_control_ui_type"];
}

@end

#endif
