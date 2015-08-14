//
//  XHMJ_FooterMarkNoPictureCell.m
//  chinapainting
//
//  Created by 新华视讯 on 15/8/4.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import "XHMJ_FooterMarkNoPictureCell.h"
#import "XHMJ_FootMarkModel.h"
#import "XHMJ_ReplyAndPraiseTableViewCell.h"
#import "XHMJ_PraiseTableViewCell.h"
#import "UIView+Extension.h"

static NSString *praiseCell = @"praiseCell";
static NSString *replyCell = @"replyCell";

#define leadingSpace 63
#define trailingSpace 8
#define cellMargin 16
#define cellHeight 21

@implementation XHMJ_FooterMarkNoPictureCell{
    CGFloat praiseHeight;
    NSMutableDictionary *commontHeightDic;
    CGFloat commentHeight;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    //设置点击事件
    self.commentImageView.userInteractionEnabled = YES;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.commentImageView addGestureRecognizer:self.tapGesture];
    //评论点赞栏
    self.commentPraiseView.backgroundColor = [UIColor clearColor];
    self.commentPraiseView.hidden = YES;
    //点赞
    self.praiseBtn.userInteractionEnabled = YES;
    self.praiseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(praiseGestureAction:)];
    [self.praiseBtn addGestureRecognizer:self.praiseGesture];
    //评论
    self.commentBtn.userInteractionEnabled = YES;
    self.commentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentGestureAction:)];
    [self.commentBtn addGestureRecognizer:self.commentGesture];
    //点赞和回复列表
    [self setTableView];
    //初始化高度字典
    commontHeightDic = [[NSMutableDictionary alloc] init];
}


#pragma mark --- 配置UITableView
- (void)setTableView{
    UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    whiteLine.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = whiteLine;
    self.tableView.tableFooterView = whiteLine;
    self.tableView.bounces = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setModel:(XHMJ_FootMarkModel *)model{
    if (_model != model) {
        _model = model;
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:_model.showPic] placeholderImage:[UIImage imageNamed:@"guide_icon_head_placeholder"]];
        self.contentLabel.text = _model.content;
        self.contentLabel.height = [self.contentLabel.text boundingRectWithSize:CGSizeMake(self.contentLabel.width, 960) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.contentLabel.font} context:nil].size.height;
        
        self.dateLabel.text = _model.time;
        //评论和点赞列表
        if (_model.praiseTotalNum != 0 && [_model.commentList count] != 0) {
            self.replyStyle = footMarkReplyNoPictureStyleWordAndPraise;
            self.tableView.hidden = NO;
        }else if([_model.commentList count] != 0 && _model.praiseTotalNum == 0){
            self.replyStyle = footMarkReplyNoPictureStyleJustWord;
            self.tableView.hidden = NO;
        }else if ([_model.commentList count] == 0 && _model.praiseTotalNum != 0){
            self.replyStyle = footMarkReplyNoPictureStyleJustPraise;
            self.tableView.hidden = NO;
        }else{
            self.replyStyle = footMarkReplyNoPictureStyleNone;
        }
        
        [self settingTableViewHeight];
        
        [self.tableView reloadData];
    }
}

#pragma mark --- 根据点赞和评论配置tableView高度
- (void)settingTableViewHeight{
    if(self.replyStyle != footMarkReplyNoPictureStyleNone){
        praiseHeight = [self heightToPraiseWithArray:_model.praiseList];
        commentHeight = [self heightWithCommentList:_model.commentList];
        CGFloat tableViewHeight = praiseHeight + commentHeight;
        self.tableViewHeightConstraint.constant = tableViewHeight;
    }else{

    }
}

#pragma mark --- 点赞和评论点击事件
- (void)tapGestureAction:(UIGestureRecognizer *)tapGesture{
    
    self.commentPraiseView.hidden = !self.commentPraiseView.hidden;
}

- (void)praiseGestureAction:(UIGestureRecognizer *)tapGesture{
    DLog(@"The praise");
    self.commentPraiseView.hidden = !self.commentPraiseView.hidden;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"praiseFooterMark" object:nil userInfo:@{@"footerMarkModel":self.model,@"":}];
}

- (void)commentGestureAction:(UIGestureRecognizer *)tapGesture{
    DLog(@"The comment");
    self.commentPraiseView.hidden = !self.commentPraiseView.hidden;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentViewAppear" object:nil userInfo:@{@"class":self}];
}

