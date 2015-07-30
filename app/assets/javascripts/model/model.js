'use strict';

/*
 * User Model
 */
app.factory('userModel', [ "$rootScope", function($rootScope) {
	
	var user = {
		id : 0,
		email : '',
		password : '',
		current_password : '',
		display_name : '',
		confirm_flg : '',
		content : '',
		img_path : '/assets/noimage.gif',
		user_kbn : 191,
		sex : 203,
		birthday : '',
		area : 300,
		save_login_flg : 1,
		work_categories : []
	};

	return {
		user : {
			get : function() {
				return user;
			},
			getUserWorkCategories : function() {
				return {
					id : 0,
					user_id : 0,
					name_id : 0
				};
			},
			set : function(model) {
				user = model;
				$rootScope.$broadcast('changedUser');
			}
		}
	};		
} ]);

/** 
 * Users Model
 */
app.factory("usersModel", [ "$rootScope", function($rootScope) {
	var users = {};

	return {
		users : {
			get : function() {
				return users;
			},
			set : function(models) {
				users = models;
				$rootScope.$broadcast('changedUsers');
			}
		}
	};
} ]);

/*
 * Work Model
 */
app.factory('workModel', [ "$rootScope", function($rootScope) {
	
	var work = {
		id : 0,
		work_kbn : '',
		payment_kbn : '121',
		price : 0,
		price_kbn : '405',
		price_kbn_nm : '50万円 〜 100万円',
		period_kbn : '',
		noki : '',
		hour_price_kbn : '136',
		hour_price_kbn_nm : '3,000円 - 4,000円 / 時間',
		week_hour_kbn : '151',
		week_hour_kbn_nm : '10時間未満',
		week_hour_period_kbn : '173',
		week_hour_period_kbn_nm : '1 - 3ヶ月',
		option_kbn : '',
		limit_date : '',
		title : '',
		content : '',
		preview_flg : 0,
		work_kbn_nm : '選択されていません'
	};

	return {
		work : {
			get : function() {
				return work;
			},
			set : function(model) {
				work = model;
				$rootScope.$broadcast('changedWork');
			}
		}
	};	
} ]);

/*
 * Work Recruit Model
 */
app.factory('workRecruitModel', [ "$rootScope", function($rootScope) {
	
	var workRecruit = {
		id : 0,
		work_kbn : '',
		payment_kbn : '121',
		price : 0,
		price_kbn : '405',
		price_kbn_nm : '50万円 〜 100万円',
		period_kbn : '',
		noki : '',
		hour_price_kbn : '136',
		hour_price_kbn_nm : '3,000円 - 4,000円 / 時間',
		week_hour_kbn : '151',
		week_hour_kbn_nm : '10時間未満',
		week_hour_period_kbn : '173',
		week_hour_period_kbn_nm : '1 - 3ヶ月',
		option_kbn : '',
		limit_date : '',
		title : '',
		content : '',
		preview_flg : 0,
		work_kbn_nm : '選択されていません'
	};

	return {
		workRecruit : {
			get : function() {
				return workRecruit;
			},
			init : function() {
				workRecruit.id = 0;
				workRecruit.work_kbn = '';
				workRecruit.payment_kbn = '121';
				workRecruit.price = '';
				workRecruit.price_kbn = '405';
				workRecruit.price_kbn_nm = '50万円 〜 100万円';
				workRecruit.period_kbn = '';
				workRecruit.noki = '';
				workRecruit.hour_price_kbn = '136';
				workRecruit.hour_price_kbn_nm = '3,000円 - 4,000円 / 時間';
				workRecruit.week_hour_kbn = '151';
				workRecruit.week_hour_kbn_nm = '10時間未満';
				workRecruit.week_hour_period_kbn = '173';
				workRecruit.week_hour_period_kbn_nm = '1 - 3ヶ月';
				workRecruit.option_kbn = '';
				workRecruit.limit_date = '';
				workRecruit.title = '';
				workRecruit.content = '';
				workRecruit.work_kbn_nm = '選択されていません';
			},
			set : function(model) {
				workRecruit = model;
				$rootScope.$broadcast('changedWorkRecruit');
			}
		}
	};	
} ]);

/** 
 * Works Model
 */
