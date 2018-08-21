//
//  HTSVideoPlayColor.h
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//S1 ~ S21
#define LiveStandardColorS1  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S1"]]
#define LiveStandardColorS2  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S2"]]
#define LiveStandardColorS3  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S3"]]
#define LiveStandardColorS4  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S4"]]
#define LiveStandardColorS5  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S5"]]
#define LiveStandardColorS6  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S6"]]
#define LiveStandardColorS7  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S7"]]
#define LiveStandardColorS8  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S8"]]
#define LiveStandardColorS9  [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S9"]]
#define LiveStandardColorS10 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S10"]]
#define LiveStandardColorS11 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S11"]]
#define LiveStandardColorS17 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S17"]]
#define LiveStandardColorS19 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S19"]]
#define LiveStandardColorS20 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S20"]]
#define LiveStandardColorS21 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S21"]]
#define LiveStandardColorS22 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S22"]]
#define LiveStandardColorS23 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S23"]]
#define LiveStandardColorS24 [HTSVideoPlayColor colorWithHexString:[[[HTSVideoPlayColor sharedInstance] colors] objectForKey:@"S24"]]


@interface HTSVideoPlayColor : NSObject

@property (nonatomic, strong) NSDictionary *colors;

+ (instancetype)sharedInstance;

+ (UIColor *)colorWithHexString:(NSString *)hexStr;

@end
