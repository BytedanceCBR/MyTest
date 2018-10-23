//
//  VideoMoreView.m
//  Video
//
//  Created by 于 天航 on 12-8-2.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VideoMoreView.h"
#import "SSTitleBarView.h"
#import "VideoRecommendViewController.h"
#import "SSAlertHeader.h"
#import "FeedbackViewController.h"
#import "APNsManager.h"
#import "AccountManager.h"
#import "AccountManagerViewController.h"
#import "AuthorityViewController.h"
#import "VideoRepinViewController.h"
#import "ShareOne.h"
#import "ShareOneHelper.h"
#import "VideoTitleLabel.h"
#import "UIColorAdditions.h"
#import "RecomDataManager.h"
#import "VideoLocalFavoriteManager.h"
#import "VideoListDataHeader.h"

#define ListCellHeight 44.f
#define ListViewFooterHeight 44.f

#define TrackMoreTabEventName @"more_tab"

#define kNewVideoSwitchTag 100021
#define kNotWifiSwitchTag 100023
#define kPositionRecordSwitchTag 100026
#define kOrientationLockSwitchTag 100027

/*
 * 帐号设置，我的收藏 (version1.2 移至“我的tab”中)
 * 精彩APP推荐，用户反馈，推荐给好友，去AppStore评分
 * 检查新版本，保存上次浏览位置, 锁定屏幕旋转, 新视频提醒，移动网络下流量提醒
 */
#define NumberOfSections 2
//#define NumberOfAccountRows 2
#define NumberOfOptionRows 3
#define NumberOfAlertRows 5

typedef enum {
//    AccountSection,
    OptionSection,
    AlertSection
} SectionType;

//typedef enum {
//    AccountRowTypeAccount,
//    AccountRowTypeFavorite
//} AccountRowType;

typedef enum {
    OptionRowTypeAppRecommend,
    OptionRowTypeFeedback,
    OptionRowTypeRecommendFriends
} OptionRowType;

typedef enum {
    AlertRowTypeNewVersion,
    AlertRowTypePositionRecord,
    AlertRowTypeOrientationLock,
    AlertRowTypeNewVideo,
    AlertRowTypeNotWifi
} AlertRowType;

@interface VideoMoreView () <UITableViewDelegate, UITableViewDataSource, AccountManagerViewControllerDelegate, AuthorityViewControllerDelegate, FeedbackViewControllerDelegate>

@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) UITableView *listView;

@end

@implementation VideoMoreView

@synthesize titleBar = _titleBar;
@synthesize listView = _listView;

- (void)dealloc
{
    self.titleBar = nil;
    self.listView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	[self loadView];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    tmpFrame.size.height = SSUIFloatNoDefault(@"vuTitleBarHeight");
    
    self.titleBar = [[[SSTitleBarView alloc] initWithFrame:tmpFrame orientation:self.interfaceOrientation] autorelease];
    _titleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _titleBar.titleBarEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *portraitBackgroundImage = [UIImage imageNamed:@"titlebarbg.png"];
    portraitBackgroundImage = [portraitBackgroundImage stretchableImageWithLeftCapWidth:portraitBackgroundImage.size.width/2
                                                                           topCapHeight:1.f];
    UIImageView *portraitBackgroundView = [[[UIImageView alloc] initWithImage:portraitBackgroundImage] autorelease];
    portraitBackgroundView.frame = _titleBar.bounds;
    _titleBar.portraitBackgroundView = portraitBackgroundView;
//    [_titleBar showBottomShadow];
    [self addSubview:_titleBar];

    VideoTitleLabel *titleLabel = [[[VideoTitleLabel alloc] init] autorelease];
    titleLabel.text = @"更多";
    [titleLabel sizeToFit];
    [_titleBar setCenterView:titleLabel];
    
    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;
    
    self.listView = [[[UITableView alloc] initWithFrame:tmpFrame style:UITableViewStyleGrouped] autorelease];
    _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _listView.backgroundColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuBackgroundColor")];
    _listView.separatorColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuMoreViewCellBorderColor")];
    _listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _listView.backgroundView = nil;
    _listView.delegate = self;
    _listView.dataSource = self;
    [self addSubview:_listView];
    
    [self bringSubviewToFront:_titleBar];
}

