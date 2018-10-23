//
//  VideoHistoryView.m
//  Video
//
//  Created by Kimi on 12-10-22.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoHistoryView.h"
#import "VideoHistoryManager.h"
#import "VideoListCell.h"
#import "VideoData.h"
#import "VideoDetailViewController.h"

#define TrackHistoryTabEventName @"history_tab"

@interface VideoHistoryView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) NSArray *historyList;
@end

@implementation VideoHistoryView

- (void)dealloc
{
    self.listView = nil;
    self.historyList = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.listView = [[[UITableView alloc] initWithFrame:self.bounds] autorelease];
        _listView.delegate = self;
        _listView.dataSource = self;
        [self addSubview:_listView];
    }
    return self;
}

- (void)willAppear
{
    [super willAppear];
    self.historyList = [[VideoHistoryManager sharedManager] historyDataList];
    
    [_listView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_historyList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ret = 0.f;
    
    ret = SSUIFloatNoDefault(@"vuListCellHeight");
    if ([((VideoData *)[_historyList objectAtIndex:indexPath.row]).socialActionStr length] > 0) {
        ret += SSUIFloatNoDefault(@"vuSocialActionLabelHeight") + SSUIFloatNoDefault(@"vuSocialActionLabelTopMargin");
    }
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *historyCellID = @"historyCellID";
    
    VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCellID];
    if (cell == nil) {
        cell = [[[VideoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:historyCellID] autorelease];
    }
    
    [cell setVideoData:[_historyList objectAtIndex:indexPath.row] type:VideoListCellTypeNormal];
    cell.trackEventName = TrackHistoryTabEventName;
    [cell refreshUI];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_historyList count]) {
        VideoDetailViewController *controller = [[[VideoDetailViewController alloc] init] autorelease];
        controller.video = [_historyList objectAtIndex:indexPath.row];
        
        UINavigationController *nav = [SSCommon topViewControllerFor:self].navigationController;
        [nav pushViewController:controller animated:YES];
        
        trackEvent([SSCommon appName], TrackHistoryTabEventName, @"click_cell");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
