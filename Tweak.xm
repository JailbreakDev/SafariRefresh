#include <substrate.h>
#import <objc/runtime.h>

@interface BrowserController : UIViewController
+(id)sharedBrowserController;
-(void)reloadKeyPressed;
-(void)createReloadPageControl; //new
@end

@interface BrowserController (RefreshControl)
@property (nonatomic, strong) UIRefreshControl *reloadPageControl;
@end

%hook BrowserController

+(id)sharedBrowserController {
	self = %orig;

	if (self) {
		@try {
			UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self,"_scrollView");
			if (scrollView) {
				[(BrowserController *)self createReloadPageControl];
				[scrollView addSubview:((BrowserController *)self).reloadPageControl];
			}
		} @catch (NSException *e) {
			NSLog(@"[SafariRefresh] caught exception: %@",e);
		}
	}

	return self;
}

%new

-(void)createReloadPageControl {
	[self.reloadPageControl removeFromSuperview];
	self.reloadPageControl = [[UIRefreshControl alloc] init];
	[self.reloadPageControl addTarget:self action:@selector(reloadKeyPressed) forControlEvents:UIControlEventValueChanged];
}

%new

- (void)setReloadPageControl:(UIRefreshControl *)refreshControl {
     objc_setAssociatedObject(self, @selector(reloadPageControl), refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIRefreshControl *)reloadPageControl {
    return objc_getAssociatedObject(self, @selector(reloadPageControl));
}

-(void)resume {
	@try {
		UIScrollView *scrollView = MSHookIvar<UIScrollView *>(self,"_scrollView");
		if (scrollView) {
			[self createReloadPageControl];
			[scrollView addSubview:self.reloadPageControl];
		}
	} @catch (NSException *e) {
		NSLog(@"[SafariRefresh] caught exception: %@",e);
	}
	%orig;
}

-(void)reloadKeyPressed {
	if (self.reloadPageControl) {
		[self.reloadPageControl endRefreshing];
	}
	%orig;
}

%end
