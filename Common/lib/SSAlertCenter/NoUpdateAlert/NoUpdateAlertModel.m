//
//  NoUpdateAlertModel.m
//  Article
//
//  Created by Yu Tianhang on 12-11-5.
//
//

#import "NoUpdateAlertModel.h"
#import "SSAppPageManager.h"

@implementation NoUpdateAlertModel

+ (id)defaultModel
{
    NoUpdateAlertModel *noUpdateAlertModel = [[NoUpdateAlertModel alloc] init];
    
    noUpdateAlertModel.title   = nil;
    noUpdateAlertModel.tip = [SSTipModel defaultFloatModel];
    noUpdateAlertModel.message = noUpdateAlertModel.tip.displayInfo;
    
    noUpdateAlertModel.buttons = nil;
    noUpdateAlertModel.actions = nil;
    noUpdateAlertModel.delayTime = 0.f;
    
    return noUpdateAlertModel;
}

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        self.title = nil;
        
        self.tip = [[SSTipModel alloc] initWithDictionary:data];
        self.message = _tip.displayInfo;
        
        NSMutableString *buttons = [NSMutableString stringWithCapacity:30];
        NSMutableString *actions = [NSMutableString stringWithCapacity:30];
        
        SSTipModelActionType actionType = [SSTipModel actionTypeForTipModel:self.tip];
        if (actionType == SSTipModelActionTypeAlertWebOrDownload) {
            [buttons appendString:NSLocalizedString(@"网页体验,下载,取消", nil)];
            [actions appendFormat:@"%@,%@,%@", _tip.webURL, _tip.downloadURL, @""];
        }
        else if (SSTipModelActionTypeDownload) {
            [buttons appendString:NSLocalizedString(@"下载,取消", nil)];
            [actions appendFormat:@"%@,%@", _tip.downloadURL, @""];
            
        }
        self.buttons = [buttons copy];
        self.actions = [actions copy];
        self.delayTime = 0.f;
    }
    return self;
}

@end
