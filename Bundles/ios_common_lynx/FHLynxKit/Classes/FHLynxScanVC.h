//
//  FHLynxScanVC.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface History : NSObject

+ (void)recordScanResult:(NSString*)url;
+ (NSArray<NSString*>*)getScanHistory;

+ (void)recordUrlInTextField:(NSString*)url;
+ (NSString*)getHistoryUrlInTextField;

@end


@interface FHLynxScanVC : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@end

NS_ASSUME_NONNULL_END
