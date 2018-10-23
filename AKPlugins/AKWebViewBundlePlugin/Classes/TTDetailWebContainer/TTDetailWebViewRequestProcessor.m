//
//  TTDetailWebViewRequestProcessor.m
//  Article
//
//  Created by yuxin on 4/13/16.
//
//



#import "TTDetailWebViewRequestProcessor.h"
#import "TTURLTracker.h"

#import <TTBaseLib/TTStringHelper.h>
#import <TTTracker/TTTracker.h>
#import <TTRoute/TTRoute.h>
@implementation TTDetailWebViewRequestProcessor
{
    NSURL * _openPageUrl;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _openPageUrl = nil;
    }
    return self;
}

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
 
 
    BOOL result = YES;
    
    if([self redirectRequestCanOpen:request])
    {
        result = [self redirectLocalRequest:request.URL];
    }
    
    
    return result;
    
}

 

- (BOOL)redirectRequestCanOpen:(NSURLRequest *)requestURL
{
    if ([requestURL.URL.scheme isEqualToString:kBytedanceScheme] ||
        [[requestURL.URL absoluteString] hasPrefix:TTLocalScheme] ||
        [[requestURL.URL absoluteString] hasPrefix:kLocalSDKDetailSCheme] ||
        [[requestURL.URL absoluteString] hasPrefix:kSNSSDKScheme]) {
        return YES;
    }
    return NO;
};

- (BOOL)redirectLocalRequest:(NSURL*)requestURL
{
    BOOL shouldStartLoad = YES;
    if([requestURL.scheme isEqualToString:kBytedanceScheme])
    {
        if ([requestURL.host isEqualToString:@"domReady"]) {
            if (_delegate && [_delegate respondsToSelector:@selector(processRequestReceiveDomReady)]) {
                [_delegate processRequestReceiveDomReady];
            }
            shouldStartLoad = NO;
        }
        else if([requestURL.host isEqualToString:kUserProfile])
        {
            NSDictionary *parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            if (_delegate && [_delegate respondsToSelector:@selector(processRequestShowUserProfileForUserID:)]) {
                [_delegate processRequestShowUserProfileForUserID:[parameters objectForKey:@"user_id"]];
            }
            NSString *action = [parameters objectForKey:@"action"];
            if([action isEqualToString:@"digg"])
            {
                ttTrackEvent(@"detail", @"click_digg_users");
            }
            else if([action isEqualToString:@"bury"])
            {
                ttTrackEvent(@"detail", @"click_bury_users");
            }
            else if([action isEqualToString:@"repin"])
            {
                ttTrackEvent(@"detail", @"click_favorite_users");
            }
            else if ([action isEqualToString:@"pgc"])
            {
                ttTrackEvent(@"detail", @"click_pgc_user_profile");
            }
            shouldStartLoad = NO;
        }

        else if ([requestURL.host isEqualToString:kClickSource]) {
            NSDictionary *parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            NSString * sourceURL = [parameters objectForKey:@"source"];
            
            sourceURL = [sourceURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (_delegate && [_delegate respondsToSelector:@selector(processRequestOpenWebViewUseURL:supportRotate:)]) {
                [_delegate processRequestOpenWebViewUseURL:[TTStringHelper URLWithURLString:sourceURL] supportRotate:NO];
            }
            shouldStartLoad = NO;
            ttTrackEvent(@"detail", @"click_source");
        }
        else if ([requestURL.host isEqualToString:kDownloadAppHost]) {
            NSDictionary * parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            if (_delegate && [_delegate respondsToSelector:@selector(processRequestOpenAppStoreByActionURL:itunesID:)]) {
                [_delegate processRequestOpenAppStoreByActionURL:[parameters objectForKey:@"url"] itunesID:[parameters objectForKey:@"apple_id"]];
            }
            shouldStartLoad = NO;
        }
        else if ([requestURL.host isEqualToString:kCustomOpenHost]) {
            NSDictionary *parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            NSString * sourceURL = [parameters objectForKey:@"url"];
            sourceURL = [sourceURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (_delegate && [_delegate respondsToSelector:@selector(processRequestOpenWebViewUseURL:supportRotate:)]) {
                [_delegate processRequestOpenWebViewUseURL:[TTStringHelper URLWithURLString:sourceURL] supportRotate:NO];
            }
            shouldStartLoad = NO;
        }
        else if ([requestURL.host isEqualToString:kTrackURLHost]) {
            NSDictionary * parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            NSString * trackStr = [parameters objectForKey:@"url"];
            shouldStartLoad = NO;
//            ssTrackURL(trackStr);
            ttTrackURL(trackStr);
        }
        else if ([requestURL.host isEqualToString:kMediaAccountProfileHost]) {
            NSDictionary * parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            
            if (_delegate && [_delegate respondsToSelector:@selector(processRequestShowPGCProfileWithParams:)]) {
                [_delegate processRequestShowPGCProfileWithParams:parameters];
            }
            shouldStartLoad = NO;
            ttTrackEvent(@"detail", @"click_web_header");
        }
        else if ([requestURL.host isEqualToString:kKeyWordsHost]) {
            NSDictionary * parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            NSString * keyWordString = [[NSString stringWithFormat:@"%@", [parameters objectForKey:@"keyword"]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSUInteger index = [[parameters objectForKey:@"index"] integerValue];
            if (!isEmptyString(keyWordString)) {
                keyWordString = [NSString stringWithFormat:@"%@", keyWordString];
                if (_delegate && [_delegate respondsToSelector:@selector(processRequestShowSearchViewWithQuery:fromType:index:)]) {
                    [_delegate processRequestShowSearchViewWithQuery:keyWordString fromType:3 index:index];
                }
            }
            shouldStartLoad = NO;
        }
     
    }
    else if ([[TTRoute sharedRoute] canOpenURL:requestURL] ) {
        
        if (_openPageUrl == nil) {
            _openPageUrl = requestURL;
            
            [[TTRoute sharedRoute] openURLByPushViewController:requestURL];
            
            //防止连续打开一样的
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _openPageUrl = nil;
            });
        }
        
        shouldStartLoad = NO;
    }
    return shouldStartLoad;
}

@end
