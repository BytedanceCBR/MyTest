//
//  TTEditPGCTableViewControllerImp.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <Foundation/Foundation.h>


@class TTEditPGCProfileViewModel;
@interface TTEditPGCTableViewControllerImp : NSObject
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, weak) TTEditPGCProfileViewModel *viewModel;

- (instancetype)initWithViewModel:(TTEditPGCProfileViewModel *)viewModel;
@end
