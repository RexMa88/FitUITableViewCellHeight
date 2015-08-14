//
//  XHMJ_PraiseTableViewCell.m
//  chinapainting
//
//  Created by 新华视讯 on 15/8/5.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import "XHMJ_PraiseTableViewCell.h"
#import "XHMJ_FootMarkModel.h"
#import "UIView+Extension.h"

#define writerTextColor [UIColor colorWithRed:87/255.0f green:107/255.0f blue:149/255.0f alpha:1.0f]
#define marginConstraint 71
#define paddingConstraint 30

@implementation XHMJ_PraiseTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.praiseName = [[UILabel alloc] initWithFrame:CGRectMake(22, 1, kWidth - marginConstraint - paddingConstraint, 17)];
    self.praiseName.backgroundColor = [UIColor clearColor];
    self.praiseName.numberOfLines = 0;
    self.praiseName.lineBreakMode = NSLineBreakByCharWrapping;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (void)setPraiseArr:(NSArray *)praiseArr{
    if (_praiseArr != praiseArr) {
        _praiseArr = praiseArr;
        //拼接字符串
        __block NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        [_praiseArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XHMJ_FootMarkPraiseModel *model = obj;
            NSMutableAttributedString *name = [[NSMutableAttributedString alloc]initWithString:model.userName attributes:@{
                                                                    NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f],
                                                                    NSForegroundColorAttributeName:writerTextColor}];
            if (idx == 0) {
                str = name;
            }else{
                [str appendAttributedString:name];
            }
        }];
        self.praiseName.height = [str boundingRectWithSize:CGSizeMake(self.praiseName.width, 900) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        self.praiseName.attributedText = str;
        [self addSubview:self.praiseName];
    }
}

@end
