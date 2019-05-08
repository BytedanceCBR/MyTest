//
//  FHBaseTableViewCell.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/20.
//

#import "FHBaseTableViewCell.h"

@implementation FHBaseTableViewCell

+(NSString *)identifier
{
    return @"base";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.head = false;
    self.tail = false;
}


/*
 open class var identifier: String {
 return "base"
 }
 
 override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
 super.init(style: style, reuseIdentifier: reuseIdentifier)
 self.selectionStyle = .none
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 override func prepareForReuse() {
 super.prepareForReuse()
 isHead = false
 isTail = false
 }
 */

@end