app.factory("worksModel", [ "$rootScope", function($rootScope) {
	var works = {};

	return {
		works : {
			get : function() {
				return works;
			},
			set : function(models) {
				works = models;
				$rootScope.$broadcast('changedWorks');
			}
		}
	};
} ]);

/** 
 * Works Index Model
 */
app.factory("worksIndexModel", [ "$rootScope", function($rootScope) {
	var worksIndex = {};

	return {
		worksIndex : {
			get : function() {
				return worksIndex;
			},
			set : function(models) {
				worksIndex = models;
				$rootScope.$broadcast('changedWorksIndex');
			}
		}
	};
} ]);

/*
 * Search Model
 */
app.factory('searchModel', [ "$rootScope", function($rootScope) {
	
	var search = {
		work_kbn1 : true,
		work_kbn2 : true,
		work_kbn3 : true,
		work_kbn4 : true,
		work_kbn11 : true,
		work_kbn12 : true,
		work_kbn13 : true,
		work_kbn14 : true,
		work_kbn15 : true,
		work_kbn16 : true,
		work_kbn21 : true,
		work_kbn22 : true,
		work_kbn23 : true,
		work_kbn24 : true,
		work_kbn25 : true,
		work_kbn31 : true,
		work_kbn32 : true,
		work_kbn33 : true,
		work_kbn41 : true,
		work_kbn42 : true,
		work_kbn43 : true,
		work_kbn44 : true,
		work_kbn51 : true,
		work_kbn52 : true,
		work_kbn53 : true,
		work_kbn61 : true,
		work_kbn62 : true,
		work_kbn63 : true,
		work_kbn64 : true,
		work_kbn65 : true,
		work_kbn66 : true,
		work_kbn67 : true,
		work_kbn68 : true,
		work_kbn71 : true,
		work_kbn72 : true,
		work_kbn73 : true,
		work_kbn74 : true,
		work_kbn75 : true,
		work_kbn76 : true,
		payment_kbn : 123,
		hourPriceStart : '',
		hourPriceEnd : '',
		projectPriceStart : '',
		projectPriceEnd : '',
		order_kbn : 411,
		favorite_only_flg : false,
		exclude_end_flg : false,
		order_kbn_nm : '新着順'
	};

	return {
		search : {
			get : function() {
				return search;
			},
			set : function(model) {
				search = model;
				$rootScope.$broadcast('changedSearch');
			}
		}
	};	
} ]);

/*
 * Work Propose Model
 */
app.factory('workProposeModel', [ "$rootScope", function($rootScope) {
	
	var workPropose = {
		payment_kbn : '121',
		price : 0,
		period_kbn : '',
		noki : '',
		hour_price : 0,
		week_hour_kbn : '151',
		week_hour_kbn_nm : '10時間未満',
		week_hour_period_kbn : '173',
		week_hour_period_kbn_nm : '1 - 3ヶ月',
		content : ''
	};
	
	return {
		workPropose : {
			get : function() {
				return workPropose;
			},
			getInitModel : function() {
				return {
					payment_kbn : '121',
					price : 0,
					period_kbn : '',
					noki : '',
					hour_price : 0,
					week_hour_kbn : '151',
					week_hour_kbn_nm : '10時間未満',
					week_hour_period_kbn : '173',
					week_hour_period_kbn_nm : '1 - 3ヶ月',
					content : ''
				};
			},
			set : function(model) {
				workPropose = model;
				$rootScope.$broadcast('changedWorkPropose');
			}
		}
	};	
} ]);

/** 
 * Work Proposes Model
 */
app.factory("workProposesModel", [ "$rootScope", function($rootScope) {
	var workProposes = {};

	return {
		workProposes : {
			get : function() {
				return workProposes;
			},
			set : function(models) {
				workProposes = models;
				$rootScope.$broadcast('changedWorkProposes');
			}
		}
	};
} ]);

/*
 * Search Message Model
 */
app.factory('searchMessageModel', [ "$rootScope", function($rootScope) {
	
	var searchMessage = {
		title : ""
	};

	return {
		searchMessage : {
			get : function() {
				return searchMessage;
			},
			set : function(model) {
				searchMessage = model;
				$rootScope.$broadcast('changedSearchMessage');
			}
		}
	};	
} ]);

/*
 * Search User Model
 */
