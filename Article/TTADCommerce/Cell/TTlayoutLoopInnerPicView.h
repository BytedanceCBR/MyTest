//
//  TTlayoutLoopInnerPicView.h
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"


@interface TTlayoutLoopInnerPicView : SSThemedView

-(instancetype)initWithFrame:(CGRect)frame;

-(void)updatePicViewWithData:(ExploreOrderedData *)orderData WithPerPicSize:(CGSize)perPicSize WithbaseCell:(ExploreCellBase *)baseCell WithTabelView:(UITableView *)tableView;

@end
