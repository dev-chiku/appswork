'use strict';

/*
 * 提案同意メッセージダイアログ用コントローラー
 */
app.controller('ProposeOkMessageCtrl', [
	'$scope',
	'$rootScope',
	'$routeParams',
	'$controller',
	'$location',
	'$log',
	'proposeOkMessageModel',
	'worksModel',
	'messageService',
	function($scope, $rootScope, $routeParams, $controller, $location, $log, 
			proposeOkMessageModel, worksModel, messageService) {
		
		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("ProposeOkMessageCtrl Start");

		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.proposeOkMessage = proposeOkMessageModel.proposeOkMessage.get();

		$scope.$on('changedProposeOkMessage', function() {
			$scope.proposeOkMessage = proposeOkMessageModel.proposeOkMessage.get();
		});

		$scope.insertProposeOkMessage = function(proposeOkMessage) {
			$scope.errors = null;
			$scope.displayMessages = "";
			$scope.showProgressModal();
			messageService.insertProposeOkMessage(proposeOkMessage).success(
					function(data, status, headers, config) {
						$scope.hideProgressModal();
						$("#modal-propose-ok-message").modal("hide");
						
						var works = worksModel.works.get();
						var flg = true;
						if (data != undefined && works != undefined) {
							angular.forEach(works, function(work, i) {
								angular.forEach(work.proposes, function(propose, i) {
									if (propose.id == data.id) {
										propose.ok_flg = 1;
										worksModel.works.set(works);
										flg = false;
										return;
									}
								});
								
								if (!flg) {
									return;
								}
							});
						}
						
						return;
	
					}).error(function(data, status, headers, config) {
						$scope.hideProgressModal();
						var messages = [];
						$scope.errors = data;
						$scope.setErrorMessage(data.content, "メッセージ", messages);
						$scope.setErrorMessage(data.error_message, "", messages);
						$scope.displayMessages = $scope.getMessage(messages);
						$('body,html').animate({
							scrollTop : 0
						}, 'slow');
						return;
					});
		};
	} ]);
