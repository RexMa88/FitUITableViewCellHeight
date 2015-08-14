//
//  XHMJ_ReplyAndPraiseTableViewCell.m
//  chinapainting
//
//  Created by 新华视讯 on 15/8/5.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import "XHMJ_ReplyAndPraiseTableViewCell.h"
#import "XHMJ_FootMarkModel.h"
#import "UIView+Extension.h"

#define writerTextColor [UIColor colorWithRed:87/255.0f green:107/255.0f blue:149/255.0f alpha:1.0f]
#define marginConstraint 71

@implementation XHMJ_ReplyAndPraiseTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 1,kWidth - marginConstraint - 16 , 17)];
    self.replyLabel.backgroundColor = [UIColor clearColor];
    self.replyLabel.numberOfLines = 0;
    self.replyLabel.lineBreakMode = NSLineBreakByCharWrapping;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCommentModel:(XHMJ_FootMarkCommentModel *)commentModel{
    if (_commentModel != commentModel) {
        _commentModel = commentModel;
        if (_commentModel.pwriterId == 0) {
            //当没有人回复,只评论时
            NSString *reply = [NSString stringWithFormat:@"%@:%@",_commentModel.writerName,_commentModel.context];
            
            NSMutableAttributedString *replyStr = [[NSMutableAttributedString alloc] initWithString:reply attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}];
            //评论人字体颜色
            [replyStr addAttribute:NSForegroundColorAttributeName value:writerTextColor range:NSMakeRange(0, [_commentModel.writerName length])];
            //回复内容字体颜色
            [replyStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([_commentModel.writerName length], [_commentModel.context length])];
            self.replyLabel.attributedText = replyStr;
            CGFloat height = [self.replyLabel.attributedText boundingRectWithSize:CGSizeMake(self.replyLabel.width, 900) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
            self.replyLabel.height = height;
            [self addSubview:_replyLabel];
        }else{
            //当有人回复评论时
            NSString *reply = [NSString stringWithFormat:@"%@回复%@:%@",_commentModel.writerName,_commentModel.pwriterName,_commentModel.context];
            
            NSMutableAttributedString *replyStr = [[NSMutableAttributedString alloc] initWithString:reply attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}];
            //回复人字体颜色
            [replyStr addAttribute:NSForegroundColorAttributeName value:writerTextColor range:NSMakeRange(0, [_commentModel.writerName length])];
            //回复字体颜色
            [replyStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([_commentModel.writerName length], 2)];
            //被回复人字体颜色
            [replyStr addAttribute:NSForegroundColorAttributeName value:writerTextColor range:NSMakeRange([_commentModel.writerName length]+2, [_commentModel.pwriterName length])];
            //回复内容字体颜色
            NSUInteger loc = [_commentModel.writerName length] + 2 + [_commentModel.pwriterName length];
            [replyStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(loc, [_commentModel.context length])];
            self.replyLabel.attributedText = replyStr;
            CGFloat height = [self.replyLabel.attributedText boundingRectWithSize:CGSizeMake(self.replyLabel.width, 900) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
            self.replyLabel.height = height;
            [self addSubview:_replyLabel];
        }
    }
}

@end
