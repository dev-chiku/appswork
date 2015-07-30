'use strict';

/*
 * angularモジュール登録
 */
var app = angular.module('appswork', [ 'ngRoute', 'ngUpload' ]).config(
		function($routeProvider, $locationProvider) {
			
			$locationProvider.html5Mode(true);
//			<base href="/">
			
			// ルーティング設定
			$routeProvider.when('/', {
				templateUrl : "/templates/index.html",
				controller : 'IndexCtrl'
			}).when('/work', {
				templateUrl : "/templates/index.html",
				controller : 'IndexCtrl'
			}).when('/message', {
				templateUrl : "/templates/message.html",
				controller : 'MessageCtrl'
			}).when('/message/:rId', {
				templateUrl : "/templates/message.html",
				controller : 'MessageCtrl'
			}).when('/message/target/:rId', {
				templateUrl : "/templates/message.html",
				controller : 'MessageCtrl'
			}).when('/employer/:rId', {
				templateUrl : "/templates/employer.html",
				controller : 'EmployerCtrl'
			}).when('/work/detail/:rId', {
				templateUrl : '/templates/detail.html',
				controller : 'WorkDetailCtrl'
			}).when('/mypage', {
				templateUrl : '/templates/mypage.html',
				controller : 'MypageCtrl'
			}).when('/connection', {
				templateUrl : '/templates/connection.html',
				controller : 'ConnectionCtrl'
			}).when('/mypage/:rId', {
				templateUrl : '/templates/mypage.html',
				controller : 'MypageCtrl'
			}).when('/privacypolicy', {
				templateUrl : '/templates/privacypolicy.html',
				controller : 'AbstractCtrl'
			}).when('/agreement', {
				templateUrl : '/templates/agreement.html',
				controller : 'AbstractCtrl'
			}).otherwise({
				redirectTo : '/'
			});
		});

app.config(['$httpProvider', function($httpProvider) {
	$httpProvider.defaults.headers.common = {'X-Requested-With': 'XMLHttpRequest'};
	$httpProvider.defaults.headers.post['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
	$httpProvider.defaults.headers.put['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
	$httpProvider.defaults.headers.patch['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
	$httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

app.filter('lineBreak', function ($sce) {
    return function (input, exp) {
    	if (input == undefined || 
    			input == null) {
    		return "";
    	}
        var replacedHtml = input.replace(/"/g, '&quot;').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        return $sce.trustAsHtml(replacedHtml.replace(/¥n|¥r/g, '<br>').replace(/[\n\r]/g, "<br />"));
    };
});

app.filter('doTrustAsHtml', function ($sce) {
    return function (input, exp) {
    	if (input == undefined || 
    			input == null) {
    		return "";
    	}
        return $sce.trustAsHtml(input);
    };
});