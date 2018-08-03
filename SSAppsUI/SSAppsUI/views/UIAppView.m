//
//  UIAppView.m
//  SSAppsUI
//
//  Created by Dianwei on 13-9-4.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import "UIAppView.h"
#import "ASIHTTPRequest.h"
#import "URLSetting.h"
#import "NSString+SBJSON.h"
#import "AppsUIUtil.h"
#import "AppDetailViewController.h"

@interface UIAppView()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, retain)UITableView *appTableView;
@property(nonatomic, retain)ASIHTTPRequest *request;
@property(nonatomic, retain)NSMutableArray *appList;
@end

@implementation UIAppView

- (void)dealloc
{
    self.appTableView = nil;
    [self.request cancel];
    self.request = nil;
    self.appList = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.appTableView = [[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain] autorelease];
        _appTableView.delegate = self;
        _appTableView.dataSource = self;
        self.appList = [NSMutableArray arrayWithCapacity:10];
        [self addSubview:_appTableView];
        [self refresh];
    }
    
    return self;
}

- (void)refresh
{
    [self startRequest];
}

- (void)startRequest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_request cancel];
        self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[URLSetting baseURLString]]];
        NSLog(@"request:%@, url:%@", _request, _request.url);
        [_request startSynchronous];
        NSError *error = _request.error;
        if(error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            NSString *response = _request.responseString;
            [_appList removeAllObjects];
            [_appList addObjectsFromArray:[response JSONValue]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_appTableView reloadData];
            });
            
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(indexPath.row < _appList.count)
    {
        NSDictionary *data = _appList[indexPath.row];
        cell.textLabel.text = [data objectForKey:@"app_name"];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _appList.count)
    {
        AppDetailViewController *controller = [[AppDetailViewController alloc] init];
        NSDictionary *data = _appList[indexPath.row];
        [controller refreshWithAppID:[data objectForKey:@"id"] name:[data objectForKey:@"app_name"]];
        UIViewController *topController = [AppsUIUtil topViewControllerFor:self];
        [topController.navigationController pushViewController:controller animated:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
