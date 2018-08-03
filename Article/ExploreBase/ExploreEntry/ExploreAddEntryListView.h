//
//  ExploreAddEntryListView.h
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "SSViewBase.h"
#import "ExploreAddEntryListCell.h"
#import "SSNavigationBar.h"

@interface ExploreAddEntryListView : SSViewBase<UITableViewDelegate, UITableViewDataSource, ExploreAddEntryListCellDelegate>

- (instancetype)initWithFrame:(CGRect)frame showGroupID:(NSString *)needShowGroupID;

 
@end
