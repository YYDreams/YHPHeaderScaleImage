//
//  UIScrollView+HeaderScaleImage.m
//  YHPHeaderScaleImage
//
//  Created by LOVE on 16/8/22.
//  Copyright © 2016年 LOVE. All rights reserved.
//

#import "UIScrollView+HeaderScaleImage.h"
#import <objc/message.h>

#define yhpKeyPath(objc,keyPath)  @(((void)objc.keyPath,#keyPath))
/**
 *  分类的目的:实现连个方法实现的交换，调用原有方法，有现有方法（自己实现方法）的实现
 
 */
@interface NSObject (ExchangeMethods)
/**
 *  交换对象方法
 *
 *  @param origSelector     原有方法
 *  @param exchangeSelector 现有方法（自己实现方法）
 */
+(void)yhp_exchangeInstanceSelector:(SEL)origSelector exchangeSelector:(SEL)exchangeSelector;
/**
 *  交换类方法
 *
 *  @param origSelector     原有方法
 *  @param exchangeSelector 现有方法（自己实现方法）
 */
+(void)yhp_exchangeClassSelector:(SEL)origSelector exchangeSelector:(SEL)exchangeSelector;

@end

@implementation NSObject (ExchangeMethods)

+(void)yhp_exchangeInstanceSelector:(SEL)origSelector exchangeSelector:(SEL)exchangeSelector{
  
    //获取原有方法
    Method origMethod = class_getInstanceMethod(self, origSelector);
    
    //获取交换方法
    Method exchangeMethod = class_getInstanceMethod(self, exchangeSelector);
    //不能直接交换方法实现，需要判断原有方法是否存在,存在才能交换
    //若方法不存在，直接把自己方法的实现作为原有方法的实现，调用原有方法，就会来到当前方法的实现
    BOOL isAdd = class_addMethod(self, origSelector, method_getImplementation(exchangeMethod), method_getTypeEncoding(exchangeMethod));
    
    if (!isAdd) {//添加方法失败，表示原有方法存在，直接替换
        method_exchangeImplementations(origMethod, exchangeMethod);
    }
}

+(void)yhp_exchangeClassSelector:(SEL)origSelector exchangeSelector:(SEL)exchangeSelector{

    Method orgMethod = class_getClassMethod(self, origSelector);
    
    Method exchangeMethod = class_getClassMethod(self, exchangeSelector);
    
    BOOL isAdd = class_addMethod(self, origSelector, method_getImplementation(exchangeMethod), method_getTypeEncoding(exchangeMethod));
    
    if (!isAdd) {
        
        method_exchangeImplementations(orgMethod, exchangeMethod);
    }
}
@end

static char *const headerImageViewKey = "headerImageViewKey";
static char *const headerImageViewHeight = "headerImageViewHeight";
static char *const isInitiaKey = "isInitialKey";

//默认图片高度
static  CGFloat const DefaultImageHeight = 200;

@implementation UIScrollView (HeaderScaleImage)

//// 把类加载进内存的时候调用,只会调用一次
+(void)load{

    [self yhp_exchangeInstanceSelector:@selector(setTableHeaderView:) exchangeSelector:@selector(setyhp_TableHeaderView:)];
}

#pragma mark - SELMethod
-(void)setyhp_TableHeaderView:(UIView *)tableHeaderView{// 拦截通过代码设置tableView头部视图

     //不是UITableView，就直接返回
    if (![self isMemberOfClass:[UITableView class]]) return;
    
    //设置tableView头视图
    [self setyhp_TableHeaderView:tableHeaderView];

    // 设置头部视图的位置
    UITableView *tableView = (UITableView *)self;
    self.yhp_headerScaleImageHeight = tableView.tableHeaderView.frame.size.height;
    
}
#pragma mark - Setter && Getter
-(void)setYhp_headerScaleImage:(UIImage *)yhp_headerScaleImage{

    self.yhp_HeaderImageView.image = yhp_headerScaleImage;
    
    [self setupHeaderImageView]; //初始化头部视图
}

-(UIImage *)yhp_headerScaleImage{

    return self.yhp_HeaderImageView.image;
}

-(void)setYhp_headerScaleImageHeight:(CGFloat)yhp_headerScaleImageHeight{

    objc_setAssociatedObject(self, headerImageViewHeight, @(yhp_headerScaleImageHeight), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self setupHeaderImageViewFrame];//设置头部视图的位置
}

-(CGFloat)yhp_headerScaleImageHeight{

    CGFloat headerImageHeight = [objc_getAssociatedObject(self, headerImageViewHeight) floatValue];
    
    return headerImageHeight == 0 ? DefaultImageHeight:headerImageHeight;
    
}

-(UIImageView *)yhp_HeaderImageView{

    UIImageView *imageView = objc_getAssociatedObject(self, headerImageViewKey);
    
    if (imageView == nil) {
        
        imageView = [[UIImageView alloc]init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self insertSubview:imageView atIndex:0];
    }
    /**
     保存ImageView
       object:给哪个对象添加属性
      key:属性名称
      value:属性值
      policy:保存策略
     */
    objc_setAssociatedObject(self, headerImageViewKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return imageView;
}

-(void)setYhp_isInitial:(BOOL )yhp_isInitial{
    
    
    objc_setAssociatedObject(self, isInitiaKey, @(yhp_isInitial), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)yhp_isInitial{
    
    return [objc_getAssociatedObject(self, isInitiaKey)boolValue];
}

#pragma mark - OBJMethods
//设置头部视图的位置
-(void)setupHeaderImageViewFrame{
    
    self.yhp_HeaderImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.yhp_headerScaleImageHeight);
}
//初始化头部视图
-(void)setupHeaderImageView{

    [self setupHeaderImageViewFrame];//设置头部视图的位置
  
    //KVO监听偏移量，修改头部ingView的frame
    if (self.yhp_isInitial == NO) {
        
        [self addObserver:self forKeyPath:yhpKeyPath(self, contentOffset) options:NSKeyValueObservingOptionNew context:nil];
        
       self.yhp_isInitial = YES;
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

  //获取当前偏移量
    CGFloat offsetY = self.contentOffset.y;
    
    if (offsetY < 0) {
        
        self.yhp_HeaderImageView.frame = CGRectMake(offsetY, offsetY, self.bounds.size.width  - offsetY * 2, self.yhp_headerScaleImageHeight-offsetY);
        
    }else{
    
        self.yhp_HeaderImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.yhp_headerScaleImageHeight);
    }
}

#pragma mark - dealloc
- (void)dealloc{

    if (self.yhp_isInitial) {// 初始化过，就表示有监听contentOffset属性，才需要移除
        [self removeObserver:self forKeyPath:yhpKeyPath(self, contentOffset)];
    }
}
@end
