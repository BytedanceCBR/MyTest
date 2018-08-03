//
//  AppDetailView.m
//  SSAppsUI
//
//  Created by Dianwei on 13-9-5.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import "AppDetailView.h"
#import "ASIHTTPRequest.h"
#import "URLSetting.h"
#import "NSString+SBJSON.h"
#import "DetailImageViewController.h"
#import "AppsUIUtil.h"

@interface AppDetailView()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, retain)UITableView *detailTableView;
@property(nonatomic, retain)ASIHTTPRequest *request;
@property(nonatomic, retain)NSMutableArray *detailList;
@property(nonatomic, retain)NSString *appID;
@end

@implementation AppDetailView

- (void)dealloc
{
    self.detailTableView = nil;
    [self.request cancel];
    self.request = nil;
    self.detailList = nil;
    self.appID = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.detailTableView = [[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain] autorelease];
        _detailTableView.delegate = self;
        _detailTableView.dataSource = self;
        self.detailList = [NSMutableArray arrayWithCapacity:10];
        [self addSubview:_detailTableView];
    }
    
    return self;
}

- (void)refreshWithAppID:(NSString*)appID
{
    self.appID = appID;
    [self startRequest];
}

- (void)startRequest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_request cancel];
        NSString *urlString = [NSString stringWithFormat:@"%@%@/detail", [URLSetting baseURLString], _appID];
        self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
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
            [_detailList removeAllObjects];
            [_detailList addObjectsFromArray:[response JSONValue]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_detailTableView reloadData];
            });
            
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _detailList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(indexPath.row < _detailList.count)
    {
        NSDictionary *data = _detailList[indexPath.row];
        cell.textLabel.text = [data objectForKey:@"detail_name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"版本:%@", [data objectForKey:@"version"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _detailList.count)
    {
        NSDictionary *data = _detailList[indexPath.row];
        DetailImageViewController *controller = [[DetailImageViewController alloc] init];
        [controller refreshWithDetailID:[data objectForKey:@"id"]];
        UIViewController *topController = [AppsUIUtil topViewControllerFor:self];
        [topController.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}


@end
