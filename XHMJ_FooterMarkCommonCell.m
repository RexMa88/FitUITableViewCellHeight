//
//  XHMJ_FooterMarkCommonCell.m
//  chinapainting
//
//  Created by 新华视讯 on 15/8/4.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import "XHMJ_FooterMarkCommonCell.h"
#import "XHMJ_FootMarkModel.h"
#import "XHMJ_FooterPictureCollectionCell.h"
#import "XHMJ_ReplyAndPraiseTableViewCell.h"
#import "XHMJ_PraiseTableViewCell.h"
#import "UIView+Extension.h"

#define collectionWidth self.photoCollectionView.frame.size.width
#define collectionLeading 63
#define collectionTrailing 90
#define minSpacing 7
//点赞评论条约束条件
#define leadingSpace 63
#define trailingSpace 8
#define cellMargin 16
#define cellHeight 21

static NSString *reuseID = @"photoCell";
static NSString *praiseCell = @"praiseCell";
static NSString *replyCell = @"replyCell";

@implementation XHMJ_FooterMarkCommonCell{
    CGFloat praiseHeight;
    NSMutableArray *commentHeightArr;
    NSMutableDictionary *commentHeightDic;
    CGFloat commentHeight;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    UINib *nib = [UINib nibWithNibName:@"XHMJ_FooterPictureCollectionCell" bundle:nil];
    [self.photoCollectionView registerNib:nib forCellWithReuseIdentifier:reuseID];
    
    //设置评论点赞视图(默认隐藏)
    self.commentAndPraiseView.backgroundColor = [UIColor clearColor];
    self.commentAndPraiseView.hidden = YES;
    //设置评论点赞手势
    self.commentImageView.userInteractionEnabled = YES;
    self.commentPraiseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    self.commentPraiseTapGesture.numberOfTouchesRequired = 1;
    self.commentPraiseTapGesture.numberOfTapsRequired = 1;
    [self.commentImageView addGestureRecognizer:self.commentPraiseTapGesture];
    //设置点赞图片
    self.praiseImg.userInteractionEnabled = YES;
    self.praiseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(praiseGestureAction:)];
    self.praiseTapGesture.numberOfTouchesRequired = 1;
    self.praiseTapGesture.numberOfTapsRequired = 1;
    [self.praiseImg addGestureRecognizer:self.praiseTapGesture];
    //设置评论图片
    self.commentImg.userInteractionEnabled = YES;
    self.commentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentGestureAction:)];
    self.commentTapGesture.numberOfTapsRequired = 1;
    self.commentTapGesture.numberOfTouchesRequired = 1;
    [self.commentImg addGestureRecognizer:self.commentTapGesture];
    //配置TableView
    [self setTableView];

    //初始化commentHeightDic
    commentHeightDic = [[NSMutableDictionary alloc] init];
}

- (void)setTableView{
    UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    whiteLine.backgroundColor = [UIColor clearColor];
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
        self.contentLabel.text = model.content;
        self.dateLabel.text = model.time;
        
        //设置照片数量
        if (_model.picCount>=0 && _model.picCount <=3) {
            self.collectionViewHeightConstraint.constant = self.photoCollectionView.width / 3;
        }else if (_model.picCount >=4 && _model.picCount <= 6) {
            self.collectionViewHeightConstraint.constant = self.photoCollectionView.width / 3 * 2;
        }else{
            self.collectionViewHeightConstraint.constant = self.photoCollectionView.width;
        }
        
        [self.photoCollectionView reloadData];
        
        if (_model.praiseTotalNum != 0 && [_model.commentList count] != 0) {
            self.replyStyle = footMarkReplyStyleWordAndPraise;
            self.tableView.hidden = NO;
        }else if([_model.commentList count] != 0 && _model.praiseTotalNum == 0){
            self.replyStyle = footMarkReplyStyleJustWord;
            self.tableView.hidden = NO;
        }else if ([_model.commentList count] == 0 && _model.praiseTotalNum != 0){
            self.replyStyle = footMarkReplyStyleJustPraise;
            self.tableView.hidden = NO;
        }else{
            self.replyStyle = footMarkReplyStyleNone;
        }
        
        [self settingTableViewHeight];

        [self.tableView reloadData];
    }
}

