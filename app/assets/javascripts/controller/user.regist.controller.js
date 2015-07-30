'use strict';

/*
 * 会員登録ダイアログ用コントローラー
 */
app.controller('UserRegistCtrl', 
		[ '$scope', '$controller', '$log', 'userModel', 'userService',
		  function($scope, $controller, $log, userModel, userService) {
	$scope.errors = null;
	$scope.displayMessages = "";
	$scope.userModel = userModel.user.get();
	
	// 基底コントローラーの継承
	$controller('AbstractCtrl', {$scope: $scope});
	
	$log.debug("UserRegistCtrl Start");

	$scope.inserUser = function(userModel) {
		$scope.errors = null;
		$scope.displayMessages = "";
		if (!userModel || !userModel.confirm_flg) {
			$scope.errors = new Object();
			$scope.errors.confirm_flg = "利用規約とプライバシーポリシーをご確認の上、同意するにチェックを行ってください";
			$scope.displayMessages = $scope.errors.confirm_flg;
			return;
		}
		$scope.showProgressModal();
		userService.insertUser(userModel).success(function (data, status, headers, config) {
			$scope.hideProgressModal();
			$scope.displayMessages = "登録が成功しました。¥n送信された認証メールよりメールアドレスの認証を行ってください。";
			return;
			
		}).error(function (data, status, headers, config) {
			$scope.hideProgressModal();
			var messages = [];
			$scope.errors = data;
			$scope.setErrorMessage(data.email, "メールアドレス", messages);
			$scope.setErrorMessage(data.password, "パスワード", messages);
			$scope.setErrorMessage(data.display_name, "表示名", messages);
			$scope.setErrorMessage(data.error_message, "", messages);
			$scope.displayMessages = $scope.getMessage(messages);
			return;
	    });
    };
	
} ]);

