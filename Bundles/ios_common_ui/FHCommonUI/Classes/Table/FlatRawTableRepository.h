//
//  FlatRawTableRepository.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FlatRawTableRepository <NSObject>
-(NSInteger)dataCount;
-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowInSection:(NSInteger)section;
-(id)modelAtIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
