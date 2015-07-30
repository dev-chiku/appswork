'use strict';

/*
 * 仕事依頼登録ダイアログ用コントローラー
 */
app.controller('WorkRecruitCtrl', [
	'$scope',
	'$controller',
	'$location',
	'$window',
	'$log',
	'workModel',
	'workRecruitModel',
	'searchModel',
	'itemService',
	function($scope, $controller, $location, $window, $log, workModel, workRecruitModel, searchModel, itemService) {
	
		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
		
		$log.debug("WorkRecruitCtrl Start");

		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.workModel = workRecruitModel.workRecruit.get();

		// WorkDetailCtrlとMainCtrlでダイアログを開いた時にデータをセット
		$scope.$on('changedWorkRecruit', function() {
			$scope.workModel = workRecruitModel.workRecruit.get();
		});

		// 共通初期処理
		$scope.initCommon();
	
		$scope.updateWork = function(model, isPreview) {
			
			$scope.showProgressModal();
			$scope.errors = null;
			$scope.displayMessages = "";
			model.limit_date = $("#workModel_limit_date_recruit_modal").val();
			model.noki = $("#workModel_noki_recruit_modal").val();
			
			if (isPreview) {
				model.preview_flg = 1;
			} else {
				model.preview_flg = 0;
			}
			
			itemService.insertItem(model).success(function(data, status, headers, config) {
				$scope.hideProgressModal();
				if (model.preview_flg == 1) {
					$window.open($location.$$protocol + "://" + $location.$$host + ":" + $location.$$port + '/#/work/detail/' + data.id);
					return;
				}
				
				$("#modal-recruit").modal("hide");
				$("#alert-message").html("仕事依頼が登録されました。登録した仕事依頼はMYページより確認できます。");
				$("#modal-alert").modal("show");
				workRecruitModel.workRecruit.init();
				$scope.workModel = workRecruitModel.workRecruit.get();
				workModel.work.set(data);
				
				// 再検索させる為、モデルのセットを行う
				var search = searchModel.search.get();
				searchModel.search.set(search);
				
				return;
				
			}).error(function(data, status, headers, config) {
				$scope.hideProgressModal();
				var messages = [];
				$scope.errors = data;
				$scope.setErrorMessage(data.work_kbn, "仕事カテゴリ", messages);
				$scope.setErrorMessage(data.title, "依頼タイトル", messages);
				$scope.setErrorMessage(data.payment_kbn, "支払方式", messages);
				$scope.setErrorMessage(data.hour_price_kbn, "時給", messages);
				$scope.setErrorMessage(data.week_hour_kbn, "仕事量", messages);
				$scope.setErrorMessage(data.week_hour_period_kbn, "予定期間", messages);
				$scope.setErrorMessage(data.price, "目安予算", messages);
				$scope.setErrorMessage(data.noki, "希望納期", messages);
				$scope.setErrorMessage(data.limit_date, "募集の締め切り", messages);
				$scope.setErrorMessage(data.content, "依頼の目的・背景", messages);
				$scope.setErrorMessage(data.error_message, "", messages);
				$scope.displayMessages = $scope.getMessage(messages);
				$('#modal-recruit').animate({ scrollTop: 0 }, 'slow');
				setTimeout(function(){ 
					$scope.showLoginDialogWhenNotLogin();
			    }, 500);
				setTimeout(function(){ 
					$('#modal-recruit').modal('handleUpdate');
			    }, 1000);
				
				return;
			});
		};
		
		$scope.changeWorkKbn = function() {
			$scope.workModel.work_kbn_nm = $scope
					.getWorkKbnName($scope.workModel.work_kbn);
		};
	
		$scope.isProjectPayment = function() {
			if ($scope.workModel.payment_kbn
					&& $scope.workModel.payment_kbn == "122") {
				return true;
			}
			return false;
		};
	
	} ]);
