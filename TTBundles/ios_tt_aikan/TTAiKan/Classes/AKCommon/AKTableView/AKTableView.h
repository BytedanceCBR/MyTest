//
//  AKTableView.h
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import <UIKit/UIKit.h>
#import "AKTableView_IMP.h"
#import "AKTableViewModel.h"

@interface AKTableView : UITableView

@property (nonatomic, strong) AKTableViewModel *tableViewModel;

@end
