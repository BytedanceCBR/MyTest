//
//  TTShareAdapterSetting.h
//  Pods
//
//  Created by 张 延晋 on 3/7/15.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"

@protocol TTShareAppMethodSource <NSObject>

- (BOOL)isPadDevice;
- (BOOL)isZoneVersion;

- (UIViewController *)topmostViewController;

- (void)activityWillSharedWith:(id<TTActivityProtocol>)activity;
- (void)activityHasSharedWith:(id<TTActivityProtocol>)activity error:(NSError *)error desc:(NSString *)desc;

@end


@interface TTShareAdapterSetting : NSObject

@property (nonatomic, strong) id<TTShareAppMethodSource> methodSource;

+ (instancetype)sharedService;

- (BOOL)isPadDevice;
- (BOOL)isZoneVersion;

- (UIViewController *)topmostViewController;

- (void)activityWillSharedWith:(id<TTActivityProtocol>)activity;
- (void)activityHasSharedWith:(id<TTActivityProtocol>)activity error:(NSError *)error desc:(NSString *)desc;

- (void)setPanelClassName:(NSString *)panelClassName;
- (NSString *)getPanelClassName;

- (void)setForwardSharePanelClassName:(NSString *)forwardSharePanelClassName;
- (NSString *)getForwardSharePanelClassName;

@end
