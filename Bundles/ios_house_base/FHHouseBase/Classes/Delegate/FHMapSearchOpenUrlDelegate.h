//
//  FHMapSearchOpenUrlDelegate.h
//  FHHouseBase
//
//  Created by 张静 on 2018/12/24.
//

#ifndef FHMapSearchOpenUrlDelegate_h
#define FHMapSearchOpenUrlDelegate_h

#define OPENURL_CALLBAK @"openurl_callback"

@protocol FHMapSearchOpenUrlDelegate <NSObject>


@required
-(void)handleHouseListCallback:(NSString *)openUrl;

@end


#endif /* FHMapSearchOpenUrlDelegate_h */
