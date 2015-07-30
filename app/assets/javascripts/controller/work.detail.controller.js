'use strict';

/*
 * 仕事詳細ページ用コントローラー
 */
app.controller('WorkDetailCtrl', [
	'$scope',
	'$controller',
	'$routeParams',
	'$log',
	'workModel',
	'workProposeModel',
	'workCommentsModel',
	'workCommentModel',
	'workRecruitModel',
	'workFavoriteModel',
	'proposeOkMessageModel',
	'itemService',
	'itemProposeService',
	'itemCommentService',
	'itemFavoriteService',
	function($scope, $controller, $routeParams, $log, workModel, 
			workProposeModel, workCommentsModel, workCommentModel, 
			workRecruitModel, workFavoriteModel, proposeOkMessageModel,
			itemService, itemProposeService, itemCommentService, itemFavoriteService) {
	
		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
		
		$log.debug("WorkDetailCtrl Start");

		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.displayProposeMessages = "";
		$scope.displayCommentMessages = "";
		$scope.workModel = workModel.work.get();
		$scope.workProposeModel = workProposeModel.workPropose.get();
		$scope.workCommentsModel = workCommentsModel.workComments.get();
		$scope.workCommentModel = workCommentModel.workComment.get();
		$scope.workFavoriteModel = workFavoriteModel.workFavorite.get();
			
		// WorkRecruteCtrlで保存後、ダイアログを閉じた時にセット
		$scope.$on('changedWork', function() {
			var work = workModel.work.get();
			if (work.id == $scope.workModel.id) {
				$scope.getWork();
			}
		});

		// 共通初期処理
		$scope.initCommon();

		// URLパラメータ取得
		if ($routeParams.rId == undefined || $routeParams.rId == "") {
			// エラーメッセージ表示
			$scope.displayCommonMsg(messageKbn.err_0004);	// URLパラメーターが不正です。
			return;
		}
		
		$scope.getWork = function() {
			itemService.getItem($routeParams.rId).success(function (data, status, headers, config) {
				// モデルセット
				$scope.workModel = data.item;
				$scope.workModel.owner_flg = data.owner_flg;
				
				if ($scope.workModel.price == undefined || $scope.workModel.price == "") {
					$scope.workModel.price = "無し";
				}
				if ($scope.workModel.noki == undefined || $scope.workModel.noki == "") {
					$scope.workModel.noki = "無し";
				}
				if ($scope.workModel.price_kbn_nm == undefined || $scope.workModel.price_kbn_nm == "") {
					$scope.workModel.price_kbn_nm = "指定無し";
				}
				if ($scope.workModel.hour_price_kbn_nm == undefined || $scope.workModel.hour_price_kbn_nm == "") {
					$scope.workModel.hour_price_kbn_nm = "指定無し";
				}
				
				$scope.workProposeModel.payment_kbn = $scope.workModel.payment_kbn;
				
				$scope.getWorkPropose();
				$scope.getWorkComment();
				
				if ($scope.isLimitDays()) {
					$scope.displayProposeMessages = "提案の募集期間が終了している為、提案はできません。";
				}
				
				return;
				
			}).error(function (data, status, headers, config) {
				return;
		    });
		};
		
		$scope.getWorkComment = function() {
			itemCommentService.getItemComments($routeParams.rId).success(function (data, status, headers, config) {
				if (data == undefined || data == "") {
					$scope.workCommentsModel = [];
					return;
				}
				
				// モデルセット
				workCommentsModel.workComments.set(data);
				$scope.workCommentsModel = workCommentsModel.workComments.get();
				
				return;
				
			}).error(function (data, status, headers, config) {
				// エラーメッセージ表示
				$scope.displayMessages = data;
				$(window).scrollTop(0);
				return;
		    });
		};
		
		$scope.getWorkPropose = function() {
			itemProposeService.getItemPropose($routeParams.rId).success(function (data, status, headers, config) {
				if (data == undefined || data == "") {
					$scope.workProposeModel = workProposeModel.workPropose.getInitModel();
					$scope.workProposeModel.payment_kbn = $scope.workModel.payment_kbn;
					return;
				}
				
				// モデルセット
				workProposeModel.workPropose.set(data);
				$scope.workProposeModel = workProposeModel.workPropose.get();
				
				$("#btnEntry").click();
				
				return;
				
			}).error(function (data, status, headers, config) {
				$scope.workProposeModel = workProposeModel.workPropose.getInitModel();
				$scope.workProposeModel.payment_kbn = $scope.workModel.payment_kbn;

				return;
		    });
		};		
		
		$scope.updateWorkPropose = function(workProposeModel) {
			
			if (workProposeModel.ok_flg != undefined && workProposeModel.ok_flg == 1) {
				$("#alert-message").html("すでに合意されている提案の為、編集できません。");
				$("#modal-alert").modal("show");
				return;
			}

			$scope.errors = null;
			$scope.displayProposeMessages = "";
			workProposeModel.item_id = $routeParams.rId;
			workProposeModel.noki = $("#workProposeModel_noki").val();
			
			if (workProposeModel.id == undefined 
					|| workProposeModel.id == "") {
				$scope.showProgressModal();
				itemProposeService.insertItemPropose(workProposeModel).success(function(data, status, headers, config) {
					$scope.hideProgressModal();
					$scope.workProposeModel.id = data.id;
					$scope.workModel.propose_count = $scope.workModel.propose_count + 1;
					$scope.displayProposeMessages = "提案が登録されました。提案した仕事の履歴はMYページより確認できます。";
					$('body, html').animate({ scrollTop: 315 }, 'slow');
					return;
					
				}).error(function(data, status, headers, config) {
					$scope.hideProgressModal();
					var messages = [];
					$scope.errors = data;
					$scope.setErrorMessage(data.payment_kbn, "支払方式", messages);
					$scope.setErrorMessage(data.hour_price, "時給", messages);
					$scope.setErrorMessage(data.week_hour_kbn, "仕事量", messages);
					$scope.setErrorMessage(data.week_hour_period_kbn, "予定期間", messages);
					$scope.setErrorMessage(data.price, "提案金額", messages);
					$scope.setErrorMessage(data.noki, "完了予定日", messages);
					$scope.setErrorMessage(data.content, "メッセージ", messages);
					$scope.setErrorMessage(data.error_message, "", messages);
					$scope.displayProposeMessages = $scope.getMessage(messages);
					$('body, html').animate({ scrollTop: 315 }, 'slow');
					$scope.showLoginDialogWhenNotLogin($scope.getWork);
					return;
				});
			} else {
				// 再提案の確認メッセージ表示
				$("#modal-confirm-message").html("再提案を行います。よろしいですか？<br>（クライアントにメッセージが再送されます）");
				$scope.workProposeModel = workProposeModel;
				$scope.showCofirmDialog($scope.updateWorkProposeExec);
			}
		};
		
		$scope.showCofirmDialog = function(callback) {
			$log.debug("showCofirmDialog");
			$("#modal-confirm").modal("show");
			$('#btnConfirmOk').unbind();
			$('#btnConfirmOk').on('click', function() {
				$log.debug("showCofirmDialog OK");
				$("#modal-confirm").modal("hide");
				$scope.showProgressModal();
				workProposeModel = $scope.workProposeModel;
				itemProposeService.updateItemPropose(workProposeModel).success(function(data, status, headers, config) {
					$scope.hideProgressModal();
					$scope.displayProposeMessages = "提案が更新されました。提案した仕事の履歴はMYページより確認できます。";
					$('body, html').animate({ scrollTop: 315 }, 'slow');
					return;
					
				}).error(function(data, status, headers, config) {
					$scope.hideProgressModal();
					var messages = [];
					$scope.errors = data;
					$scope.setErrorMessage(data.payment_kbn, "支払方式", messages);
					$scope.setErrorMessage(data.hour_price, "時給", messages);
					$scope.setErrorMessage(data.week_hour_kbn, "仕事量", messages);
					$scope.setErrorMessage(data.week_hour_period_kbn, "予定期間", messages);
					$scope.setErrorMessage(data.price, "提案金額", messages);
					$scope.setErrorMessage(data.noki, "完了予定日", messages);
					$scope.setErrorMessage(data.content, "メッセージ", messages);
					$scope.setErrorMessage(data.error_message, "", messages);
					$scope.displayProposeMessages = $scope.getMessage(messages);
					$('body, html').animate({ scrollTop: 315 }, 'slow');
					$scope.showLoginDialogWhenNotLogin($scope.getWork);
					return;
				});	
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

		$scope.insertComment = function(workCommentModel) {
			$scope.showProgressModal();
			$scope.displayCommentMessages = "";
			workCommentModel.item_id = $routeParams.rId;
			itemCommentService.insertItemComment(workCommentModel).success(function(data, status, headers, config) {
				$scope.hideProgressModal();
				$scope.displayCommentMessages = "";
				workCommentModel.comment = "";
				if ($scope.workCommentsModel == undefined) {
					$scope.workCommentsModel = [];
				}
				$scope.workCommentsModel.unshift(data);
				var offset = $( "#question-list" ).offset();
				$('body, html').animate({ scrollTop: offset.top - 80 }, 'slow');
				return;
				
			}).error(function(data, status, headers, config) {
				$scope.hideProgressModal();
				var messages = [];
				$scope.errors = data;
				$scope.setErrorMessage(data.comment, "質問内容", messages);
				$scope.setErrorMessage(data.error_message, "", messages);
				$scope.displayCommentMessages = $scope.getMessage(messages);
				var offset = $( "#question-list" ).offset();
				$('body, html').animate({ scrollTop: offset.top - 80 }, 'slow');
				$scope.showLoginDialogWhenNotLogin($scope.getWork);
				return;
			});				
		};
		
		$scope.updateFavorite = function() {
			itemFavoriteService.updateItemFavorite($scope.workModel.own_favorite_flg, $scope.workModel.id).success(function(data, status, headers, config) {
				if ($scope.workModel.own_favorite_flg == 1) {
					$scope.workModel.own_favorite_flg = 0;
					$scope.workModel.favorite_count = $scope.workModel.favorite_count - 1; 
				} else {
					$scope.workModel.own_favorite_flg = 1;
					$scope.workModel.favorite_count = $scope.workModel.favorite_count + 1; 
				}
				return;
				
			}).error(function(data, status, headers, config) {
				$scope.errors = data;
				$scope.showLoginDialogWhenNotLogin($scope.getWork);
				return;
			});				
		};
		
		$scope.changeWorkKbn = function() {
			$scope.workProposeModel.work_kbn_nm = $scope
					.getWorkKbnName($scope.workProposeModel.work_kbn);
		};
	
		$scope.isProjectPayment = function(payment_kbn) {
			if (payment_kbn == undefined) {
				if ($scope.workModel
						&& $scope.workModel.payment_kbn
						&& $scope.workModel.payment_kbn == "122") {
					return true;
				}
			} else {
				if (payment_kbn == "122") {
					return true;
				}
			}
			return false;
		};

		$scope.isProjectPaymentForPropose = function() {
			if ($scope.workProposeModel
					&& $scope.workProposeModel.payment_kbn
					&& $scope.workProposeModel.payment_kbn == "122") {
				return true;
			}
			return false;
		};

		$scope.isPreview = function() {
			if ($scope.workModel != undefined
					&& $scope.workModel.preview_flg != undefined
					&& $scope.workModel.preview_flg == "1") {
				return true;
			}
			return false;
		};

		$scope.initWorkModel = function() {
			$scope.workModel.work_kbn = '';
			$scope.workModel.payment_kbn = '1';
			$scope.workModel.price = '';
			$scope.workModel.period_kbn = '';
			$scope.workModel.noki = '';
			$scope.workModel.hour_price_kbn = '6';
			$scope.workModel.hour_price_kbn_nm = '3,000円 - 4,000円 / 時間';
			$scope.workModel.week_hour_kbn = '1';
			$scope.workModel.week_hour_kbn_nm = '10時間未満';
			$scope.workModel.week_hour_period_kbn = '3';
			$scope.workModel.week_hour_period_kbn_nm = '1 - 3ヶ月';
			$scope.workModel.option_kbn = '';
			$scope.workModel.limit_date = '';
			$scope.workModel.title = '';
			$scope.workModel.content = '';
			$scope.workModel.work_kbn_nm = '選択されていません';
		};
		
		$scope.isOwner = function() {
			if ($scope.workModel.owner_flg != undefined
					&& String($scope.workModel.owner_flg) == "1") {
				return true;
			}
			return false;
		};
		
		$scope.isEdit = function() {
			if ($scope.isOwner() && !$scope.isPreview()) {
				return true;
			}
			return false;
		};
		
		$scope.editWorkRecruit = function() {
			workRecruitModel.workRecruit.init();
			workRecruitModel.workRecruit.set(JSON.parse(JSON.stringify($scope.workModel)));
			$("#modal-recruit").modal("show");			
		};
		
		$scope.getItemFavoriteString = function() {
			if ($scope.workModel == undefined 
					|| $scope.workModel.own_favorite_flg == undefined) {
				return "気になるリストへ追加";
			}
			
			if ($scope.workModel.own_favorite_flg == 1) {
				if ($scope.workModel.favorite_count == undefined) {
					return "気になるリストから削除";
				} else {
					return "気になるリストから削除 (" + $scope.workModel.favorite_count + ")";
				}
			} else {
				if ($scope.workModel.favorite_count == undefined) {
					return "気になるリストへ追加";
				} else {
					return "気になるリストへ追加 (" + $scope.workModel.favorite_count + ")";
				}
			}
		};
		
		$scope.getEndDayString = function(limit_days) {
			if (limit_days == undefined) {
				return "";
			}
			
			if (limit_days > 0) {
				return "(残り" + limit_days + "日)";
			} else {
				return '(募集終了)';
			}
		};

		$scope.isLimitDays = function() {
			if ($scope.workModel == undefined || $scope.workModel.limit_days == undefined) {
				return true;
			}
			
			if ($scope.workModel.limit_days > 0) {
				return false;
			} else {
				return true;
			}
		};

		$scope.getWork();
		
	} ]);
