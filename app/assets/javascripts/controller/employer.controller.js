'use strict';

/*
 * ユーザー情報用コントローラー.
 */
app.controller('EmployerCtrl', 
	['$scope',
	'$controller',
	'$routeParams',
	'$timeout',
	'$interval',
	'$log',
	'employerModel',
	'userService',
	function($scope, $controller, $routeParams, $timeout, $interval, $log,
			employerModel, userService) {

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("EmployerCtrl Start");
		
		$scope.employer = employerModel.employer.get();
		
		// URLパラメータ取得
		if ($routeParams.rId == undefined || $routeParams.rId == "") {
			// エラーメッセージ表示
			$scope.displayCommonMsg(messageKbn.err_0004);	// URLパラメーターが不正です。
			return;
		}

		$scope.errors = null;
		$scope.displayMessages = "";

		/** 
		 * ユーザー情報取得 
		 */
		$scope.getEmployer = function() {
			userService.getUser($routeParams.rId).success(function(data, status, headers, config) {
				$scope.employer = data;
				$scope.employer.user_inf = $scope.getUserInf();
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
		};
		
		/** 
		 * ユーザー仕事カテゴリ存在判定 
		 * @return {boolean} true:存在 false:未存在
		 */
		$scope.isCategoriesExists = function() {
			if ($scope.employer == undefined 
					|| $scope.employer.work_categories == undefined 
					|| $scope.employer.work_categories.length == undefined
					|| $scope.employer.work_categories.length == 0) {
				return false;
			}
			return true;
		};

		/** 
		 * ユーザー情報文字列(性別、年齢、地域)取得 
		 */
		$scope.getUserInf = function() {
			var ret = "";
			if ($scope.employer == undefined) {
				return "";
			}
			
			if ($scope.employer.sex_name != undefined 
					&& $scope.employer.sex_name != null 
					&& $scope.employer.sex_name != "") {
				ret += "性別：" + $scope.employer.sex_name;
			}
			if ($scope.employer.birthday_str != undefined 
					&& $scope.employer.birthday_str != null 
					&& $scope.employer.birthday_str != "") {
				if (ret != "") {
					ret += "¥n";
				}
				
				var today = new Date();
				today = today.getFullYear() * 10000 + today.getMonth() * 100 + 100 + today.getDate();
				var birthday = parseInt($scope.employer.birthday_str.replace(/-/g,''));
				ret += "年齢：" + (Math.floor((today-birthday)/10000)) + "才";
			}
			if ($scope.employer.area_name != undefined 
					&& $scope.employer.area_name != null 
					&& $scope.employer.area_name != ""
					&& $scope.employer.area_name != "未指定") {
				if (ret != "") {
					ret += "¥n";
				}
				ret += "地域：" + $scope.employer.area_name;
			}
			return ret;
		};
		
		// ユーザー情報取得
		$scope.getEmployer();
		
	} ]);
