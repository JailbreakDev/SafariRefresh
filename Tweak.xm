@interface BrowserController : UIViewController
+(id)sharedBrowserController;
-(void)reloadKeyPressed;
-(UIRefreshControl *)createReloadPageControl; //new
@end

UIRefreshControl *reloadPageControl = nil;

%hook BrowserController

+(id)sharedBrowserController {
	self = %orig;

	if (self) {
		[[(BrowserController *)self valueForKey:@"_scrollView"] addSubview:[(BrowserController *)self createReloadPageControl]];
	}

	return self;
}

%new

-(UIRefreshControl *)createReloadPageControl {
	if (reloadPageControl) {
		[reloadPageControl removeFromSuperview];
	}
	if (!reloadPageControl) {
		reloadPageControl = [[UIRefreshControl alloc] init];
		[reloadPageControl addTarget:self action:@selector(reloadKeyPressed) forControlEvents:UIControlEventValueChanged];
	}
	return reloadPageControl;
}

-(void)resume {
	[[self valueForKey:@"_scrollView"] addSubview:[self createReloadPageControl]];
	%orig;
}

-(void)reloadKeyPressed {
	if (reloadPageControl) {
		[reloadPageControl endRefreshing];
	}
	%orig;
}

-(void)dealloc {
	[reloadPageControl removeFromSuperview];
	reloadPageControl = nil;
	[reloadPageControl release];
	%orig;
}

%end