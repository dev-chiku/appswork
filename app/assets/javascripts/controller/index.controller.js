'use strict';

/*
 * TOP画面用コントローラー
 */
app.controller('IndexCtrl',
	['$scope',
	 '$rootScope',
	'$controller',
	'$timeout',
	'$interval',
	'$location',
	'$log',
	'worksIndexModel',
	'searchModel',
	'itemService',
	'userService',
	function($scope, $rootScope, $controller, $timeout, $interval, $location, $log,
			worksIndexModel, searchModel, itemService, userService) {

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("IndexCtrl Start");
		
		$scope.worksIndex = worksIndexModel.worksIndex.get();
		
		// IndexCtrlで保存後、検索ソート変更後にセット
		$scope.$on('changedSearch', function() {
			$scope.search = searchModel.search.get();
			$scope.getWorkList($scope.search);
		});

	    /** 
	     * 検索条件をローカルストレージより取得 
	     * @return {object} 検索条件
	     */
		$scope.getSearchlocalStorage = function() {
			var storage = localStorage;
			if (storage == undefined ||
					storage == null) {
				return null;
			}
			var searchJsonString = storage.getItem('search');
			if (searchJsonString == undefined ||
					searchJsonString == null ||
					searchJsonString == "") {
				return null;
			}
			return JSON.parse(searchJsonString);
		};
		
	    /** 
	     * 検索条件をローカルストレージにセット 
	     * @param {object} search 検索条件
	     */
		$scope.setSearchlocalStorage = function(search) {
			var storage = localStorage;
			if (storage == undefined ||
					storage == null) {
				return;
			}
			var searchJsonString = JSON.stringify(search);
			storage.setItem('search', searchJsonString);
			return;
		};
		
	    /** 
	     * 仕事リスト取得 
	     * @param {object} search 検索条件
	     * @param {boolean} isButton true:ボタンクリックにより実行 false:コントローラ生成時などの実行
	     */
		$scope.getWorkList = function(search, isButton) {
			itemService.getItems(search).success(function(data, status, headers, config) {
				$scope.worksIndex = data;
				$scope.setSearchlocalStorage(search);
				if (isButton) {
					$('#modal-work-search').modal('hide');
				}
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
		};
		
	    /** 
	     * 3列構成の最終列判定
	     * @return {boolean} true:3列目 false:3列目以外
	     */
		$scope.isLastCol = function(index) {
			if ((index + 1) % 3 == 0) {
				return true;
			}
			return false;
		};

	    /** 
	     * 残り日数文字列取得
	     * @return {String} 残り日数文字列
	     */
		$scope.getLimitDayString = function(limitDay) {
			if (limitDay != undefined && limitDay > 0) {
				return "残り " + limitDay + "日";
			}
			return "募集終了";
		};

	    /** 
	     * 募集終了判定
	     * @return {String} 残り日数文字列
	     * @return {boolean} true:募集終了 false:受付中
	     */
		$scope.isLimitDayEnd = function(limitDay) {
			if (limitDay != undefined && limitDay > 0) {
				return false;
			}
			return true;
		};
		

	    /** 
	     * 支払区分による非有効化判定
	     * @param {boolean} isHour true:時給制 false:時給制以外
	     * @return {boolean} true:非有効化 false:有効化
	     */
		$scope.isDisablePaymentKbn = function(isHour) {
			if ($scope.search == undefined ||
					$scope.search.payment_kbn == undefined) {
				return false;
			}

			if (isHour) {
				// 時給制
				if ($scope.search.payment_kbn == "121" 
						|| $scope.search.payment_kbn == "123") {
					return false;
				}
			} else {
				// プロジェクト制
				if ($scope.search.payment_kbn == "122" 
					|| $scope.search.payment_kbn == "123") {
					return false;
				}
			}
			return true;
		};
		
	    /** 
	     * 仕事内容を改行をスペースに変えて返す
	     * @return {String} 仕事内容
	     */
		$scope.getContentString = function(value) {
			if (value == undefined || value == "") {
				return "";
			}
			return value.replace(/\r?\n/g, " ");
		};
		
	    /** 
	     * 支払区分変更時処理
	     */
		$scope.changePaymentKbn = function() {
			if ($scope.search == undefined ||
					$scope.search.payment_kbn == undefined) {
				return;
			}
			
			// 時給制
			if ($scope.search.payment_kbn == "121") {
				$scope.search.projectPriceStart = "";
				$scope.search.projectPriceEnd = "";
			}

			// プロジェクト制
			if ($scope.search.payment_kbn == "122") {
				$scope.search.hourPriceStart = "";
				$scope.search.hourPriceEnd = "";
			}
		};

	    /** 
	     * メール認証処理
	     */
		$scope.authEmail = function() {
			
			if ($rootScope.is_mail_auth_check != undefined &&
					$rootScope.is_mail_auth_check == 1) {
				return;
			}
			
			var param = $scope.getParamEmailToken();
			if (param == "") {
				$rootScope.is_mail_auth_check = 1;
				return;
			}
			
			$scope.errors = null;
			$scope.displayMessages = "";
			userService.authEmail(param).success(function (data, status, headers, config) {
				$rootScope.is_mail_auth_check = 1;
				$("#alert-message").html("メール認証が成功しました。");
				$("#modal-alert").modal("show");
				$('#modal-alert').on('hidden.bs.modal',
					function() {
						$('#modal-alert').unbind();
						$("#modal-login").modal("show");
						$("#inputLoginEmail").focus();
					});	
				return;
				
			}).error(function (data, status, headers, config) {
				$rootScope.is_mail_auth_check = 1;
				var messages = [];
				$scope.errors = data;
				$scope.setErrorMessage(data.error_message, "", messages);
				var msg = $scope.getMessage(messages);
				if (msg == undefined || msg == "") {
					return;
				}
				$("#alert-message").html(msg);
				$("#modal-alert").modal("show");
				return;
				
		    });

		};
		
	    /** 
	     * 仕事カテゴリオールチェック処理
	     */
		$scope.checkAllWorkCategory = function() {
			$scope.search.work_kbn1 = true;
			$scope.search.work_kbn2 = true;
			$scope.search.work_kbn3 = true;
			$scope.search.work_kbn4 = true;
			$scope.search.work_kbn11 = true;
			$scope.search.work_kbn12 = true;
			$scope.search.work_kbn13 = true;
			$scope.search.work_kbn14 = true;
			$scope.search.work_kbn15 = true;
			$scope.search.work_kbn16 = true;
			$scope.search.work_kbn21 = true;
			$scope.search.work_kbn22 = true;
			$scope.search.work_kbn23 = true;
			$scope.search.work_kbn24 = true;
			$scope.search.work_kbn25 = true;
			$scope.search.work_kbn31 = true;
			$scope.search.work_kbn32 = true;
			$scope.search.work_kbn33 = true;
			$scope.search.work_kbn41 = true;
			$scope.search.work_kbn42 = true;
			$scope.search.work_kbn43 = true;
			$scope.search.work_kbn44 = true;
			$scope.search.work_kbn51 = true;
			$scope.search.work_kbn52 = true;
			$scope.search.work_kbn53 = true;
			$scope.search.work_kbn61 = true;
			$scope.search.work_kbn62 = true;
			$scope.search.work_kbn63 = true;
			$scope.search.work_kbn64 = true;
			$scope.search.work_kbn65 = true;
			$scope.search.work_kbn66 = true;
			$scope.search.work_kbn67 = true;
			$scope.search.work_kbn68 = true;
			$scope.search.work_kbn71 = true;
			$scope.search.work_kbn72 = true;
			$scope.search.work_kbn73 = true;
			$scope.search.work_kbn74 = true;
			$scope.search.work_kbn75 = true;
			$scope.search.work_kbn76 = true;	
			if ($scope.$root.$$phase != '$apply'
				&& $scope.$root.$$phase != '$digest') {
				$scope.$apply();
			}
		};
		
	    /** 
	     * 仕事カテゴリオールアンチェック処理
	     */
		$scope.unCheckAllWorkCategory = function() {
			$scope.search.work_kbn1 = false;
			$scope.search.work_kbn2 = false;
			$scope.search.work_kbn3 = false;
			$scope.search.work_kbn4 = false;
			$scope.search.work_kbn11 = false;
			$scope.search.work_kbn12 = false;
			$scope.search.work_kbn13 = false;
			$scope.search.work_kbn14 = false;
			$scope.search.work_kbn15 = false;
			$scope.search.work_kbn16 = false;
			$scope.search.work_kbn21 = false;
			$scope.search.work_kbn22 = false;
			$scope.search.work_kbn23 = false;
			$scope.search.work_kbn24 = false;
			$scope.search.work_kbn25 = false;
			$scope.search.work_kbn31 = false;
			$scope.search.work_kbn32 = false;
			$scope.search.work_kbn33 = false;
			$scope.search.work_kbn41 = false;
			$scope.search.work_kbn42 = false;
			$scope.search.work_kbn43 = false;
			$scope.search.work_kbn44 = false;
			$scope.search.work_kbn51 = false;
			$scope.search.work_kbn52 = false;
			$scope.search.work_kbn53 = false;
			$scope.search.work_kbn61 = false;
			$scope.search.work_kbn62 = false;
			$scope.search.work_kbn63 = false;
			$scope.search.work_kbn64 = false;
			$scope.search.work_kbn65 = false;
			$scope.search.work_kbn66 = false;
			$scope.search.work_kbn67 = false;
			$scope.search.work_kbn68 = false;
			$scope.search.work_kbn71 = false;
			$scope.search.work_kbn72 = false;
			$scope.search.work_kbn73 = false;
			$scope.search.work_kbn74 = false;
			$scope.search.work_kbn75 = false;
			$scope.search.work_kbn76 = false;	
			if ($scope.$root.$$phase != '$apply'
				&& $scope.$root.$$phase != '$digest') {
				$scope.$apply();
			}
		};

		// モーダル背景高さ変更の為の処理
		var stop;
		$('#modal-work-search').unbind();
		$('#modal-work-search').on(
				'shown.bs.modal',
				function() {
					stop = $interval(function() {
						$('#modal-work-search').modal(
								'handleUpdate');
					}, 200);
				});
		$('#modal-work-search').on('hidden.bs.modal',
				function() {
					if (angular.isDefined(stop)) {
						$interval.cancel(stop);
					}
				});	
		
		// 検索条件をローカルストレージより取得し、モデルにセット
		$scope.search = $scope.getSearchlocalStorage();
		if ($scope.search == undefined ||
				$scope.search == null ||
				$scope.search == "") {
			$scope.search = searchModel.search.get();
		} else {
			searchModel.search.set($scope.search);
		}
		
		// 仕事リスト取得
		$scope.getWorkList($scope.search, false);
		
		// mail認証処理
		$scope.authEmail();
		
	} ]);
