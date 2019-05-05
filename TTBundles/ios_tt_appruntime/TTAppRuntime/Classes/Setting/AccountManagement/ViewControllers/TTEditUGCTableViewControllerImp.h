//
//  TTEditUGCTableViewControllerImp.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <Foundation/Foundation.h>


@class TTEditUGCProfileViewModel;
@interface TTEditUGCTableViewControllerImp : NSObject
<
UITableViewDelegate,
UITableViewDataSource,
UIActionSheetDelegate
>
@property (nonatomic, weak) TTEditUGCProfileViewModel *viewModel;

- (instancetype)initWithViewModel:(TTEditUGCProfileViewModel *)viewModel;
@end
