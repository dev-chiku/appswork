'use strict';

/*
 * メッセージ用コントローラー
 */
app.controller('MessageCtrl', 
	['$scope',
	'$controller',
	'$timeout',
	'$interval',
	'$routeParams',
	'$location',
	'$log',
	'userModel',
	'usersModel',
	'messagesModel',
	'messageModel',
	'searchMessageModel',
	'searchUserModel',
	'userService',
	'messageService',
	'notificationService',
	function($scope, $controller, $timeout, $interval, $routeParams, $location, $log,
			userModel, usersModel, messagesModel, messageModel, 
			searchMessageModel, searchUserModel, userService, messageService, notificationService) {

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("MessageCtrl Start");
		
		$scope.messages = messagesModel.messages.get();
		$scope.message = messageModel.message.get();
		$scope.users = usersModel.users.get();
		$scope.searchMessage = searchMessageModel.searchMessage.get();
		$scope.searchUser = searchUserModel.searchUser.get();
		$scope.selectedUser = null;
		
		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.errorsSend = null;
		$scope.displaySendMessages = "";

		$scope.getMessageList = function(search, isButton) {
			messageService.getMessages(search).success(function(data, status, headers, config) {
				$scope.messages = data;

				if ($location.path().indexOf("target") != -1) {
					$timeout(function(){
						$("#target" + $routeParams.rId).click();
						var offset = $("#target" + $routeParams.rId).offset();
						var myTop = offset.top;
						$('body').animate({
							scrollTop : myTop - 82
						}, 'slow');
		            }, 0);
				}
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
		};
		
		$scope.getMypageUser = function() {
			userService.getMypageUser().success(function(data, status, headers, config) {
				userModel.user
						.set(data.user);
				$scope.userModel = userModel.user
						.get();
				return;

			}).error(function(data, status, headers, config) {
				return;
				
			});
		};
		
		$scope.insertMessage = function(detail, message) {
			message.errors = null;
			message.displayMessages = "";
			
			message.item_id = detail.item_id;
			message.parent_id = detail.id;

			$scope.userModel = userModel.user.get();

			if (detail.receive_user_id != $scope.userModel.id) {
				message.receive_user_id = detail.receive_user_id;
			} else {
				message.receive_user_id = detail.send_user_id;
			}
			message.send_user_id = $scope.userModel.id;

			$scope.showProgressModal();
			
			messageService.insertMessage(message).success(function (data, status, headers, config) {
				$scope.hideProgressModal();
				detail.details.unshift(data);
				message.errors = data;
				message.displayMessages = "";
				message.content = "";
				return;
				
			}).error(function (data, status, headers, config) {
				$scope.hideProgressModal();
				var messages = [];
				message.errors = data;
				$scope.setErrorMessage(data.content, "メッセージ", messages);
				message.displayMessages = $scope.getMessage(messages);
				return;
		    });
	    };
		
		$scope.getUserList = function(search) {
			$scope.errorsSend = null;
			$scope.selectedUser = null;
			$scope.displaySendMessages = "";
			
			userService.getUsers(search).success(function(data, status, headers, config) {
				$scope.users = data;
				angular.forEach($scope.users, function(user, i) {
					if (user.img_path == undefined || user.img_path == null || user.img_path == "") {
						user.img_path = "/assets/person.jpg";
					}
				});
				
				return;

			}).error(function(data, status, headers, config) {
				var messages = [];
				$scope.users = [];
				$scope.errorsSend = data;
				$scope.setErrorMessage(data.error_message, "", messages);
				$scope.displaySendMessages = $scope.getMessage(messages);
				return;
			});
		};
		
		$scope.insertMessageThread = function(selectedUser) {
			$scope.errorsSend = null;
			$scope.displaySendMessages = "";
			
			var message = messageModel.message.getInitModel();
			
			$scope.userModel = userModel.user.get();
			message.send_user_id = $scope.userModel.id;
			message.receive_user_id = selectedUser.user_id;
			message.title = selectedUser.title;
			message.content = selectedUser.content;
			
			$scope.showProgressModal();
			
			messageService.insertMessage(message).success(function (data, status, headers, config) {
				$scope.hideProgressModal();
				
				if ($scope.messages == undefined || $scope.messages == null) {
					$scope.messages = [];
				}
				$scope.messages.unshift(data);
				$('#modal-message').modal('hide');
				return;
				
			}).error(function (data, status, headers, config) {
				$scope.hideProgressModal();

				var messages = [];
				$scope.errorsSend = data;
				$scope.setErrorMessage(data.title, "タイトル", messages);
				$scope.setErrorMessage(data.content, "メッセージ", messages);
				$scope.displaySendMessages = $scope.getMessage(messages);
				return;
		    });
	    };
	    
		$scope.getEmployer = function() {
			userService.getUser($routeParams.rId).success(function(data, status, headers, config) {
				if (data != undefined && data.content != undefined) {
					data.content = "";
				}
				$scope.selectedUser = data;
				$scope.openAddMessageDialog();
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
		};
		
	    $scope.selectUser = function(userMessage) {
	    	$scope.selectedUser = userMessage;
		};

	    $scope.isSelectUser = function() {
	    	if ($scope.selectedUser == undefined 
	    			|| $scope.selectedUser == null) {
	    		return false;
	    	}
	    	return true;
		};
	    
		$scope.openAddMessageDialog = function() {
			$scope.userMessage = null;
			$("#modal-message").modal("show");
		};
	    
		$scope.selectTitle = function(titleMsg) {
			if (titleMsg.notification_msg_count == undefined || titleMsg.notification_msg_count == 0) {
				return;
			}
			
			notificationService.deleteNotification(titleMsg.id, 1).success(function (data, status, headers, config) {
				$scope.getMypageUser();
				titleMsg.notification_msg_count = 0;
				return;
				
			}).error(function (data, status, headers, config) {
				var messages = [];
				$scope.errorsSend = data;
				$scope.displaySendMessages = $scope.getMessage(messages);
				return;
		    });			
		};
		
		var stop;

		$('#modal-message').unbind();
		$('#modal-message').on(
				'shown.bs.modal',
				function() {
					stop = $interval(function() {
						$('#modal-message').modal(
								'handleUpdate');
					}, 200);
				});

		$('#modal-message').on('hidden.bs.modal',
				function() {
					if (angular.isDefined(stop)) {
						$interval.cancel(stop);
					}
				});

	    
	    $scope.getMypageUser();
		$scope.getMessageList($scope.search, false);

		if ($routeParams.rId != undefined && $routeParams.rId != "") {
			if ($location.path().indexOf("target") == -1) {
				$scope.getEmployer();
			}
		}

	} ]);