#pragma mark --- 根据点赞和评论配置tableView高度
- (void)settingTableViewHeight{
    if(self.replyStyle != footMarkReplyStyleNone){
        praiseHeight = [self heightToPraiseWithArray:_model.praiseList];
        commentHeight = [self heightWithCommentList:_model.commentList];
        CGFloat tableViewHeight = praiseHeight + commentHeight;
        self.tableViewHeightConstraint.constant = tableViewHeight;
    }else{
        
    }
}

#pragma mark --- 点赞和评论点击事件
- (void)tapGestureAction:(UIGestureRecognizer *)tapGesture{
    self.commentAndPraiseView.hidden = !self.commentAndPraiseView.hidden;
}

- (void)praiseGestureAction:(UIGestureRecognizer *)tapGesture{
    DLog(@"The praise");
}

- (void)commentGestureAction:(UIGestureRecognizer *)tapGesture{
    DLog(@"The comment");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commentViewAppear" object:nil userInfo:@{@"class":self}];
}

#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    switch (self.replyStyle) {
        case footMarkReplyStyleWordAndPraise:
        {
            return 2;
            break;
        }
        case footMarkReplyStyleJustWord:
        {
            return 1;
            break;
        }
        case footMarkReplyStyleJustPraise:{
            return 1;
            break;
        }
        case footMarkReplyStyleNone:{
            return 0;
            break;
        }
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (self.replyStyle) {
        case footMarkReplyStyleWordAndPraise:
        {
            if (section == 0) {
                return 1;
            }else{
                return [self.model.commentList count];
            }
        }
        case footMarkReplyStyleJustWord:
        {
            return [self.model.commentList count];
            break;
        }
        case footMarkReplyStyleJustPraise:
        {
            return 1;
            break;
        }
        case footMarkReplyStyleNone:
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
        case footMarkReplyStyleWordAndPraise:
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
        case footMarkReplyStyleJustPraise:
        {
            XHMJ_PraiseTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:praiseCell];
            
            if (cell == nil) {
                cell = (XHMJ_PraiseTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_PraiseTableViewCell" owner:nil options:nil] lastObject];
                cell.praiseArr = _model.praiseList;
            }
            return cell;
            break;
        }
        case footMarkReplyStyleJustWord:
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
        case footMarkReplyStyleNone:
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
        case footMarkReplyStyleWordAndPraise:
        {
            if (indexPath.section == 0) {
                return praiseHeight;
            }else{
                NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                return [[commentHeightDic objectForKey:key] floatValue];
            }
            break;
        }
        case footMarkReplyStyleJustPraise:
        {
            return praiseHeight;
            break;
        }
        case footMarkReplyStyleJustWord:
        {
            NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            return [[commentHeightDic objectForKey:key] floatValue];
            break;
        }
        case footMarkReplyStyleNone:
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

#pragma mark --- UITableViewdelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        XHMJ_FootMarkCommentModel *commentModel = _model.commentList[indexPath.row];
        self.commentAndPraiseView.hidden = YES;
        self.commentAndPraiseView.userInteractionEnabled = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"replyOtherPerson" object:self userInfo:@{@"commentModel":commentModel,
                                                                                                              @"class":self}];
    }
}

#pragma mark --- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _model.picCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XHMJ_FooterPictureCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    
    XHMJ_FootMarkPictureModel *pictModel = _model.picList[indexPath.row];
    
    cell.backgroundColor = [UIColor redColor];
    
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:pictModel.smallPicPath] placeholderImage:[UIImage imageNamed:@"guide_icon_head_placeholder"]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (kWidth - collectionLeading - collectionTrailing - 2 * minSpacing) / 3;
    CGFloat height = width;
    return CGSizeMake(width, height);
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
        [commentHeightDic addEntriesFromDictionary:@{key:[NSNumber numberWithFloat:rowHeight]}];
    }];
    return commentHeight;
}

- (IBAction)deleteMethod:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteNotification" object:nil userInfo:@{@"dynamicId":[NSString stringWithFormat:@"%ld",(long)_model.idIOS]}];
}
@end
