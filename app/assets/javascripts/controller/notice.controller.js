'use strict';

/*
 * お知らせ用コントローラー
 */
app.controller('NoticeCtrl', 
	['$scope',
	'$controller',
	'$timeout',
	'$interval',
	'$routeParams',
	'$location',
	'$log',
	'noticesModel',
	'noticeService',
	'notificationService',
	function($scope, $controller, $timeout, $interval, $routeParams, $location, $log,
			noticesModel, noticeService, notificationService) {

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("NoticeCtrl Start");
		
		$scope.notices = noticesModel.notices.get();
		
		$scope.errors = null;
		$scope.displayMessages = "";

		$scope.getNoticeList = function() {
			noticeService.getNotices().success(function(data, status, headers, config) {
				$scope.notices = data;
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
		};
		
		$scope.selectTitle = function(notice) {
			if (notice.notification_inf_count == undefined || notice.notification_inf_count == 0) {
				return;
			}
			
			notificationService.deleteNotification(notice.id, 2).success(function (data, status, headers, config) {
				notice.notification_inf_count = 0;
				$scope.getMypageUser();
				return;
				
			}).error(function (data, status, headers, config) {
				var messages = [];
				$scope.errorsSend = data;
				$scope.displaySendMessages = $scope.getMessage(messages);
				return;
		    });			
		};
		
		var stop;

		$scope.getNoticeList();

	} ]);
