'use strict';

/*
 * メイン画面用コントローラー
 */
app.controller('MainCtrl',
	['$scope',
	'$rootScope',
	'$controller',
	'$interval',
	'$location',
	'$log',
	'userModel',
	'workProposesModel',
	'worksModel',
	'searchModel',
	'workRecruitModel',
	'userService',
	'notificationService',
	function($scope, $rootScope, $controller, $interval, $location, $log,
			userModel, workProposesModel, worksModel, searchModel, 
			workRecruitModel, userService, notificationService) {

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("MainCtrl Start");
		
		$scope.userModel = userModel.user.get();
		$scope.workProposes = workProposesModel.workProposes
				.get();
		$scope.works = worksModel.works.get();
		$scope.search = JSON.parse(JSON.stringify(searchModel.search.get()));

		// IndexCtrlで保存後、検索ソート変更後にセット
		$scope.$on('changedSearch', function() {
			$scope.search = searchModel.search.get();
		});
		
		$scope.$on('changedUser', function() {
			$scope.userModel = userModel.user.get();
		});
		
		$interval(function() {
			$log.debug("MainCtrl interval ------>");
			
			notificationService.getNotifications().success(function(data, status, headers, config) {
				if (data == undefined || data == "" || 
						data.notification_msg_count == undefined || 
						data.notification_inf_count == undefined) {
					return;
				}
				$scope.userModel = userModel.user.get();
				$scope.userModel.notification_msg_count = data.notification_msg_count;
				$scope.userModel.notification_inf_count = data.notification_inf_count;
				userModel.user.set($scope.userModel);
				
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
			
		}, 5000);

		$scope.selectDropDownItemCall = function($event, model, attrId, attrName) {
			$scope.selectDropDownItem($event, model, attrId, attrName);
			searchModel.search.set(JSON.parse(JSON.stringify(model)));
		};

		$scope.openInfoDialog = function() {
			$("#modal-notice").modal("show");
		};

		$scope.openWorkSeachDialog = function() {
			$("#modal-work-search").modal("show");
		};

		$scope.openFirstDialog = function() {
			$("#modal-first").modal("show");
			$("#inputRegistEmail").focus();
		};

		$scope.openLoginDialog = function() {
			$("#modal-login").modal("show");
			$("#inputLoginEmail").focus();
		};
		$('#modal-login').on('hidden.bs.modal',
			function() {
				if ($rootScope.notLoginCallback != undefined) {
					$rootScope.notLoginCallback();
					$rootScope.notLoginCallback = undefined;
				}
			}
		);

		$scope.openRecruitDialog = function() {
			workRecruitModel.workRecruit.init();
			var workRecruit = workRecruitModel.workRecruit.get();
			var dayAfter = new Date(new Date().getTime() + 12 * 24 * 60 * 60 * 1000);
			workRecruit.limit_date = String(dayAfter.getFullYear()) + "/" + String(dayAfter.getMonth() + 1) + "/" + String(dayAfter.getDate()); 
			workRecruitModel.workRecruit.set(workRecruitModel.workRecruit.get());
			$("#modal-recruit").modal("show");
		};

		$scope.openMypageDialog = function() {
			if ($location.path().indexOf("mypage") == -1) {
				$scope.showProgressModal();
				$scope.getMypageUser();
			}
			$location.path("/mypage");
		};

		// モーダル背景高さ変更の為の処理
		var stop;
		$('#modal-profile').on(
				'shown.bs.modal',
				function() {
					$scope.getMypageUser();
					stop = $interval(function() {
						$('#modal-profile').modal(
								'handleUpdate');
					}, 200);
				});
		$('#modal-profile').on('hidden.bs.modal',
				function() {
					if (angular.isDefined(stop)) {
						$interval.cancel(stop);
					}
				});
		$('#modal-recruit').on(
				'shown.bs.modal',
				function() {
					stop = $interval(function() {
						$('#modal-recruit').modal(
								'handleUpdate');
					}, 200);
				});
		$('#modal-recruit').on('hidden.bs.modal',
				function() {
					if (angular.isDefined(stop)) {
						$interval.cancel(stop);
					}
				});	
		$('#modal-notice').on(
				'shown.bs.modal',
				function() {
					$scope.getMypageUser();
					stop = $interval(function() {
						$('#modal-notice').modal(
								'handleUpdate');
					}, 200);
				});
		$('#modal-notice').on('hidden.bs.modal',
				function() {
					if (angular.isDefined(stop)) {
						$interval.cancel(stop);
					}
				});		
		$('#modal-propose-ok-message').on(
				'shown.bs.modal',
				function() {
					stop = $interval(function() {
						$('#modal-propose-ok-message').modal(
								'handleUpdate');
					}, 200);
				});
		$('#modal-propose-ok-message').on('hidden.bs.modal',
				function() {
					if (angular.isDefined(stop)) {
						$interval.cancel(stop);
					}
				});	
	} ]);
