//
//  TTVVideoDetailRelatedVideoViewController.h
//  Article
//
//  Created by pei yun on 2017/5/9.
//
//

#import <TTUIWidget/SSViewControllerBase.h>
#import "TTVVideoInformationSyncProtocol.h"
#import "TTVDetailContext.h"
@class TTVVideoInformationResponse;
@interface TTVVideoDetailRelatedVideoViewController : SSViewControllerBase <TTVVideoInformationSyncProtocol,TTVDetailContext>

@property (nonatomic, strong) TTVVideoInformationResponse *videoInfo;
@property (nonatomic, weak) id<TTVVideoDetailHomeToRelatedVideoVCActionProtocol> homeActionDelegate;
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;


@end
