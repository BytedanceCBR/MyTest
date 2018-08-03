//
//  TSVControlOverlayViewController.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 11/12/2017.
//

#import <Foundation/Foundation.h>

@class TSVControlOverlayViewModel;

@protocol TSVControlOverlayViewController <NSObject>

@property (nonatomic, strong, nullable) TSVControlOverlayViewModel *viewModel;

@end
