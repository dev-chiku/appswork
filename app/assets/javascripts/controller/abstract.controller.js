'use strict';

/*
 * 基底コントローラー
 */
app.controller('AbstractCtrl', [ 
	'$scope', 
	'$rootScope', 
	'$log', 
	'$location', 
	'$timeout', 
	'$interval', 
	'$window',
	'searchModel',
	'userModel',
	'workProposesModel',
	'worksModel',
	'workRecruitModel',
	'userService',
	'itemService',
	'itemProposeService',
	'itemCommentService',
	'messageService',
	'itemFavoriteService',
	'notificationService',
	'noticeService',
	'connectionService',
	function($scope, $rootScope, $log, $location, $timeout, $interval, $window, 
			searchModel, userModel, workProposesModel, worksModel, workRecruitModel, 
			userService, itemService, itemProposeService, itemCommentService,
			messageService, itemFavoriteService, notificationService,
			noticeService, connectionService) {

		$log.debug("AbstractCtrl Start");
		
		/** 
		 * csrfが書き換わってしまう為、再設定する 
		 */
		$scope.resetCsrf = function(data) {
			$("meta[name='csrf-token']").attr('content', data.password);
			userService.setCsrf();
			itemService.setCsrf();
			itemProposeService.setCsrf();
			itemCommentService.setCsrf();
			messageService.setCsrf();
			itemFavoriteService.setCsrf();
			notificationService.setCsrf();
			noticeService.setCsrf();
			connectionService.setCsrf();
		};
		
		/** 
		 * ページ変更時処理 
		 */
		$rootScope.$on("$routeChangeSuccess", function() {

			$log.debug("routeChangeSuccess");
			$('a[rel=tooltip]').tooltip();
			$('span[rel=tooltip]').tooltip();

			$timeout(function(){
				$timeout(function(){
					$('a[rel=tooltip]').tooltip();
					$('span[rel=tooltip]').tooltip();

					try {
						if (twttr != undefined ||
								twttr.widgets != undefined ||
								twttr.widgets.load != undefined) {
							twttr.widgets.load();
						}
						FB.XFBML.parse();
					} catch (e) {
						
					}
					
	            }, 0);
            }, 500);
		});
		
		$scope.doFooterFixed = function() {
			footerFixed();
			$timeout(function(){
				$timeout(function(){
					footerFixed();
	            }, 0);
            }, 500);
		};
		
		$scope.getParamEmailToken = function() {
			var url = $scope.getCurrentFullUrl();
			if (url.indexOf("?") == -1 || url.indexOf("=") == -1) {
				return "";
			}
			var params = url.substring(url.indexOf("?") + 1);
			var param = params.substring(params.indexOf("=") + 1);
			if (param == undefined || param.length == 0) {
				return "";
			}
			param = param.substring(0, param.length);
			if (param == undefined || param.length == 0) {
				return "";
			}
			return param;
		};
		
		/** 
		 * 初期データ取得 
		 */
		$scope.getInitData = function() {
			var user = userModel.user.get();
			if ($scope.getMypageUserFlg) {
				return;
			}
			if (user == undefined || user == null || 
					user.id == undefined || user.id == null || user.id == 0) {
				$scope.getMypageUserFlg = true;
				$scope.getMypageUser();
			}
		};
		
		$scope.isLogin = function() {
			
			var userData = userModel.user.get();
			if (userData == undefined) {
				return false;
			}
			
			if (userData.id == undefined || userData.id == null || 
					userData.id == 0 || userData.id == "0" || userData.id == "") {
				return false;
			}
			
			return true;
		};
		
		/** 
		 * MYページデータ取得 
		 */
		$scope.getMypageUser = function() {
			userService.getMypageUser()
					.success(function(data, status, headers, config) {
						$scope.getMypageUserFlg = false;
						userModel.user
								.set(data.user);
						$scope.userModel = userModel.user
								.get();
						workProposesModel.workProposes
								.set(data.work_proposes);
						$scope.workProposes = workProposesModel.workProposes
								.get();
						worksModel.works
								.set(data.items);
						$scope.works = worksModel.works
								.get();
						
						return;

					}).error(function(data, status, headers, config) {
						$scope.getMypageUserFlg = false;
						return;
					});
		};

		/** 
		 * apply拡張処理 
		 */
		$scope.applyEx = function() {
        	if ($scope.$root == null || $scope.$root.$$phase == null) {
        	    $scope.$apply();
        	    return;
        	}
        	if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
        	    $scope.$apply();
        	}
		};

		/** 
		 * 処理中モーダルダイアログ表示 
		 */
		$scope.showProgressModal = function() {
			$("#progressDialog").modal("show");
		};
		
		/** 
		 * 処理中モーダルダイアログ表示 
		 */
		$scope.hideProgressModal = function() {
			$("#progressDialog").modal("hide");
		};

		/** 
		 * 日付入力コントロールロストフォーカス時ハンドル 
		 * @param {String} elId エレメントID
		 * @param {model} model 入力モデル
		 * @param {String} attrId モデル項目ID
		 */
		$scope.handleBlurDateInput = function(elId, model, attrId) {
			model[attrId] = $(elId).val();
			$scope.applyEx();
		};
		
		/** 
		 * エラーメッセージセット処理 
		 * @param {array} error エラー配列
		 * @param {String} title タイトル
		 * @param {String} messages セットメッセージ
		 */
		$scope.setErrorMessage = function(errors, title, messages) {
			if (!errors || errors.length == 0) {
				return;
			}

			angular.forEach(errors, function(error, i) {
				messages.push(title + error);
			});
		};

		/** 
		 * メッセージ取得処理 
		 * @param {array} messages メッセージ配列
		 * @return {String} allMassage 連結メッセージ
		 */
		$scope.getMessage = function(messages) {
			var allMassage = "";
			angular.forEach(messages, function(message, i) {
				if (allMassage != "") {
					allMassage += "¥n";
				}
				allMassage += message;
			});
			if (allMassage == "") {
				allMassage = "予期せぬエラーが発生しました。";
			}
			return allMassage;
		};
		
		$scope.isError = function(errors) {
			if (errors == undefined || errors == null || errors == "") {
				return false;
			}
			return true;
		};
		
		/** 
		 * 後何文字可能かメッセージ取得
		 * @param {array} messages メッセージ配列
		 * @return {String} allMassage 連結メッセージ
		 */
		$scope.getLimitStringMsg = function(text, maxlength) {
			if (text == undefined || text == null) {
				return "(後" + maxlength + "文字入力可能です)";
			}
			if (maxlength - text.length < 0) {
				return '<span style="color: #e51c23;">(' + ((maxlength - text.length) * -1) + "文字入力オーバーです)</span>";
			} else {
				return "(後" + (maxlength - text.length) + "文字入力可能です)";
			}
		};

		/** 
		 * 現在フルURL取得処理 
		 * @return {String} 現在フルURL
		 */
		$scope.getCurrentFullUrl = function() {
			return $location.$$absUrl;
		};

		/** 
		 * 現在URL取得処理 
		 * @return {String} 現在URL
		 */
		$scope.getCurrentUrl = function() {
			if ($location.$$port == 3000) {
				return $location.$$protocol + "://" + $location.$$host + ":" + $location.$$port;
			} else {
				return $location.$$protocol + "://" + $location.$$host;
			}
		};
		
		/** 
		 * TOPページ判定処理 
		 * @return {boolean} true:topページ false:topページ以外
		 */
		$scope.isTopPage = function() {
			// topページ判定
			if ($location.$$path != undefined && 
					$location.$$path != null && 
					$location.$$path == "/") {
				$rootScope.top_page_flg = true;
			} else {
				$rootScope.top_page_flg = false;
			}
			
			if ($rootScope.top_page_flg == undefined 
					|| $rootScope.top_page_flg == null) {
				return false;
			}
			return $rootScope.top_page_flg;
		};

		/** 
		 * 日付チェック処理 
		 * @param {String} strDate チェック対象日付
		 * @return {boolean} true:日付 false:日付以外
		 */
		$scope.checkDate = function(strDate) {
			
			if (!strDate.match(/^\d{4}\-\d{2}\-\d{2}$/)) {
				return false;
			}
	
			var dateArr = strDate.split("-");
			if (dateArr.length < 3) {
				return false;
			}
	
			var year = Number(dateArr[0]);
			var month = Number(dateArr[1] - 1);
			var day = Number(dateArr[2]);
	
			if (year >= 0 && month >= 0 && month <= 11 && day >= 1
					&& day <= 31) {
				var date = new Date(year, month, day);
				if (isNaN(date)) {
					return false;
				} else if (date.getFullYear() == year
						&& date.getMonth() == month
						&& date.getDate() == day) {
					return true;
				}
			}
			return false;
		};
		
		/** 
		 * 日時フォーマット処理 (YYYY-MM-DD hh:mm:ss)
		 * @param {String} dateStr フォーマット対象日時
		 * @return {String} フォーマット後文字列
		 */
		$scope.getFormatDateTime = function(dateStr) {
			if (dateStr == undefined 
					|| dateStr == null
					|| dateStr == "") {
				return "";
			}

			dateStr = dateStr.replace(/-/g, '/');
			var date = Date.parse(dateStr);

			var format = 'YYYY-MM-DD hh:mm:ss';
			format = format.replace(/YYYY/g, date.getFullYear());
			format = format.replace(/MM/g, ('0' + (date.getMonth() + 1)).slice(-2));
			format = format.replace(/DD/g, ('0' + date.getDate()).slice(-2));
			format = format.replace(/hh/g, ('0' + date.getHours()).slice(-2));
			format = format.replace(/mm/g, ('0' + date.getMinutes()).slice(-2));
			format = format.replace(/ss/g, ('0' + date.getSeconds()).slice(-2));
			return format;				
		};

		/** 
		 * ログインされていない場合、ログインダイアログを表示する
		 * @param {object} callback エラー情報オブジェクト
		 */
		$scope.showLoginDialogWhenNotLogin = function(callback) {
			if (!$scope.errors 
					|| $scope.errors.is_login_check_error == undefined 
					|| $scope.errors.is_login_check_error == false) {
				return;
			}
			
			if (callback != undefined) {
				$rootScope.notLoginCallback = callback;
			}
			
			$("#modal-login").modal("show");
			$("#inputLoginEmail").focus();
			
			return;
		};
		
		/** 
		 * ログイン状態変更時処理
		 * @param {boolean} isLogin true:ログイン時 false:未ログイン時
		 */
		$scope.changeLogin = function(isLogin) {
			$('.change-header li').each(function() {
				if ($(this).attr("class") == "divider" || $(this).attr("class") == "list" || $(this).attr("class") == "both-header") {

				} else if ($(this).attr("class") == "logout-header") {
					if (isLogin) {
						$(this).css("display", "none");
					} else {
						$(this).css("display", "");
					}
				} else {
					if (isLogin) {
						$(this).css("display", "");
					} else {
						$(this).css("display", "none");
					}
				}
			});
		};

		/** 
		 * ドロップダウン選択アイテム反映 
		 * @param {object} $event イベントオブジェクト
		 * @param {model} model 入力モデル
		 * @param {String} attrId モデル項目ID
		 * @param {String} attrName モデル項目名
		 */
		$scope.selectDropDownItem = function($event, model, attrId, attrName) {
			var el = angular.element($event.currentTarget);
			model[attrId] = el.attr('value');
			model[attrName] = el.html();
		};

		/** 
		 * 支払区分判定 
		 * @return {boolean} true:プロジェクト false:時給
		 */
		$scope.isProjectPayment = function(payment_kbn) {
			if (payment_kbn
					&& payment_kbn == "122") {
				return true;
			}
			return false;
		};

		$scope.getNumComma = function(value) {
			if (value == undefined || value == null) {
				return "";
			}
			return String( value ).replace( /(\d)(?=(\d\d\d)+(?!\d))/g, '$1,' );
		};

		/** 
		 * エリア名取得
		 * @return {String} エリア名
		 */
		$scope.getAreaName = function(areaKbn) {
			if (areaKbn == undefined) {
	        	return "選択されていません";
			}
			
			switch (String(areaKbn)) {
	    	case "300":
	        	return "選択されていません";
	    	case "301":
	        	return "北海道";
	    	case "302":
	        	return "青森県";
	    	case "303":
	        	return "岩手県";
	    	case "304":
	        	return "宮城県";
	    	case "305":
	        	return "秋田県";
	    	case "306":
	        	return "山形県";
	    	case "307":
	        	return "福島県";
	    	case "308":
	        	return "茨城県";
	    	case "309":
	        	return "栃木県";
	    	case "310":
	        	return "群馬県";
	    	case "311":
	        	return "埼玉県";
	    	case "312":
	        	return "千葉県";
	    	case "313":
	        	return "東京都";
	    	case "314":
	        	return "神奈川県";
	    	case "315":
	        	return "新潟県";
	    	case "316":
	        	return "富山県";
	    	case "317":
	        	return "石川県";
	    	case "318":
	        	return "福井県";
	    	case "319":
	        	return "山梨県";
	    	case "320":
	        	return "長野県";
	    	case "321":
	        	return "岐阜県";
	    	case "322":
	        	return "静岡県";
	    	case "323":
	        	return "愛知県";
	    	case "324":
	        	return "三重県";
	    	case "325":
	        	return "滋賀県";
	    	case "326":
	        	return "京都府";
	    	case "327":
	        	return "大阪府";
	    	case "328":
	        	return "兵庫県";
	    	case "329":
	        	return "奈良県";
	    	case "330":
	        	return "和歌山県";
	    	case "331":
	        	return "鳥取県";
	    	case "332":
	        	return "島根県";
	    	case "333":
	        	return "岡山県";
	    	case "334":
	        	return "広島県";
	    	case "335":
	        	return "山口県";
	    	case "336":
	        	return "徳島県";
	    	case "337":
	        	return "香川県";
	    	case "338":
	        	return "愛媛県";
	    	case "339":
	        	return "高知県";
	    	case "340":
	        	return "福岡県";
	    	case "341":
	        	return "佐賀県";
	    	case "342":
	        	return "長崎県";
	    	case "343":
	        	return "熊本県";
	    	case "344":
	        	return "大分県";
	    	case "345":
	        	return "宮崎県";
	    	case "346":
	        	return "鹿児島県";
	    	case "347":
	        	return "沖縄県";
	    	case "348":
	        	return "海外";
			}
		};

		/** 
		 * 仕事区分名取得
		 * @param {String} 仕事区分
		 * @return {String} 仕事区分名
		 */
		$scope.getWorkKbnName = function(workKbn) {
	    	switch (workKbn) {
	    	case "1":
	        	return "システム開発・運用 -> Web・システム開発";
	    	case "2":
	        	return "システム開発・運用 -> スマホアプリ・モバイル開発";
	    	case "3":
	        	return "システム開発・運用 -> アプリケーション開発";
	    	case "4":
	        	return "システム開発・運用 -> 運用・管理・保守";
	    	case "11":
	        	return "Web制作・Webデザイン -> ウェブサイト制作・デザイン";
	    	case "12":
	        	return "Web制作・Webデザイン -> スマートフォン・モバイルサイト制作";
	    	case "13":
	        	return "Web制作・Webデザイン -> バナー・アイコン・ボタン";
	    	case "14":
	        	return "Web制作・Webデザイン -> ECサイト・ネットショップ構築・運用";
	    	case "15":
	        	return "Web制作・Webデザイン -> Webマーケティング・HP集客";
	    	case "16":
	        	return "Web制作・Webデザイン -> 運営・更新・保守・SNS運用";
	    	case "21":
	        	return "デザイン制作 -> ロゴ・イラスト・キャラクター";
	    	case "22":
	        	return "デザイン制作 -> 印刷物・DTP・その他";
	    	case "23":
	        	return "デザイン制作 -> POP・シール・メニュー";
	    	case "24":
	        	return "デザイン制作 -> 看板・地図・インフォグラフィック";
	    	case "25":
	        	return "デザイン制作 -> プロダクト・3D";
	    	case "31":
	        	return "ライティング・ネーミング -> ライティング";
	    	case "32":
	        	return "ライティング・ネーミング -> ネーミング・コピー";
	    	case "33":
	        	return "ライティング・ネーミング -> 編集・校正";
	    	case "41":
	        	return "タスク・作業 -> データ作成・テキスト入力";
	    	case "42":
	        	return "タスク・作業 -> レビュー・投稿・アンケート";
	    	case "43":
	        	return "タスク・作業 -> 調査・分析・その他";
	    	case "44":
	        	return "タスク・作業 -> 内職・軽作業・代行";
	    	case "51":
	        	return "マルチメディア -> 動画・写真・画像";
	    	case "52":
	        	return "マルチメディア -> 漫画・アニメーション・ドラマ";
	    	case "53":
	        	return "マルチメディア -> 音楽・音源・ナレーション";
	    	case "61":
	        	return "翻訳 -> 英語翻訳・英文翻訳";
	    	case "62":
	        	return "翻訳 -> 中国語翻訳";
	    	case "63":
	        	return "翻訳 -> 韓国語翻訳";
	    	case "64":
	        	return "翻訳 -> フランス語翻訳";
	    	case "65":
	        	return "翻訳 -> スペイン語翻訳";
	    	case "66":
	        	return "翻訳 -> ドイツ語翻訳";
	    	case "67":
	        	return "翻訳 -> その他翻訳";
	    	case "68":
	        	return "翻訳 -> 映像翻訳・出版翻訳・メディア翻訳";
	    	case "71":
	        	return "企画・リサーチ・その他 -> 企画・PR";
	    	case "72":
	        	return "企画・リサーチ・その他 -> リサーチ・分析・解析";
	    	case "73":
	        	return "企画・リサーチ・その他 -> セールス・ビジネスサポート";
	    	case "74":
	        	return "企画・リサーチ・その他 -> 資料作成サポート";
	    	case "75":
	        	return "企画・リサーチ・その他 -> コンサルティング";
	    	case "76":
	        	return "企画・リサーチ・その他 -> その他";
	    	default:
	        	return "選択されていません";
	    	}
		};			
		
		/** 
		 * 共通初期処理
		 */
		$scope.initCommon = function() {
			var datetimepicker = $('.date').datetimepicker({
				format : 'YYYY-MM-DD',
				language : 'ja',
				autoclose: 'true'
			});
			datetimepicker.unbind();
			datetimepicker.on('change', function(ev){
				$('.bootstrap-datetimepicker-widget').css("display", "none");
	        });
		};
		
		// 共通初期処理
		$scope.initCommon();
		
		// 初期データ取得
		$scope.getInitData();
		
		// 画面の変更を検知する
		if ($rootScope.intarvalStop == undefined) {
			$rootScope.intarvalStop = $interval(function() {
				if ($rootScope.mainRootHeight == undefined) {
					$rootScope.mainRootHeight = $("#main-root").height();
					$scope.doFooterFixed();
					return;
				}
				
				if ($rootScope.mainRootHeight != $("#main-root").height()) {
					$scope.doFooterFixed();
				}
				
				$rootScope.mainRootHeight = $("#main-root").height();
				
			}, 200);
		}		
	} ]);
