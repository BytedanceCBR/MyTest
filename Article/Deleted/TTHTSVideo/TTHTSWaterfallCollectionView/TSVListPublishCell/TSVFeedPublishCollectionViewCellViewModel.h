//
//  TSVFeedPublishCollectionViewCellViewModel.h
//  Article
//
//  Created by 王双华 on 2017/11/21.
//

#import <Foundation/Foundation.h>

@class TSVPublishStatusOriginalData;

@interface TSVFeedPublishCollectionViewCellViewModel : NSObject

- (instancetype)initWithModel:(TSVPublishStatusOriginalData *)model;

@property (nonatomic, strong, readonly) UIImage *coverImage;
@property (nonatomic, copy, readonly) NSString *uploadingProgress;
@property (nonatomic, copy, readonly) NSString *uploadingStr;
@property (nonatomic, copy, readonly) NSString *failedStr;
@property (nonatomic, assign, readonly) BOOL isFailed;

- (void)handleRetryButtonClick;
- (void)handleDeleteButtonClick;

@end
