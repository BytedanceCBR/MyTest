//
//  DetailImageViewController.m
//  SSAppsUI
//
//  Created by Dianwei on 13-9-5.
//  Copyright (c) 2013年 Dianwei. All rights reserved.
//

#import "DetailImageViewController.h"
#import "ASIHTTPRequest.h"
#import "URLSetting.h"
#import "NSString+SBJSON.h"

@interface DetailImageViewController ()<MWPhotoBrowserDelegate>
@property(nonatomic, retain)ASIHTTPRequest *request;
@property(nonatomic, retain)NSMutableArray *imageList;
@property(nonatomic, retain)NSString *detailID;
@end

@implementation DetailImageViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        self.delegate = self;
        self.displayActionButton = YES;
        self.imageList = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

- (void)refreshWithDetailID:(NSString*)detailID
{
    self.detailID = detailID;
    [self startRequest];
}

- (void)startRequest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_request cancel];
        NSString *urlString = [NSString stringWithFormat:@"%@%@/imageList", [URLSetting baseURLString], _detailID];
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
            NSArray *dataArray = [response JSONValue];
            dataArray = [dataArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDictionary *dict1 = (NSDictionary*)obj1;
                NSDictionary *dict2 = (NSDictionary*)obj2;
                NSComparisonResult result = NSOrderedSame;
                if([[dict1 objectForKey:@"order"] intValue] > [[dict2 objectForKey:@"order"] intValue])
                {
                    result = NSOrderedDescending;
                }
                else if([[dict1 objectForKey:@"order"] intValue] < [[dict2 objectForKey:@"order"] intValue])
                {
                    result = NSOrderedAscending;
                }
                
                return result;
            }];
            
            [_imageList removeAllObjects];
            for(NSDictionary *data in dataArray)
            {
                NSString *url = [data objectForKey:@"url"];
                MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
                [_imageList addObject:photo];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshUI];
            });
            
        }
    });
}

- (void)refreshUI
{
    [self reloadData];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [_imageList count];
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [_imageList count])
    {
        return _imageList[index];
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
