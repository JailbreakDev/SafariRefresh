#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <substrate.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_9_0
#define kCFCoreFoundationVersionNumber_iOS_9_0 1240.10
#endif

@interface BrowserController : UIViewController
+(id)sharedBrowserController;
-(void)reloadKeyPressed;
-(void)_reloadKeyPressed;
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
	if (self.reloadPageControl == nil) {
		self.reloadPageControl = [[[UIRefreshControl alloc] init] autorelease];
	}
	if (self.reloadPageControl.superview) {
		[self.reloadPageControl removeFromSuperview];
	}
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0) {
		[self.reloadPageControl addTarget:self action:@selector(_reloadKeyPressed) forControlEvents:UIControlEventValueChanged];
	} else {
		[self.reloadPageControl addTarget:self action:@selector(reloadKeyPressed) forControlEvents:UIControlEventValueChanged];
	}
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
		if (scrollView && !self.reloadPageControl.superview) {
			[self createReloadPageControl];
			[scrollView addSubview:self.reloadPageControl];
		}
	} @catch (NSException *e) {
		NSLog(@"[SafariRefresh] caught exception: %@",e);
	}
	%orig;
}

-(void)_reloadKeyPressed {
	if (self.reloadPageControl) {
		[self.reloadPageControl endRefreshing];
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
