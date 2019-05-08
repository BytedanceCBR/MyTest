//
//  FHBTablePageRequester.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHBTablePageRequester <NSObject>

-(void)refresh;
-(void)loadNextPage;

@end

NS_ASSUME_NONNULL_END
