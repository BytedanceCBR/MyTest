//
//  FHFilterViewModel.h
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilterItemBar;
@class FHFilterContainerPanel;
NS_ASSUME_NONNULL_BEGIN

@interface FHFilterViewModel : NSObject
@property (nonatomic, weak) FHFilterContainerPanel* filterPanel;
@property (nonatomic, weak) FilterItemBar* filterItemBar;

+ (instancetype)instanceWithItemBar:(FilterItemBar*)bar
                      withPanel:(FHFilterContainerPanel*)panel;

- (instancetype)initWithItemBar:(FilterItemBar*)bar
                      withPanel:(FHFilterContainerPanel*)panel;
@end

NS_ASSUME_NONNULL_END
