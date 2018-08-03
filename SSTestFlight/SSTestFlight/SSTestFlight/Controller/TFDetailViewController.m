//
//  TFDetailViewController.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-29.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFDetailViewController.h"
#import "TFDetailView.h"

@interface TFDetailViewController ()

@property(nonatomic, retain)TFDetailView * detailView;
@property(nonatomic, retain)TFAppInfosModel * model;
@property(nonatomic, assign)NSUInteger listIndex;

@end

@implementation TFDetailViewController

- (void)dealloc
{
    self.model = nil;
    self.detailView = nil;
    [super dealloc];
}

- (id)initWithTFAppInfosModel:(TFAppInfosModel *)model infoIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.model = model;
        self.listIndex = index;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailView = [[[TFDetailView alloc] initWithFrame:self.view.bounds] autorelease];
    [self.view addSubview:_detailView];
    [_detailView setAppInfosModel:_model modelIndex:_listIndex];
}

@end
