//
//  TTWeitoutiaoRepostIconDownloadManager.h
//  Article
//
//  Created by 王霖 on 17/4/1.
//
//

#import <Foundation/Foundation.h>
#import <AKShareServicePlugin/TTForwardWeitoutiaoActivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTWeitoutiaoRepostIconDownloadManager : NSObject<TTWeitoutiaoRepostIconDownloadManagerInterface>

+ (nullable instancetype)sharedManager;
- (nullable UIImage *)getWeitoutiaoRepostDayIcon;
- (nullable UIImage *)getWeitoutiaoRepostNightIcon;

@end

NS_ASSUME_NONNULL_END
