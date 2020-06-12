//
//  FHMainListTableView.m
//  FHHouseList
//
//  Created by 谢思铭 on 2020/6/5.
//

#import "FHMainListTableView.h"

@implementation FHMainListTableView

//解决大类页中tableview存在textfield时候会自动滚动的问题，原因是设置了tableview的contentInset
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    if(self.forbiddenScrollRectToVisible){
        return;
    }
    [super scrollRectToVisible:rect animated:animated];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
