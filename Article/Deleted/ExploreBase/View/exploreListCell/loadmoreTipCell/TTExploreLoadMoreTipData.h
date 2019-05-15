//
//  TTExploreLoadMoreTipData.h
//  Article
//
//  Created by carl on 2018/1/29.
//

#import "ExploreOriginalData.h"

@interface TTExploreLoadMoreTipData : ExploreOriginalData
@property (nonatomic, copy) NSString *display_info;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, assign) BOOL enableLoadmore;
@end
