//
//  TTTableViewBaseCellView.h
//  Article
//
//  Created by 杨心雨 on 16/8/19.
//
//

#import "ExploreCellViewBase.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOriginalData.h"

// MARK: - TTMoreViewProtocol
/** 更多控件协议 */
@protocol TTMoreViewProtocol <NSObject>

- (void)moreViewClick;

@end

@interface TTTableViewBaseCellView : ExploreCellViewBase

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) ExploreOriginalData *originalData;
- (NSUInteger)refer;

@end
