//
//  TFAppInfosModel.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-27.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFAppInfosModel : NSObject<NSCoding>

@property(nonatomic, copy) NSNumber * uploadTime;
@property(nonatomic, copy) NSNumber * releaseID;
@property(nonatomic, copy) NSString * appName;
@property(nonatomic, copy) NSString * iconURL;
@property(nonatomic, copy) NSNumber * updateNumber;
@property(nonatomic, copy) NSString * pkgName;
@property(nonatomic, copy) NSString * ipaURL;
@property(nonatomic, copy) NSString * releaseBuild;
@property(nonatomic, copy) NSNumber * ipaSize;
@property(nonatomic, copy) NSString * versionName;
@property(nonatomic, copy) NSString * ipaHash;
@property(nonatomic, copy) NSString * whatsNew;
@end
