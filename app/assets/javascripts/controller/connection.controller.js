'use strict';

/*
 * つながり用コントローラー.
 */
app.controller('ConnectionCtrl', 
	['$scope',
	'$controller',
	'$routeParams',
	'$timeout',
	'$interval',
	'$log',
	'connectionsModel',
	'connectionService',
	function($scope, $controller, $routeParams, $timeout, $interval, $log,
			connectionsModel, connectionService) {

		// 基底コントローラーの継承
		$controller('AbstractCtrl', {
			$scope : $scope
		});
	
		$log.debug("EmployerCtrl Start");
		
		$scope.connections = connectionsModel.connections.get();
		
		$scope.errors = null;
		$scope.displayMessages = "";
		$scope.data_kbn = 1;
		
		// 初期データ定義
		var pieData = [
            {
                value: 0,
                color:"#46BFBD",
                highlight: "#5AD3D1",
                label: "新しいつながり数"
            },
            {
                value: 0,
                color: "#FDB45C",
                highlight: "#FFC870",
                label: "再度のつながり数"
            }
        ];
		var weekData = {
			    labels: ["日曜", "月曜", "火曜", "水曜", "木曜", "金曜", "土曜"],
			    datasets: [
			        {
			            label: "新しいつながり数",
			            fillColor: "rgba(70,191,189,0.5)",
			            strokeColor: "rgba(70,191,189,0.8)",
			            highlightFill: "rgba(70,191,189,0.75)",
			            highlightStroke: "rgba(70,191,189,1)",
			            data: [0, 0, 0, 0, 0, 0, 0]
			        },
			        {
			            label: "再度のつながり数",
			            fillColor: "rgba(253,180,92,0.5)",
			            strokeColor: "rgba(253,180,92,0.8)",
			            highlightFill: "rgba(253,180,92,0.75)",
			            highlightStroke: "rgba(253,180,92,1)",
			            data: [0, 0, 0, 0, 0, 0, 0]
			        }
			    ]
			};				

		var monthData = {
			    labels: ["1日", "2日", "3日", "4日", "5日", "6日", "7日", "8日", "9日", "10日", "11日", "12日", "13日", "14日", "15日", "16日", "17日", "18日", "19日", "20日", "21日", "22日", "23日", "24日", "25日", "26日", "27日", "28日", "29日", "30日", "31日"],
			    datasets: [
			        {
			            label: "新しいつながり数",
			            fillColor: "rgba(70,191,189,0.5)",
			            strokeColor: "rgba(70,191,189,0.8)",
			            highlightFill: "rgba(70,191,189,0.75)",
			            highlightStroke: "rgba(70,191,189,1)",
			            data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
			        },
			        {
			            label: "再度のつながり数",
			            fillColor: "rgba(253,180,92,0.5)",
			            strokeColor: "rgba(253,180,92,0.8)",
			            highlightFill: "rgba(253,180,92,0.75)",
			            highlightStroke: "rgba(253,180,92,1)",
			            data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
			        }
			    ]
			};

		$scope.selectChartKbn = function($event, data_kbn) {
			$scope.data_kbn = data_kbn;
			$scope.setChartData();
			$("#btn-this-week").removeClass("btn-default-ex-active");
		};

		$scope.getChartKbnName = function() {
			if ($scope.data_kbn == undefined) {
				return "つながり";
			}
			switch ($scope.data_kbn) {
			case 1:
				return "今週のつながり";
			case 2:
				return "今月のつながり";
			default:
				return "すべての期間のつながり";
			}
		};

		/** 
		 * つながり情報取得 
		 */
		$scope.getConnections = function() {
			connectionService.getConnectins().success(function(data, status, headers, config) {
				$scope.connections = data;
				$scope.setChartData();
				$log.debug(JSON.stringify(data));
				return;

			}).error(function(data, status, headers, config) {
				return;
			});
		};
		
		/** 
		 * Chart情報セット 
		 */
		$scope.setChartData = function() {
			// 初期化
			pieData[0].value = 0;
			pieData[1].value = 0;
			var newList = [];
			var reList = [];
			var allList = [];
			var options = {
					legendTemplate : "<ul style=\"margin-left: 36px;\"><% for (var i=0; i<segments.length; i++){%><li style=\"color:<%=segments[i].fillColor%>;\"><span style=\"margin-top: 10px;list-style: none; margin-left: -20px; margin-right: 10px;display:inline-block; width: 25px; color:<%=segments[i].fillColor%>; background-color:<%=segments[i].fillColor%>\">AA</span><%if(segments[i].label){%><spn style=\"color: #666666;\"><%=segments[i].label%></span><%}%></li><%}%></ul>"
			    };
			if ($scope.myPieChart != undefined && $scope.myPieChart != null) {
				$scope.myPieChart.clear();
			}
			if ($scope.myBarChart != undefined && $scope.myBarChart != null) {
				$scope.myBarChart.clear();
			}

			switch ($scope.data_kbn) {
			case 1:		// 週間
				// 円グラフデータセット
				if ($scope.connections.this_week_pie_connect != undefined 
						&& $scope.connections.this_week_pie_connect.length != undefined 
						&& $scope.connections.this_week_pie_connect.length != 0) {
					pieData[0].value = $scope.connections.this_week_pie_connect[0].cn_new_cnt;
					pieData[1].value = $scope.connections.this_week_pie_connect[0].cn_re_cnt;
				}
				
				// 棒グラフデータセット
				weekData.datasets[0].data = [0, 0, 0, 0, 0, 0, 0];
				weekData.datasets[1].data = [0, 0, 0, 0, 0, 0, 0];
				if ($scope.connections.this_week_bar_new_connect != undefined 
						&& $scope.connections.this_week_bar_new_connect.length != undefined 
						&& $scope.connections.this_week_bar_new_connect.length != 0) {
					var result = $scope.connections.this_week_bar_new_connect[0];
					weekData.datasets[0].data = [result.cn1_cnt, result.cn2_cnt, result.cn3_cnt, result.cn4_cnt, result.cn5_cnt, result.cn6_cnt, result.cn7_cnt];
				}
				if ($scope.connections.this_week_bar_re_connect != undefined 
						&& $scope.connections.this_week_bar_re_connect.length != undefined 
						&& $scope.connections.this_week_bar_re_connect.length != 0) {
					var result = $scope.connections.this_week_bar_re_connect[0];
					weekData.datasets[1].data = [result.cn1_cnt, result.cn2_cnt, result.cn3_cnt, result.cn4_cnt, result.cn5_cnt, result.cn6_cnt, result.cn7_cnt];
				}
				
				// 一覧データセット
				if ($scope.connections.this_week_list_connect != undefined 
						&& $scope.connections.this_week_list_connect.length != undefined 
						&& $scope.connections.this_week_list_connect.length != 0) {
					var results = $scope.connections.this_week_list_connect;
					angular.forEach(results, function(result, i) {
						if (result.new_flg == 1) {
							newList.push(result);
						} else {
							reList.push(result);
						}
						allList.push(result);
					});
				}
				
				// Chart描画
				$scope.myPieChart = new Chart($("#pie-chart").get(0).getContext("2d")).Pie(pieData, options);
				$("#pie-legend").html($scope.myPieChart.generateLegend());
				$scope.myBarChart = new Chart($("#bar-chart").get(0).getContext("2d")).Bar(weekData, {
				    animateScale: true
				});
				
				break;
				
			case 2:		// 月間
				// 円グラフデータセット
				if ($scope.connections.this_month_pie_connect != undefined 
						&& $scope.connections.this_month_pie_connect.length != undefined 
						&& $scope.connections.this_month_pie_connect.length != 0) {
					pieData[0].value = $scope.connections.this_month_pie_connect[0].cn_new_cnt;
					pieData[1].value = $scope.connections.this_month_pie_connect[0].cn_re_cnt;
				}
				
				// 棒グラフデータセット
				monthData.datasets[0].data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
				monthData.datasets[1].data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
				if ($scope.connections.this_month_bar_new_connect != undefined 
						&& $scope.connections.this_month_bar_new_connect.length != undefined 
						&& $scope.connections.this_month_bar_new_connect.length != 0) {
					var results = $scope.connections.this_month_bar_new_connect;
					var days = [];
					for (i = 1; i <= 31; i = i +1){
						var dayValue = 0;
						angular.forEach(results, function(result, m) {
							if (result.cn_day == i) {
								dayValue = result.cn_cnt;
								return;
							}
						});
						days.push(dayValue);
					}
					monthData.datasets[0].data = days;
				}
				if ($scope.connections.this_month_bar_re_connect != undefined 
						&& $scope.connections.this_month_bar_re_connect.length != undefined 
						&& $scope.connections.this_month_bar_re_connect.length != 0) {
					var results = $scope.connections.this_month_bar_re_connect;
					var days = [];
					for (i = 1; i <= 31; i = i +1){
						var dayValue = 0;
						angular.forEach(results, function(result, m) {
							if (result.cn_day == i) {
								dayValue = result.cn_cnt;
								return;
							}
						});
						days.push(dayValue);
					}
					monthData.datasets[1].data = days;
				}
				
				// 一覧データセット
				if ($scope.connections.this_month_list_connect != undefined 
						&& $scope.connections.this_month_list_connect.length != undefined 
						&& $scope.connections.this_month_list_connect.length != 0) {
					var results = $scope.connections.this_month_list_connect;
					angular.forEach(results, function(result, i) {
						if (result.new_flg == 1) {
							newList.push(result);
						} else {
							reList.push(result);
						}
						allList.push(result);
					});
				}
				
				// Chart描画
				$scope.myPieChart = new Chart($("#pie-chart").get(0).getContext("2d")).Pie(pieData, options);
				$("#pie-legend").html($scope.myPieChart.generateLegend());
				$scope.myBarChart = new Chart($("#bar-chart").get(0).getContext("2d")).Bar(monthData, {
				    animateScale: true
				});
				
				break;
				
			case 3:		// すべての期間
				// 円グラフデータセット
				if ($scope.connections.this_all_pie_connect != undefined 
						&& $scope.connections.this_all_pie_connect.length != undefined 
						&& $scope.connections.this_all_pie_connect.length != 0) {
					pieData[0].value = $scope.connections.this_all_pie_connect[0].cn_new_cnt;
					pieData[1].value = $scope.connections.this_all_pie_connect[0].cn_re_cnt;
				}

				// 一覧データセット
				if ($scope.connections.this_all_list_connect != undefined 
						&& $scope.connections.this_all_list_connect.length != undefined 
						&& $scope.connections.this_all_list_connect.length != 0) {
					var results = $scope.connections.this_all_list_connect;
					angular.forEach(results, function(result, i) {
						if (result.new_flg == 1) {
							newList.push(result);
						} else {
							reList.push(result);
						}
						allList.push(result);
					});
				}
				
				// Chart描画
				$scope.myPieChart = new Chart($("#pie-chart").get(0).getContext("2d")).Pie(pieData, options);
				$("#pie-legend").html($scope.myPieChart.generateLegend());
				
				break;
			}
			
			$scope.newList = newList;
			$scope.reList = reList;
			$scope.allList = allList;
		};
		
		$scope.getMessage = function(data) {
			if (data == undefined || data.connect_kbn == undefined) {
				return "";
			}
			
			var userStr = '<a href="employer/' + data.from_user_id + '">' + data.user_name + '</a>';
			var title = '<a href="work/detail/' + data.item_id + '">' + data.title + '</a>';
			var userInf = '<a href="employer/' + data.to_user_id + '">ユーザー情報</a>';
			
			// 1:案件詳細(formに閲覧者) 
			// 2:案件詳細(formに案件掲載者) 
			// 3:提案(formに提案者) 
			// 4:提案(formに案件掲載者) 
			// 5:メッセージ(formに送信者) 
			// 6:メッセージ(formに受信者) 
			// 7:ユーザー情報(formに閲覧者)
			// 8:ユーザー情報(formに閲覧対象ユーザー)
			// 9:再提案(formに提案者) 
			// 10:再提案(formに案件掲載者) 
			switch (data.connect_kbn) {
			case 1:
				return userStr + "さんがあなたの募集「" + title + "」を閲覧しました。";
			case 2:
				return userStr + "さんの募集「" + title + "」を閲覧しました。";
			case 3:
				return userStr + "さんがあなたの募集「" + title + "」に提案しました。";
			case 4:
				return userStr + "さんの募集「" + title + "」に提案しました。";
			case 5:
				return userStr + "さんからメッセージを受信しました。";
			case 6:
				return "あなたが" + userStr + "さんにメッセージを送信しました。";
			case 7:
				return userStr + "さんがあなたの" + userInf + "を閲覧しました。";
			case 8:
				return userStr + "さんのユーザー情報を閲覧しました。";
			case 9:
				return userStr + "さんがあなたの募集「" + title + "」に再提案しました。";
			case 10:
				return userStr + "さんの募集「" + title + "」に再提案しました。";
			case 11:
				return userStr + "さんがあなたの募集「" + title + "」をお気に入りに追加しました。";
			case 12:
				return userStr + "さんの募集「" + title + "」をお気に入りに追加しました。";
			case 13:
				return userStr + "さんがあなたの募集「" + title + "」をお気に入りから削除しました。";
			case 14:
				return userStr + "さんの募集「" + title + "」をお気に入りから削除しました。";
			case 15:
				return userStr + "さんがあなたの募集「" + title + "」に質問を投稿しました。";
			case 16:
				return userStr + "さんの募集「" + title + "」に質問を投稿しました。";
			}
			
			return "";
			
		};
		
		$scope.isBarChartShow = function() {
			if ($scope.data_kbn == undefined || $scope.data_kbn == 3) {
				return false;
			}
			return true;
		};
		
		// つながり情報取得
		$scope.getConnections();
		
	} ]);