- (void)didAppear   // will not be invoke in viewController's viewWillAppear method
{
    [super didAppear];
    
    if (_listView) {
        [_listView reloadData];
    }
    trackEvent([SSCommon appName], TrackMoreTabEventName, @"enter");
}

#pragma mark - private

- (void)switchAction:(id)sender
{
    UISwitch *tmp = sender;

    if (tmp.tag == kNewVideoSwitchTag)  {
        closeAPNsNewAlert(!apnsNewAlertClosed());
        trackEvent([SSCommon appName], TrackMoreTabEventName, !apnsNewAlertClosed() ? @"notify_on" : @"notify_off");
    }
    else if (tmp.tag == kNotWifiSwitchTag) {
        setNotWifiAlertOn(!notWifiAlertOn());
        trackEvent([SSCommon appName], TrackMoreTabEventName, notWifiAlertOn()? @"2g_flow_alert_on" : @"2g_flow_alert_off");
    }
    else if (tmp.tag == kPositionRecordSwitchTag) {
        setPositionRecordOn(!positionRecordOn());
        trackEvent([SSCommon appName], TrackMoreTabEventName, positionRecordOn() ? @"progress_on" : @"progress_off");
    }
    else if (tmp.tag == kOrientationLockSwitchTag) {
        setOrientationLock(!orientationLocked());
        trackEvent([SSCommon appName], TrackMoreTabEventName, orientationLocked() ? @"auto_rotate_lock" : @"auto_rotate_unlock");
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == OptionSection) {
        return NumberOfOptionRows;
    }
    else if (section == AlertSection) {
        return NumberOfAlertRows;    
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *listCellIdentifier = @"list_cell_identifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:listCellIdentifier] autorelease];
    }
    else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryView = nil;
    }

    cell.backgroundColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuBackgroundColor")];
    cell.textLabel.textColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuMoreViewCellTextLabelTextColor")];
    cell.textLabel.font = ChineseFontWithSize(17.f);
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuMoreViewCellDetailTextLabelTextColor")];
    cell.detailTextLabel.font = ChineseFontWithSize(17.f);

    if (indexPath.section == OptionSection) {
        switch (indexPath.row) {
            case OptionRowTypeAppRecommend:
            {
                cell.textLabel.text = @"精彩应用推荐";
                
                if ([RecomDataManager isHasNewRecommend]) {
                    cell.detailTextLabel.text = @"new";
                }
                
                break;
            }
            case OptionRowTypeFeedback:
            {
                cell.textLabel.text = @"用户反馈";
                break;
            }
            case OptionRowTypeRecommendFriends:
            {
                cell.textLabel.text = @"推荐给朋友";
                break;
            }
                
            default:
                break;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == AlertSection) {
        switch (indexPath.row) {
            case AlertRowTypeNewVersion:
            {
                cell.textLabel.text = @"检查新版本";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"当前版本%@", [SSCommon versionName]] ;
                cell.detailTextLabel.textColor = [UIColor grayColor];
                cell.detailTextLabel.font = ChineseFontWithSize(14.f);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case AlertRowTypePositionRecord:
            {
                UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, (ListCellHeight - 30) / 2, 100, 30)];
                aSwitch.tag = kPositionRecordSwitchTag;
                [aSwitch setOn:positionRecordOn()];
                [aSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = aSwitch;
                [aSwitch release];
                
                cell.textLabel.text = @"保存浏览进度";
                break;
            }
            case AlertRowTypeNewVideo:
            {
                UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, (ListCellHeight - 30) / 2, 100, 30)];
                aSwitch.tag = kNewVideoSwitchTag;
                [aSwitch setOn:!apnsNewAlertClosed()];
                [aSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = aSwitch;
                [aSwitch release];
                
                cell.textLabel.text = NSLocalizedString(@"newVideoAlertStr", nil);
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                break;
            }
            case AlertRowTypeOrientationLock:
            {
                UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, (ListCellHeight - 30) / 2, 100, 30)];
                aSwitch.tag = kOrientationLockSwitchTag;
                [aSwitch setOn:orientationLocked()];
                [aSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = aSwitch;
                [aSwitch release];
                
                cell.textLabel.text = @"锁定屏幕旋转";
                break;
            }
            case AlertRowTypeNotWifi:
            {
                UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, (ListCellHeight - 30) / 2, 100, 30)];
                aSwitch.tag = kNotWifiSwitchTag;
                [aSwitch setOn:notWifiAlertOn()];
                [aSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = aSwitch;
                [aSwitch release];
                
                cell.textLabel.text = @"移动网络下流量提醒";
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ListCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == AlertSection) {
        return ListViewFooterHeight;
    }
    else {
        return 0.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == AlertSection) {
        
        UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _listView.bounds.size.width, ListViewFooterHeight)] autorelease];
        UILabel *copyRightLabel = [[[UILabel alloc] init] autorelease];
        copyRightLabel.backgroundColor = [UIColor clearColor];
        copyRightLabel.font = ChineseFontWithSize(12.f);
        copyRightLabel.textColor = [UIColor colorWithHexString:@"999999"];
        
