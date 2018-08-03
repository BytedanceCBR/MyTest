//
//  AWEVideoDetailBottomControlOverlayViewController.h
//  Pods
//
//  Created by Zuyang Kou on 20/06/2017.
//
//

#import "AWEVideoDetailDefine.h"
#import "TSVControlOverlayViewController.h"
#import "TSVControlOverlayViewModel.h"
#import "TSVDetailViewModel.h"
#import <UIKit/UIKit.h>

@class TTShortVideoModel;
@class AWEVideoDetailControlAdOverlayViewController;
@class TSVVideoDetailPromptManager;

NS_ASSUME_NONNULL_BEGIN;

@interface AWEVideoDetailControlAdOverlayViewController : UIViewController <TSVControlOverlayViewController>

@property (nonatomic, strong, nullable) TTShortVideoModel *model;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, strong, nullable) TSVControlOverlayViewModel *viewModel;

@property (nonatomic, copy, nullable) void (^avatarOrUserNameDidClick)(void);

@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;

@property (nonatomic, weak, nullable) id<AWEVideoDetailTopViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END;
