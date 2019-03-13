//
//  TTVPlayerModel.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerModel.h"
#import "TTBaseMacro.h"
#import "NSString+TTPlayerEnDecode.h"

@implementation TTVPlayerModel
- (void)dealloc
{

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.useOwnPlayer = YES;
        self.enableCache = YES;
        self.enableResolution = YES;
        self.defaultResolutionType = TTVPlayerResolutionTypeUnkown;
    }
    return self;
}


- (NSString *)trackLabel
{
    if (!_trackLabel) {
        return [self dataTrackLabel];
    }else{
        return _trackLabel;
    }
    return nil;
}

- (NSString *)dataTrackLabel
{
    NSString * dataLabel = nil;
    if ([self.categoryID isEqualToString:@"__all__"]) {
        dataLabel = [NSString stringWithFormat:@"click_headline"];
    }
    else
    {
        if (!isEmptyString(self.categoryID)) {
            BOOL hasPrefix = [self.categoryID hasPrefix:@"_"]; //特殊处理cID是_favorite的情况
            NSString *click = hasPrefix ? @"click" : @"click_";
            dataLabel = [NSString stringWithFormat:@"%@%@", click,self.categoryID];
        }
    }
    if (!dataLabel) {
        dataLabel = @"click_unknow";
    }
    return dataLabel;
}

- (void)setUrlString:(NSString *)urlString{
    _urlString = [urlString ttPlayer_URLDecodedString] ?: urlString;
}

@end