#ifdef DEBUG
        copyRightLabel.text = [NSString stringWithFormat:@"©飞飞出品  feifei.com Debug %@", CHANNEL_NAME];
#else
        copyRightLabel.text = @"©飞飞出品  feifei.com";
#endif
        [copyRightLabel sizeToFit];
        [footer addSubview:copyRightLabel];
        
        copyRightLabel.center = CGPointMake(footer.bounds.size.width/2, footer.bounds.size.height/2);
        
        return footer;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == OptionSection)
    {
        switch (indexPath.row) {
            case OptionRowTypeAppRecommend:
            {
                VideoRecommendViewController *control = [[[VideoRecommendViewController alloc] init] autorelease];

                UINavigationController *nav = [SSCommon topViewControllerFor:self].navigationController;
                [nav pushViewController:control animated:YES];
                
                [RecomDataManager setHasNewRecommend:YES];
                
                trackEvent([SSCommon appName], TrackMoreTabEventName, @"recommend_button");

                break;
            }
            case OptionRowTypeFeedback:
            {
                trackEvent([SSCommon appName], TrackMoreTabEventName, @"feedback");
                
                FeedbackViewController *controller = [[[FeedbackViewController alloc] init] autorelease];
                controller.delegate = self;

                UINavigationController *nav = [SSCommon topViewControllerFor:self].navigationController;
                [nav pushViewController:controller animated:YES];
                
                break;
            }
            case OptionRowTypeRecommendFriends:
            {
                ShareOneHelper * sharedHelper = [ShareOneHelper sharedHelper];
                sharedHelper.subject = nil;  
                sharedHelper.body = NSLocalizedString(@"ShareMsgBody", nil);
                sharedHelper.smsBody = sharedHelper.body;
                sharedHelper.subject = NSLocalizedString(@"ShareMsgSubject", nil);
                sharedHelper.showShareOne = NO;
                sharedHelper.showCopy = NO;
                
                UIViewController *topController = [SSCommon topViewControllerFor:self];
                if ([ShareOneHelper canSendMailAndText]) {
                    [sharedHelper shareWithViewController:topController];
                }
                
                trackEvent([SSCommon appName], TrackMoreTabEventName, @"share_app");
                
                break;
            }
            default:
                break;
        }
    }
    else if (indexPath.section == AlertSection) {
        
        switch (indexPath.row) {
            case AlertRowTypeNewVersion:
            {
                [[NewVersionAlertManager alertManager] startAlertAutoCheck:NO];
                
                trackEvent([SSCommon appName], TrackMoreTabEventName, @"check_version");
                
                break;
            }
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AccountManageViewControllerDelegate

- (void)accountManagerControllerCancelled:(AccountManagerViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AuthorityViewControllerDelegate

- (void)authorityViewControllerDone:(AuthorityViewController *)controller userInfo:(id)userinfo
{
    [controller.navigationController popViewControllerAnimated:YES];
    [_listView reloadData];
}

#pragma mark - FeedbackViewControllerDelegate

- (void)feedbackViewControllerCancelled:(FeedbackViewController *)controller
{

	UINavigationController *nav = [SSCommon topViewControllerFor:self].navigationController;
    [nav popViewControllerAnimated:YES];
}

@end


