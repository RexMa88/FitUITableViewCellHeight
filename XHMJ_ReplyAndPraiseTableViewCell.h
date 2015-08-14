//
//  XHMJ_ReplyAndPraiseTableViewCell.h
//  chinapainting
//
//  Created by 新华视讯 on 15/8/5.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHMJ_FootMarkCommentModel;
@interface XHMJ_ReplyAndPraiseTableViewCell : UITableViewCell

@property (strong, nonatomic) XHMJ_FootMarkCommentModel *commentModel;
@property (strong, nonatomic) UILabel *replyLabel;

@end
