//
//  TFAppInfosModel.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-27.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFAppInfosModel.h"

@implementation TFAppInfosModel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.uploadTime = [aDecoder decodeObjectForKey:@"uploadTime"];
        self.releaseID = [aDecoder decodeObjectForKey:@"releaseID"];
        self.appName = [aDecoder decodeObjectForKey:@"appName"];
        self.iconURL = [aDecoder decodeObjectForKey:@"iconURL"];
        self.updateNumber = [aDecoder decodeObjectForKey:@"updateNumber"];
        self.pkgName = [aDecoder decodeObjectForKey:@"pkgName"];
        self.ipaURL = [aDecoder decodeObjectForKey:@"ipaURL"];
        self.releaseBuild = [aDecoder decodeObjectForKey:@"releaseBuild"];
        self.ipaSize = [aDecoder decodeObjectForKey:@"ipaSize"];
        self.versionName = [aDecoder decodeObjectForKey:@"versionName"];
        self.ipaHash = [aDecoder decodeObjectForKey:@"ipaHash"];
        self.whatsNew = [aDecoder decodeObjectForKey:@"whatsNew"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_uploadTime forKey:@"uploadTime"];
    [aCoder encodeObject:_releaseID forKey:@"releaseID"];
    [aCoder encodeObject:_appName forKey:@"appName"];
    [aCoder encodeObject:_iconURL forKey:@"iconURL"];
    [aCoder encodeObject:_updateNumber forKey:@"updateNumber"];
    [aCoder encodeObject:_pkgName forKey:@"pkgName"];
    [aCoder encodeObject:_ipaURL forKey:@"ipaURL"];
    [aCoder encodeObject:_releaseBuild forKey:@"releaseBuild"];
    [aCoder encodeObject:_ipaSize forKey:@"ipaSize"];
    [aCoder encodeObject:_versionName forKey:@"versionName"];
    [aCoder encodeObject:_ipaHash forKey:@"ipaHash"];
    [aCoder encodeObject:_whatsNew forKey:@"whatsNew"];
    
}

@end
