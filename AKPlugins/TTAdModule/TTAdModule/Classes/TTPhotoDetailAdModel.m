//
//  TTPhotoDetailAdModel.m
//  Article
//
//  Created by yin on 16/8/1.
//
//

#import "TTPhotoDetailAdModel.h"
#import <TTBaseLib/TTBaseMacro.h>

#define kSeperatorSchemaString        @"://"

@implementation TTPhotoDetailAdModel

@end

@implementation TTPhotoDetailAdImageRecomModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"ID"}];
}

- (TTPhotoDetailAdActionType) adActionType {
    if ([self.type isEqualToString:@"web"]) {
        return TTPhotoDetailAdActionType_Web;
    } else if ([self.type isEqualToString:@"action"]) {
        return TTPhotoDetailAdActionType_Action;
    } else if ([self.type isEqualToString:@"form"]) {
        return TTPhotoDetailAdActionType_App;
    }else if ([self.type isEqualToString:@"counsel"]) {
        return TTPhotoDetailAdActionType_Counsel;
    }else if ([self.type isEqualToString:@"app"]){
        return TTPhotoDetailAdActionType_App;
    }
    return TTPhotoDetailAdActionType_Web;
}

- (NSString *)appURL {
    if (!isEmptyString(_appURL)) {
        return _appURL;
    }
    NSRange seperateRange = [self.open_url rangeOfString:kSeperatorSchemaString];
    if (seperateRange.length > 0) {
        _appURL = [self.open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
        
        _tabURL = [self.open_url substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.open_url length] - NSMaxRange(seperateRange))];
    } else {
        _appURL = self.open_url;
    }
    return _appURL;
}

- (NSString *)tabURL {
    if (!isEmptyString(_tabURL)) {
        return _tabURL;
    }
    
    NSRange seperateRange = [self.open_url rangeOfString:kSeperatorSchemaString];
    if (seperateRange.length > 0) {
        _appURL = [self.open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
        
        _tabURL = [self.open_url substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.open_url length] - NSMaxRange(seperateRange))];
    } else {
        _appURL = self.open_url;
    }
    return _tabURL;
}

- (NSDictionary *)mointerInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (!isEmptyString(self.ID)) {
        info[@"ad_id"] = [NSString stringWithFormat:@"%@", self.ID ];
    }
    
    if (!isEmptyString(self.log_extra)) {
        info[@"log_extra"] = self.log_extra;
    }
    
    if (!isEmptyString(self.type)) {
        info[@"ad_actionType"] = self.type;
    }
    
    return info;
}

@end


@implementation TTAdImageModel

@end


@implementation TTPhotoDetailAdUrlListModel

@end
