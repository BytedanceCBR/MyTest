//
//  AWEDetailLogoViewController.h
//  Pods
//
//  Created by Zuyang Kou on 22/08/2017.
//
//

#import <UIKit/UIKit.h>

@class TTShortVideoModel;
@class TSVVideoDetailPromptManager;

NS_ASSUME_NONNULL_BEGIN;

@interface AWEDetailLogoViewController : UIViewController

@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, strong, nullable) TTShortVideoModel *model;
@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;

- (void)refreshLogoImage;

@end

NS_ASSUME_NONNULL_END;
