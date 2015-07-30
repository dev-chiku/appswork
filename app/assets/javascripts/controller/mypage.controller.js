'use strict';

/*
 * MYページ用コントローラー
 */
app.controller('MypageCtrl', [
	'$scope',
	'$rootScope',
	'$routeParams',
	'$controller',
	'$location',
	'$log',
	'userModel',
	'workProposesModel',
	'worksModel',
	'proposeOkMessageModel',
	'userService',
	function($scope, $rootScope, $routeParams, $controller, $location, $log, 
			userModel, workProposesModel, worksModel, proposeOkMessageModel, userService) {
		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
		
		$log.debug("MypageCtrl Start");
	
		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.userModel = userModel.user.get();
		$scope.workProposes = workProposesModel.workProposes.get();
		$scope.works = worksModel.works.get();
		$scope.tabKbn = 1;
	
		// MainCtrlでダイアログを開いた時にデータを取得、セット
		$scope.$on('changedUser', function() {
			$scope.userModel = userModel.user.get();
		});
		$scope.$on('changedWorkProposes', function() {
			$scope.workProposes = workProposesModel.workProposes.get();
		});
		$scope.$on('changedWorks', function() {
			$scope.works = worksModel.works.get();
		});
	
		$scope.updateUser = function(userModel) {
			$scope.errors = null;
			$scope.displayMessages = "";
			$scope.showProgressModal();
			userModel.birthday = $("#userModel_birthday").val();
			
			userService.updateUser(userModel).success(
					function(data, status, headers, config) {
						$scope.hideProgressModal();
						$scope.displayMessages = "更新されました。";
						$('body,html').animate({
							scrollTop : 0
						}, 'slow');
						return;
	
					}).error(function(data, status, headers, config) {
						$scope.hideProgressModal();
						var messages = [];
						$scope.errors = data;
						$scope.setErrorMessage(data.email, "メールアドレス",
								messages);
						$scope.setErrorMessage(data.current_password,
								"現在のパスワード", messages);
						$scope.setErrorMessage(data.password, "変更パスワード",
								messages);
						$scope.setErrorMessage(data.display_name, "表示名",
								messages);
						$scope.setErrorMessage(data.birthday, "生年月日",
								messages);
						$scope.setErrorMessage(data.error_message, "",
								messages);
						$scope.displayMessages = $scope
								.getMessage(messages);
						$('body,html').animate({
							scrollTop : 0
						}, 'slow');
						return;
					});
		};
	
		$scope.doLogout = function() {
			 userService.logoutUser().success(function (data, status,
					 headers, config) {
				// csrfが書き換わってしまう為、再設定する
				$scope.resetCsrf(data);

				 $("#modal-profile").modal("hide");
				 $scope.changeLogin(false);
				 $location.path("/");
				 return;
			 }).error(function (data, status, headers, config) {
				 return;
			 });
		};
		
		$scope.doOkPropose = function(propose) {
			var proposeOkMessage = proposeOkMessageModel.proposeOkMessage.getInitModel();
			proposeOkMessage.item_id = propose.item_id;
			proposeOkMessage.receive_user_id = propose.create_user_id;
			proposeOkMessageModel.proposeOkMessage.set(proposeOkMessage);
			$("#modal-propose-ok-message").modal("show");
		};
		
		$scope.getOkProposeString = function(okFlg) {
			if (okFlg == undefined || String(okFlg) != "1") {
				return "提案に合意する";
			}
			return "提案に合意済み";
		};

		$scope.checkWorkCategory = function(value) {
			if ($scope.userModel.work_categories == undefined ||
					$scope.userModel.work_categories == null ||
					$scope.userModel.work_categories.length == undefined ||
					$scope.userModel.work_categories.length == 0) {
				$scope.userModel.work_categories = [];
				var workCategory = userModel.user.getUserWorkCategories();
				workCategory.name_id = value;
				$scope.userModel.work_categories.push(workCategory);
				$log.debug("checkWorkCategory first add " + value);
				$log.debug("checkWorkCategory first add " + JSON.stringify($scope.userModel.work_categories));
				return;
			}

			var isExists = false;
			angular.forEach($scope.userModel.work_categories, function(category, i) {
				if (category.name_id != undefined && String(category.name_id) == String(value)) {
					$scope.userModel.work_categories.splice(i, 1);
					$log.debug("checkWorkCategory del " + value);
					$log.debug("checkWorkCategory del " + JSON.stringify($scope.userModel.work_categories));
					isExists = true;
					return;
				}
			});
			
			if (!isExists) {
				var workCategory = userModel.user.getUserWorkCategories();
				workCategory.name_id = value;
				$scope.userModel.work_categories.push(workCategory);
				$log.debug("checkWorkCategory end add " + value);
				$log.debug("checkWorkCategory end add " + JSON.stringify($scope.userModel.work_categories));
			}
		};
		
		$scope.isCheckWorkCategory = function(value) {
			if ($scope.userModel == undefined ||
					$scope.userModel.work_categories == undefined ||
					$scope.userModel.work_categories == null ||
					$scope.userModel.work_categories.length == undefined ||
					$scope.userModel.work_categories.length == 0) {
				return false;
			}

			var isExists = false;
			angular.forEach($scope.userModel.work_categories, function(category, i) {
				if (category.name_id != undefined && String(category.name_id) == String(value)) {
					isExists = true;
					return;
				}
			});
			
			return isExists;
		};

		$scope.getCheckWorkCategories = function() {
			if ($scope.userModel == undefined ||
					$scope.userModel.work_categories == undefined ||
					$scope.userModel.work_categories == null ||
					$scope.userModel.work_categories.length == undefined ||
					$scope.userModel.work_categories.length == 0) {
				return "(選択されていません)";
			}

			var categories = "";
			categories += "下記の仕事カテゴリが選択されています";
			angular.forEach($scope.userModel.work_categories, function(category, i) {
				categories += "¥n";
				categories += "(" + $scope.getWorkKbnName(String(category.name_id)) + ")";
			});
			
			return categories;
		};

		
		$scope.selectImage = function() {
			$rootScope.uploadKbn = 1;
			$('#avatar').click();	
		};
		
		$rootScope.chageUploadImage = function() {
			$scope.userModel.img_path = "/assets/img-loading.gif";
			$('#upload-submit').click();
		};
		
		$rootScope.uploadComplete = function(content) {
			$scope.userModel.img_path = content.img_path;
			$scope.userModel.img_file_name = content.img_file_name;
			$scope.userModel.tmp_img_path = content.tmp_img_path;
			$scope.userModel.tmp_file_name = content.tmp_file_name;
		};
		
		$scope.getAge = function() {
			if ($scope.userModel == undefined
					|| $scope.userModel.birthday == undefined
					|| $scope.userModel.birthday == null
					|| $scope.userModel.birthday == "") {
				return "年齢表示";
			}
			
			if (!$scope.checkDate($scope.userModel.birthday)) {
				return "年齢表示";
			}
	
			var today = new Date();
			today = today.getFullYear() * 10000 + today.getMonth() * 100 + 100 + today.getDate();
			var birthday = parseInt($scope.userModel.birthday.replace(/-/g,''));
			return (Math.floor((today-birthday)/10000)) + "才";
		};

		$scope.moveMessage = function() {
			$location.path("/message");
			$("#modal-profile").modal("hide");
		};

		$scope.selectTab = function(tabKbn) {
			$scope.tabKbn = tabKbn;
		};
		
		$scope.getOkMsg = function(workPropose) {
			if (workPropose.ok_flg == undefined || 
					workPropose.user_id == undefined || 
					workPropose.user_name == undefined || workPropose.ok_flg != "1") {
				return "";
			}
			
			var ret = '<a href="employer/' + String(workPropose.user_id) + '">' + workPropose.user_name + '</a>さんがあなたの提案に同意しました。<br />';
			ret += '<a href="message/target/' + String(workPropose.msg_id) + '">同意メッセージ</a>などをご確認頂き、直接やり取りの上、お仕事を進めてください。';
			return ret;
		};
		
		/**
		 * カレンダー選択反映処理
		 */
		$('.date').unbind();
		$('.date').on(
				"dp.change",
				function(e) {
					$scope.userModel.birthday = $('.date').children(
							'input[type="text"]').val();
					if ($scope.$root.$$phase != '$apply'
							&& $scope.$root.$$phase != '$digest') {
						$scope.$apply();
					}
				});
	
		/**
		 * カレンダー変更反映処理
		 */
		$('.date').children('input[type="text"]').blur(
				function() {
					$scope.userModel.birthday = $('.date').children(
							'input[type="text"]').val();
					if ($scope.$root.$$phase != '$apply'
							&& $scope.$root.$$phase != '$digest') {
						$scope.$apply();
					}
				});
		
		if ($routeParams.rId != undefined) {
			switch ($routeParams.rId) {
			case "1":
				$("#my-basic-info-tab").click();
				break;
			case "2":
				$("#my-profile-tab").click();
				break;
			case "3":
				$("#my-entry-tab").click();
				break;
			case "4":
				$("#my-recruit-tab").click();
				break;
			case "5":
				$("#my-message-tab").click();
				break;
			}
			$scope.tabKbn = Number($routeParams.rId);
			return;
		}
		
		$scope.hideProgressModal();
	} ]);
