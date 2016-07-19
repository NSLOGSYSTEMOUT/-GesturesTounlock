//
//  LoadGestureView.m
//  手势解锁
//
//  Created by leotao on 16/7/19.
//  Copyright © 2016年 ZS. All rights reserved.
//

#import "LoadGestureView.h"

@interface LoadGestureView ()

@property(nonatomic, strong)NSMutableArray *buttons;
@property(nonatomic, assign)CGPoint movePoint;
@end

@implementation LoadGestureView

-(NSMutableArray *)buttons {

    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    
    return _buttons;
}

//解析xib的时候调用  先于awakeFromNib方法执行
-(instancetype)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self addButtons];
    }
    return self;
}

-(void)addButtons{
    
    for (int i = 0; i < 9; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
//        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
        button.userInteractionEnabled = NO;
        
        [self addSubview:button];
    }
}

//-(void)btnClick:(UIButton *)button{
//    button.selected = YES;
//}

//获取触摸点
-(CGPoint)pointWithTouch:(NSSet *)touches{

    //    当前触摸点
    UITouch *touch = [touches anyObject];
    CGPoint  pos = [touch  locationInView:self];
    return pos;
}

//获取触摸的按钮
-(UIButton *)buttonWithPoint:(CGPoint)point{

    CGFloat  wh = 30;
    
    for (UIButton *btn  in self.subviews) {
        
        CGFloat x = btn.center.x - wh *0.5;
        CGFloat y = btn.center.y - wh * 0.5;
        CGRect frame = CGRectMake(x, y, wh, wh);
        if ( CGRectContainsPoint(frame, point)) { //  点在按钮上
            return btn;
        }
    }
    
    return nil;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 当前触摸点
    CGPoint pos = [self pointWithTouch:touches];
    // 获取触摸按钮
    UIButton *btn = [self buttonWithPoint:pos];
    
    if (btn && btn.selected == NO) { // 有触摸按钮的时候才需要选中
        
        btn.selected = YES;
        [_buttons addObject:btn];
    }

}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    CGPoint  pos = [self pointWithTouch:touches];
    _movePoint = pos;
    UIButton *button = [self buttonWithPoint:pos];
    
    if (button && button.selected == NO) {
        button.selected = YES;
        [_buttons addObject:button];
    }

//    重绘
    [self setNeedsDisplay];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

//    string用于存储触摸的路径
    NSMutableString *string = [NSMutableString string];
    for (UIButton *btn in self.buttons) {
        [string appendFormat:@"%ld", (long)btn.tag];
    }
    
    NSLog(@"%@", string);
//    取消所有按钮的选中
//    [self.buttons makeObjectsPerformSelector:@selector(setSelected:) withObject:@NO];
    for (UIButton *button in self.subviews) {
        if (button.selected) {
            button.selected = NO;
        }
    }
    
    [self.buttons removeAllObjects];
    [self setNeedsDisplay];
}

//设置按钮位置
-(void)layoutSubviews{

    [super layoutSubviews];
    
    CGFloat col = 0;
    CGFloat row = 0;
    
    CGFloat btnw = 74;
    CGFloat btnh = 74;
    CGFloat btnx = 0;
    CGFloat btny = 0;
    
    int tolalCol = 3;
    CGFloat margin = (self.bounds.size.width - tolalCol * btnw) /(tolalCol +1);
    
    for (int i = 0; i < self.subviews.count; i ++) {
        
        col = i % 3;
        row = i /3;
        
        btnx = margin +(margin +btnw)*col;
        btny =  (margin + btnh) * row;
        
        UIButton * button = self.subviews[i];
        button.frame = CGRectMake(btnx, btny, btnw, btnh);
    }
}

//加载xib完成的时候调用
//-(void)awakeFromNib{
//    
//    for (int i = 0 ; i < 9 ; i++) {
//        
//    }
//}

- (void)drawRect:(CGRect)rect {

    if (!self.buttons.count) {
        return;
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i = 0; i<self.buttons.count; i++) {
        UIButton *button = _buttons[i];
        if (i ==0) {
            [path moveToPoint:button.center];
        } else {
            [path addLineToPoint:button.center];
        }
    }
//    所有已选中按钮之间都连线
//    连接按钮之外的线段
    [path addLineToPoint:_movePoint];
    [[UIColor greenColor] set];
    path.lineWidth = 8;
    path.lineJoinStyle = kCGLineJoinRound;
    
    CGContextAddPath(contextRef, path.CGPath);
//    渲染到视图
    [path stroke];
}

@end
