'use strict';

/*
 * ログインダイアログ用コントローラー
 */
app.controller('UserLoginCtrl', [
	'$scope',
	'$controller',
	'$log',
	'userModel',
	'userService',
	'itemService',
	'itemProposeService',
	'itemCommentService',
	'messageService',
	'itemFavoriteService',
	'notificationService',
	'noticeService',
	'connectionService',
	function($scope, $controller, $log, userModel, userService,
			itemService, itemProposeService, itemCommentService,
			messageService, itemFavoriteService, notificationService,
			noticeService, connectionService) {
		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.userModel = userModel.user.get();

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});

		$log.debug("UserLoginCtrl Start");

		$scope.login = function(userModel) {
			$scope.errors = null;
			$scope.displayMessages = "";
			userService.getLoginUser(userModel.email, userModel.password,
					userModel.save_login_flg).success(
					function(data, status, headers, config) {
						// csrfが書き換わってしまう為、再設定する
						$scope.resetCsrf(data);
						
						$("#modal-login").modal("hide");
						$scope.changeLogin(true);
						$scope.getMypageUser();
						return;

					}).error(function(data, status, headers, config) {
				var messages = [];
				$scope.errors = data;
				$scope.setErrorMessage(data.email, "メールアドレス", messages);
				$scope.setErrorMessage(data.password, "パスワード", messages);
				$scope.setErrorMessage(data.error_message, "", messages);
				$scope.displayMessages = $scope.getMessage(messages);
				return;
			});
		};
	} ]);