#pragma mark --- TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    switch (self.replyStyle) {
        case footMarkReplyNoPictureStyleWordAndPraise:
        {
            return 2;
            break;
        }
        case footMarkReplyNoPictureStyleJustWord:
        {
            return 1;
            break;
        }
        case footMarkReplyNoPictureStyleJustPraise:{
            return 1;
            break;
        }
        case footMarkReplyNoPictureStyleNone:{
            return 0;
            break;
        }
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (self.replyStyle) {
        case footMarkReplyNoPictureStyleWordAndPraise:
        {
            if (section == 0) {
                return 1;
            }else{
                return [self.model.commentList count];
            }
        }
        case footMarkReplyNoPictureStyleJustWord:
        {
            return [self.model.commentList count];
            break;
        }
        case footMarkReplyNoPictureStyleJustPraise:
        {
            return 1;
            break;
        }
        case footMarkReplyNoPictureStyleNone:
        {
            return 0;
            break;
        }
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (self.replyStyle) {
        case footMarkReplyNoPictureStyleWordAndPraise:
        {
            if (indexPath.section == 0) {
                XHMJ_PraiseTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:praiseCell];
                if (cell == nil) {
                    cell = (XHMJ_PraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_PraiseTableViewCell" owner:nil options:nil] lastObject];
                    cell.praiseArr = _model.praiseList;
                }
                return cell;
            }else{
                XHMJ_ReplyAndPraiseTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:replyCell];
                if (cell == nil) {
                    cell = (XHMJ_ReplyAndPraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_ReplyAndPraiseTableViewCell" owner:nil options:nil] lastObject];
                    XHMJ_FootMarkCommentModel *model = _model.commentList[indexPath.row];
                    cell.commentModel = model;
                    
                }
                return cell;
            }
            break;
        }
        case footMarkReplyNoPictureStyleJustPraise:
        {
            XHMJ_PraiseTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:praiseCell];
            
            if (cell == nil) {
                cell = (XHMJ_PraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_PraiseTableViewCell" owner:nil options:nil] lastObject];
                cell.praiseArr = _model.praiseList;
            }
            return cell;
            break;
        }
        case footMarkReplyNoPictureStyleJustWord:
        {
            XHMJ_ReplyAndPraiseTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:replyCell];
            if (cell == nil) {
                cell = (XHMJ_ReplyAndPraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_ReplyAndPraiseTableViewCell" owner:nil options:nil] lastObject];
                XHMJ_FootMarkCommentModel *model = _model.commentList[indexPath.row];
                cell.commentModel = model;
            }
            return cell;
            break;
        }
        case footMarkReplyNoPictureStyleNone:
        {
            return nil;
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (self.replyStyle) {
        case footMarkReplyNoPictureStyleWordAndPraise:
        {
            if (indexPath.section == 0) {
                return praiseHeight;
            }else{
                NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                return [[commontHeightDic objectForKey:key] floatValue];
            }
            break;
        }
        case footMarkReplyNoPictureStyleJustPraise:
        {
            return praiseHeight;
            break;
        }
        case footMarkReplyNoPictureStyleJustWord:
        {
            NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            return [[commontHeightDic objectForKey:key] floatValue];
            break;
        }
        case footMarkReplyNoPictureStyleNone:
        {
            return 0;
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        return line;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        return line;
    }
    return nil;
}

#pragma mark --- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        XHMJ_FootMarkCommentModel *commentModel = _model.commentList[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replyOtherPerson" object:self userInfo:@{@"commentModel":commentModel,
                                                                                                              @"class":self}];
    }
}

#pragma mark --- 自适应高度
//点赞部分高度
- (CGFloat)heightToPraiseWithArray:(NSArray *)praiseArr{
    XHMJ_PraiseTableViewCell *cell = (XHMJ_PraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_PraiseTableViewCell" owner:nil options:nil] lastObject];
    cell.praiseArr = praiseArr;
    return (cell.praiseName.height + 3.0f);
}

//评论部分高度
- (CGFloat)heightWithCommentList:(NSArray *)commentList{
    commentHeight = 0;
    [commentList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XHMJ_ReplyAndPraiseTableViewCell *cell = (XHMJ_ReplyAndPraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_ReplyAndPraiseTableViewCell" owner:nil options:nil] lastObject];
        XHMJ_FootMarkCommentModel *model = obj;
        cell.commentModel = model;
        CGFloat rowHeight = cell.replyLabel.height+3;
        commentHeight += rowHeight;
        NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)idx];
        [commontHeightDic addEntriesFromDictionary:@{key:[NSNumber numberWithFloat:rowHeight]}];
    }];
    return commentHeight;
}

- (IBAction)deleteMethod:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteNotification" object:nil userInfo:@{@"dynamicId":[NSString stringWithFormat:@"%ld",(long)_model.idIOS]}];
}
@end