app.factory('searchUserModel', [ "$rootScope", function($rootScope) {
	
	var searchUser = {
		user_name : ""
	};

	return {
		searchUser : {
			get : function() {
				return searchUser;
			},
			set : function(model) {
				searchUser = model;
				$rootScope.$broadcast('changedSearchUser');
			}
		}
	};	
} ]);

/*
 * Message Model
 */
app.factory('messageModel', [ "$rootScope", function($rootScope) {
	
	var message = {
		id : 0,
		item_id : 0,
		parent_id : 0,
		send_user_id : 0,
		receive_user_id : 0,
		title : '',
		content : ''
	};

	return {
		message : {
			get : function() {
				return message;
			},
			getInitModel : function() {
				return {
					id : 0,
					item_id : 0,
					parent_id : 0,
					send_user_id : 0,
					receive_user_id : 0,
					title : '',
					content : ''
				};
			},
			set : function(model) {
				message = model;
				$rootScope.$broadcast('changedMessage');
			}
		}
	};	
} ]);

/*
 * Propose Ok Message Model
 */
app.factory('proposeOkMessageModel', [ "$rootScope", function($rootScope) {
	
	var proposeOkMessage = {
		id : 0,
		item_id : 0,
		parent_id : 0,
		send_user_id : 0,
		receive_user_id : 0,
		title : '',
		content : ''
	};

	return {
		proposeOkMessage : {
			get : function() {
				return proposeOkMessage;
			},
			getInitModel : function() {
				return {
					id : 0,
					item_id : 0,
					parent_id : 0,
					send_user_id : 0,
					receive_user_id : 0,
					title : '',
					content : ''
				};
			},
			set : function(model) {
				proposeOkMessage = model;
				$rootScope.$broadcast('changedProposeOkMessage');
			}
		}
	};	
} ]);

/** 
 * Messages Model
 */
app.factory("messagesModel", [ "$rootScope", function($rootScope) {
	var messages = {};

	return {
		messages : {
			get : function() {
				return messages;
			},
			set : function(models) {
				messages = models;
				$rootScope.$broadcast('changedMessages');
			}
		}
	};
} ]);

/** 
 * Employer Model
 */
app.factory("employerModel", [ "$rootScope", function($rootScope) {
	var employer = {};

	return {
		employer : {
			get : function() {
				return employer;
			},
			set : function(model) {
				employer = model;
				$rootScope.$broadcast('changedEmployer');
			}
		}
	};
} ]);

/** 
 * Work Comments Model
 */
app.factory("workCommentsModel", [ "$rootScope", function($rootScope) {
	var workComments = {};

	return {
		workComments : {
			get : function() {
				return workComments;
			},
			set : function(models) {
				workComments = models;
				$rootScope.$broadcast('changedWorkComments');
			}
		}
	};
} ]);

/*
 * Work Comment Model
 */
app.factory('workCommentModel', [ "$rootScope", function($rootScope) {
	
	var workComment = {
		id : 0,
		item_id : 0,
		comment : ''
	};

	return {
		workComment : {
			get : function() {
				return workComment;
			},
			getInitModel : function() {
				return {
					id : 0,
					item_id : 0,
					comment : ''
				};
			},
			set : function(model) {
				workComment = model;
				$rootScope.$broadcast('changedWorkComment');
			}
		}
	};	
} ]);

/*
 * Work Favorite Model
 */
app.factory('workFavoriteModel', [ "$rootScope", function($rootScope) {
	
	var workFavorite = {
		id : 0,
		item_id : 0
	};

	return {
		workFavorite : {
			get : function() {
				return workFavorite;
			},
			set : function(model) {
				workFavorite = model;
				$rootScope.$broadcast('changedWorkFavorite');
			}
		}
	};	
} ]);

/** 
 * Notices Model
 */
app.factory("noticesModel", [ "$rootScope", function($rootScope) {
	var notices = {};

	return {
		notices : {
			get : function() {
				return notices;
			},
			set : function(models) {
				notices = models;
				$rootScope.$broadcast('changedNotices');
			}
		}
	};
} ]);

/** 
 * Connections Model
 */
app.factory("connectionsModel", [ "$rootScope", function($rootScope) {
	var connections = {};

	return {
		connections : {
			get : function() {
				return connections;
			},
			set : function(models) {
				connections = models;
				$rootScope.$broadcast('changedConnections');
			}
		}
	};
} ]);
