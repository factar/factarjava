<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
	<base href="<%=basePath%>">
	<title>图层管理</title>
	<link rel="stylesheet" type="text/css"
		href="backstage/css/layerManager.css">
	<link rel="stylesheet" href="backstage/css/zTreeStyle.css" type="text/css">
	<link rel="stylesheet" href="backstage/css/validform.css" type="text/css">
	<script type="text/javascript" src="backstage/js/jquery-1.6.2.min.js"></script>
	<script type="text/javascript" src="backstage/js/tree/tree.js"></script>
	<script type="text/javascript" src="backstage/js/jquery.ztree-2.6.js"></script>
	<script type="text/javascript" src="backstage/js/layer.js"></script>
	<script type="text/javascript" src="backstage/js/cgsjImageManage.js"></script>
	<script type="text/javascript" src="backstage/js/Validform_v5.1_min.js"></script>
	<script type="text/javascript">
	var path = "<%=path%>";
	var _status="";//操作状态对象
	var layerTree;//layer tree 对象
	var zbLayerTree;
	var simpleNodes =[];//tree 数据数组
	var treeSetting = {
		fontCss : setFont,
		showLine : true,
		callback : {
			click : zTreeOnClick
		}
	};  //ztree setting
	var zbTreeSetting = {
			fontCss: setFont,
			showLine: true,
			callback : {
		      click: zTreeOnClick2
		    }
	};
	var layers = [];
	var treeType = "TC";
	
	
	
	// 设置字体颜色
	var colorR = 16;
	var colorG = 80;
	var colorB = 120;
	function setFont(treeId, treeNode) {
		if (treeNode && treeNode.isParent) {
			var css = {color: "#"+colorR.toString(16)+colorG.toString(16)+colorB.toString(16)};
			return css;
		} else {
			return {};
		}
	}
	$(document).ready(function() {
		// 加载各模块位置自适应
		loadWidHei();
		//加载树
		loadTree();
		// 加载图层下拉列表
		loadLayers();
		//添加表单验证
	});

	//自适应屏幕宽高	
	function loadWidHei() {
		var clientHeight = $(window).height();//当前浏览器窗口的高度
		var clientWidth = $(window).width();//当前浏览器窗口的宽度
		$("#leftdiv").css("height", clientHeight);
		$("#rightdiv").css("height", clientHeight);
		$("#leftdiv").css("width", clientWidth * 0.3 - 20);
		$("#rightdiv").css("width", clientWidth * 0.7 - 18);
	}
	function loadTree() {
	  $.post(path + "/LayersServlet",{"action":"init","type":"manage"},function(data){
			eval(data);
//			var treeSetting = clone(setting);
			treeSetting.treeNodeKey = "id";
			treeSetting.treeNodeParentKey = "pId";;
			var treeNodes = clone(simpleNodes);
			treeSetting.isSimpleData = true;
			treeSetting.nameCol = "name";
			treeSetting.expandSpeed = "fast";
			// 字体颜色
			treeSetting.fontCss = setFont;
			layerTree = $("#treeDemo").zTree(treeSetting, treeNodes);
		},"text"); 
	}
	//是否是图层点击事件
	function isLayerChange(){
    		if($("input[name='isLayer'][checked]").val()=="yes"){
//    			document.getElementById("layerSelect").disabled=false;
//    			document.getElementById("fieldSelect").disabled=false;
//    			document.getElementById("isZbTrue").disabled=false;
//    			document.getElementById("isZbFalse").disabled=false;
//    			document.getElementById("layerType").disabled=false;
//    			document.getElementById("isPmtTrue").disabled=false;
//    			document.getElementById("isPmtFalse").disabled=false;
//    			document.getElementById("isLinkTrue").disabled=false;
    			document.getElementById("isLinkFalse").disabled=false;
//    			if($("input[name='zbField'][checked]").val()=="1"){
//    				document.getElementById("zbSelBtn").removeAttribute('disabled');
//    			}else{
//    				document.getElementById("zbSelBtn").disabled="disabled";
//    			}
    			$("#layerTypeContent").show();
    		}else{
    			$("#layerSelect").val("0");
    			changeFieldSelect();
    			document.getElementById("layerSelect").disabled="disabled";
    			document.getElementById("fieldSelect").disabled="disabled";
    			$("input[name='isLink']").attr("disabled","disabled"); 
    			$("input[name='zbField']").attr("disabled","disabled"); 
    			$("input[name='pmtField']").attr("disabled","disabled"); 
    			document.getElementById("zbSelBtn").disabled="disabled";
    			document.getElementById("layerType").disabled="disabled";
    			$("#layerTypeContent").hide();
    		}
    	}
    	//图层类型下拉菜单事件
    	function layerTypeChange(){
			var layerType =$("#layertype").val();
			if(layerType==1){
				$("#layerTypeContent").show();
				$("#layerTypeActual").hide();
				$("#layerTypeCamera").hide();
			}else if(layerType=="actual"){
				$("#layerTypeContent").hide();
				$("#layerTypeActual").show();
				$("#layerTypeCamera").hide();
			}else if(layerType=="camera"){
				$("#layerTypeContent").hide();
				$("#layerTypeActual").hide();
				$("#layerTypeCamera").show();
			}
		}
		
		// 是否关联实时数据单选按钮点击事件
    	function isLinkChange(){
    	alert($("input[name='isLink'][checked]").val());
    		if($("input[name='isLink'][checked]").val()=="yes"){
//    		$("#layerTypeContent input[type='text']").removeAttr("disabled"); 
//			$("#layerTypeContent input[type='text']").removeAttr("readonly"); 
			$("#layerTypeContent input[type='text']").attr("readonly",false); 
    		$("#layerTypeContent input[type='text']").css("color","red"); 
    			var layer = getLayer(layerCodeSelected);
    			if(layer==null){
    				return;
    			}
    			if(	_status!="updateInit"){
	    			// 加载图层数据
					var url = path+"/BackServlet";
//					$.post(url,{action:"getRelation",tableName:layer.desttable},
//						function(data){
//						var relations = data;
//						if(relations.length>0){
//							var options = "";
//							for(var i=0;i<relations.length;i++){
//								var rela = relations[i];
//								$("#ssTable").val(rela.relationtalbe);
//								$("#ssField").val(rela.relationfield);
//								$("#userField").val(rela.field);
//							}
//						}
//						
//					},"json");
				}
    		}else{
//    			$("#layerTypeContent input[type='text']").attr("disabled", "disabled"); 
				$("#layerTypeContent input[type='text']").attr("readOnly","readOnly"); 
    			$("#layerTypeContent input[type='text']").val("");
    		}
    	}
    	//切换图片上传
    	function changetubiao(){
			$("#fileuploadiframe").show();
			$("#tubiaodiv").hide();
		}
		//是否周边查询
		function isZb(){
			if($("input[name='zbField'][checked]").val()=="1"){
				document.getElementById("zbSelBtn").disabled = false;
			}else{
				document.getElementById("zbSelBtn").disabled = true;
			}
		}
		
		//加载周边图层树形
		function loadZbTree(){
			//创建适用于各个浏览器的 XMLHttprequest 对象
			var xmlreq = newXMLHttpRequest();
			//建立于服务器的链接
			xmlreq.open("get",path+"/LayersServlet?action=init&type=manage",true);
			//编写服务器响应后的处理代码
			xmlreq.onreadystatechange=function returnMessage(){
			     //固定格式，验证服务器响应是否完成
			     if (xmlreq.readyState == 4) {
			   		if (xmlreq.status == 200) {
						//响应正确完成
						//alert("服务器响应成功!!!");
						//得到服务器返回数据
						var result = xmlreq.responseText;
						//执行返回语句
						eval(result);
					
						var zNodes2 = clone(simpleNodes);
						zbTreeSetting.treeNodeKey = "id";
						zbTreeSetting.treeNodeParentKey = "pId";
						zbTreeSetting.isSimpleData = true;
						zbTreeSetting.nameCol = "name";
						zbTreeSetting.expandSpeed = "fast";
						// 字体颜色
						zbTreeSetting.fontCss = setFont;
						zbTreeSetting.checkable = true;
						zbTreeSetting.checkStyle="checkbox";
						
						zbLayerTree=$("#zbTreeDemo").zTree(zbTreeSetting, zNodes2);
						$("#selZbLayerbar").css({"display":"block"});
						var zblayers=$("#zbLayerField").val();
						var lays = zblayers.split(";");
						for(var i=0;i<lays.length;i++){
							var node=zbLayerTree.getNodeByParam("id",lays[i]);
							if(node==null){
								continue;
							}
							var checkObj = $("#" + node.tId + "_check");
							checkObj.trigger("click"); 
						}
			        } else {
			           //所有的验证都失败
			         alert("HTTP error "+xmlreq.status+": "+xmlreq.statusText);
			       }
			     }
			};
			//发送请求
			xmlreq.send(null);
			
		}
		//周边查询div操作
		function zbSel(){
			var IDs="";
			var treeNode = zbLayerTree.getCheckedNodes();
			for (x in treeNode) {
				if (treeNode[x].check_True_Full && !(treeNode.isParent && 
					(treeNode.nodes || treeNode.nodes.length != 0))&&treeNode[x].isLayer==1) {
					IDs+=treeNode[x].id+";";
				}
			}
			if(IDs.length>0){
				IDs=IDs.substring(0,IDs.length-1)
			}
			$("#zbLayerField").val(IDs);
			$("#selZbLayerbar").css({"display":"none"});
		}
		
		function hideZb(){
			$("#selZbLayerbar").css({"display":"none"});
			//$("#selZbLayerbar").style.display="none";
		}
		function isZb(){
			if($("input[name='zbField'][checked]").val()=="1"){
				document.getElementById("zbSelBtn").disabled = false;
			}else{
				document.getElementById("zbSelBtn").disabled = true;
			}
		}
		
		//表单信息验证
		function checkInformation(){
	//			return true;
//			$(".Validform_checktip").each(function(i){
//				console.log($(this).val());
//			});
		
//		$("#addLayerForm").Validform({
//				tiptype : function(msg, o, cssctl) {
//					//msg：提示信息;
//					//o:{obj:*,type:*,curform:*}, obj指向的是当前验证的表单元素（或表单对象），type指示提示的状态，值为1、2、3、4， 1：正在检测/提交数据，2：通过验证，3：验证失败，4：提示ignore状态, curform为当前form对象;
//					//cssctl:内置的提示信息样式控制函数，该函数需传入两个参数：显示提示信息的对象 和 当前提示的状态（既形参o中的type）;
//					if (!o.obj.is("form")) {//验证表单元素时o.obj为该表单元素，全部验证通过提交表单时o.obj为该表单对象;
//						var objtip = o.obj.siblings(".Validform_checktip");
//						cssctl(objtip, o.type);
//						objtip.text(msg);
//					}
//				}
//			});
			return true;
	}
	
	// 复选框内容
		function getFields(){
			var fields = document.getElementsByName("showFields");
			var layerFields = "";
			var checked = false;
			if(fields.length>0){
				for(i=0;i<fields.length;i++){
					if(!fields[i].checked)
						continue;
					layerFields += fields[i].value +";";
					checked = true;
				}
			}
			if(layerFields.length>0){
				layerFields = layerFields.substr(0,layerFields.length-1);
			}
			if(checked){
				return layerFields;
			}else{
				return null;
			}
		}
	
	// 表单重置 formReset
		function formReset(){
			$("#parentNode").val("");
			$("#treenodeName").val("");
			//图层
			$("#layerSelect").val("0");
			//加载相应字段
			changeFieldSelect();
			//关联实时数据
			//$("#isLink").val("no");
			$("input[name='isLink'][value='no']").attr("checked","yes");
			$("#ssTable").val("");
			$("#ssField").val("");
			//$("#zbField").val("0");
			$("input[name='zbField'][value='0']").attr("checked","yes");
			$("#zbLayerField").val("");
    		//$("#pmtField").val("0");
    		$("input[name='pmtField'][value='0']").attr("checked","yes");
    		$("#layerType").val("1");
    		$("#actualLayerFields").val("");
    		$("#actualTitle").val("");
    		$("#actualValue").val("");
    		$("#showField").html("");
    		$("input[name='isLayer'][value='no']").attr("checked","no");
    		$("#layerTypeContent").hide();
		}
		
		
</script>
	</head>
	<body>
		<div class="selZbLayerbar" id="selZbLayerbar"
			style="position: absolute; display:none; align: center; z-index: 900; background-color:  #d7eef6; border: 1px solid #bbe4fa; text-align: center;">
			<ul id="zbTreeDemo" class="tree"></ul>
			<div style="align: center">
				<input type="button" value="确定" onclick="zbSel()" />
				<input type="button" value="取消" onclick="hideZb()" />
			</div>
		</div>
		<div id="cgsjImageManageDiv" class="cgsjImageManageDiv"
			style="position: absolute; display: none; align: center; z-index: 901; background-color: #d7eef6; border:1px double #A6B8C8; text-align: center;">
		</div>
		<div id="leftdiv"
			style="background-color: #f2fafc; float: left; width: 20%; margin: 0 10px 0 10px; position: relative;">
			<ul id="treeDemo" class="tree"></ul>
			<div
				style="position: absolute; bottom: 10px; left: 10px; height: 24px;">
				<input type="button" value="增加" onclick="loadNode('add')" />
				<input type="button" value="删除" onclick="deleteNode()" />
				<input type="button" value="编辑" onclick="loadNode('update')" />
			</div>
		</div>
		<div id="rightdiv" style="width: 76%; background-color: #f2fafc;float: left;">
			<form id="addLayerForm" action="">
				<div id="baseinfo" style="height: 250px;display: block;">
					<p>
						<label class="leftlable">父节点:	</label>
						<input type="text" value="" id="parentNode" class="valuelabel" disabled="disabled" />
					</p>
					<p >
						<label class="leftlable">
							节点名称:
						</label>
						<input type="text" value="" id="treenodeName" name="treenodeName" />
						<label class="Validform_checktip"> </label>
					</p>
					<p >
						<label class="leftlable">
							是否是图层:
						</label>
						<input type="radio" name="isLayer" id="isLayerTrue" class="valuelabel"
							onclick="isLayerChange()" value="yes" disabled="disabled" />是
						<input type="radio" name="isLayer" onclick="isLayerChange()"
							id="isLayerFalse" value="no" checked="checked"
							disabled="disabled" />否
					</p>
					<p >
						<label class="leftlable">
							选择图层:
						</label>
						<select class="valuelabel" id="layerSelect" datatype="*"
							 onchange="changeFieldSelect()"
							disabled="disabled">
						</select>
						<label class="Validform_checktip"></label>
					</p>
					<p >
						<label class="leftlable">
							查询字段:
						</label>
						<select class="valuelabel" id="fieldSelect" datatype="*"
							 disabled="disabled">
							<option value="">请选择查询字段</option>
						</select>
						<label class="Validform_checktip"></label>
					</p>
					<div style="height: 28px;width: 100%;margin: 0px;">
						<label class="leftlable">
							显示字段:
						</label>
						<div id="showField" style="width: 400px;float: left;"></div>
					</div>
					<p >
						<label class="leftlable">
							周边查询::
						</label>
						<input type="radio" class="valuelabel" name="zbField" onclick="isZb(this)"
							id="isZbTrue" value="1" disabled="disabled" />
						是&nbsp;&nbsp;&nbsp;
						<input type="radio" name="zbField" checked="checked"
							id="isZbFalse" onclick="isZb(this)" value="0" disabled="disabled" />
						否
					
					</p>
					<p >
						<label class="leftlable">
							周边查询图层:
						</label>
						<input type="text" id="zbLayerField" value="" class="valuelabel"
							disabled="disabled" />
						<input id="zbSelBtn" type="button" value="选择" disabled="disabled"
							onclick="loadZbTree()" />
					
					</p>
					<p >
						<label class="leftlable">
							图层类型:
						</label>
						<select id="layertype" class="valuelabel" id="layerType"
							onchange="layerTypeChange()" disabled="disabled">
							<option value="1">
								业务图层
							</option>
							<option value="actual">
								传感数据
							</option>
							<option value="camera">
								视频图像
							</option>
						</select>
					</p>
				</div>
				<!--		业务图层配置div								-->
				<div id="layerTypeContent"
					style="height: 220; width: 100%; overflow-y: scroll; OVERFLOW-x: none; margin: 0px;display:none;">
					<p >
						<label class="leftlable">
							是否关联平面图:
						</label>
						<input class="valuelabel" type="radio" name="pmtField" value="1" 
							id="isPmtTrue" />
						<label >
							是
						</label>
						<input  type="radio" name="pmtField"
							checked="checked" id="isPmtFalse" value="0" />
						<label class="otherlabel">
							否
						</label>
					</p>
					<p >
						<label class="leftlable">
							是否关联实时数据:
						</label>
						<input class="valuelabel" type="radio" name="isLink" value="yes"
							onclick="isLinkChange()" id="isLinkTrue" />
						<label class="otherlabel">
							是
						</label>
						<input class="radiocss" type="radio" name="isLink"
							checked="checked" value="no" onclick="isLinkChange()"
							id="isLinkFalse" />
						<label class="otherlabel">
							否
						</label>
					</p>
					<p >
						<label class="leftlable">
							本表关联字段:
						</label>
						<input type="text" id="userField" value="" class="valuelabel"
							  disabled="disabled">
						<label class="Validform_checktip"></label>
					</p>
					<p >
						<label class="leftlable">
							设备表名:
						</label>
						<input type="text" id="sbtable" value="" class="valuelabel" 
							disabled="disabled"  >
						<label class="Validform_checktip"></label> 
					
					</p>
					<p >
						<label class="leftlable">
							设备表关联字段:
						</label>
						<input type="text" id="sbField" value="" class="valuelabel"
							disabled="disabled"  >
						<label class="Validform_checktip"></label> 
							
					</p>
					<p >
						<label class="leftlable">
							实时数据表名称:
						</label>
						<input type="text" id="ssTable" value="" class="valuelabel"
							disabled="disabled" >
						<label class="Validform_checktip"></label>
					</p>
					<p >
						<label class="leftlable">
							实时表关联字段:
						</label>
						<input type="text" id="ssField" value="" class="valuelabel"
							disabled="disabled" >
						<label class="Validform_checktip"></label>
					</p>
					<p >
						<label class="leftlable">
							实时数据字段:
						</label>
						<input type="text" id="actualValue" value="" class="valuelabel"
							disabled="disabled"  >
						<label class="Validform_checktip"></label>
					</p>
					<p >
						<label class="leftlable">
							实时数据刷新时间:
						</label>
						<input type="text" id="refreshTime" value="5000"
							class="valuelabel" disabled="disabled"  >
						<label style="position: relative; top: 6px; left: 0px;">
							(单位：毫秒)
						</label>
						<label class="Validform_checktip"></label>
					</p>
					<p >
						<label class="leftlable">
							历史展示:
						</label>
						<input class="valuelabel" type="radio" name="isHistory" value="1" />
						<label class="otherlabel">
							是
						</label>
						<input class="radiocss" type="radio" name="isHistory"
							checked="checked" value="0" />
						<label class="otherlabel">
							否
						</label>
					</p>
					<div>
						<label class="leftlable" >
							图标:
						</label>
						<iframe id="fileuploadiframe" src='backstage/markerupload.jsp'
							style="width: 300px; float: left; height: 26px;margin-left: 10px;" frameborder='0'
							scrolling='no'  >
						</iframe>
						<div id="tubiaodiv"
						style="float: left; display: none; padding-top: 4px;margin-left: 10px;">
						<img id="tubiao" src=""
							style="width: 25px; height: 25px; float: left;" />
						<input type="button" value="更改" style="float: left;"
							onclick="changetubiao()" />
						</div>
					</div>
				</div>
				<div id="layerTypeActual"
					style="height: 245; width: 100%; overflow-y: scroll; OVERFLOW-x: none; display: none;">
					<p >
						<label class="leftlable">
							实时数据表名:
						</label>
						<input type="text" id="ssTable" value="" class="labelvalue"
							disabled="disabled">
					</p>
					<p >
						<label class="leftlable">
							本表关联字段:
						</label>
						<input type="text" id="userField" value="" class="labelvalue"
							disabled="disabled">
					</p>
					<p >
						<label class="leftlable">
							实时表关联字段:
						</label>
						<input type="text" id="ssField" value="" class="labelvalue"
							disabled="disabled" />
					</p>
					<p >
						<label class="leftlable">
							实时数据字段:
						</label>
						<input type="text" id="actualValue" value="" class="labelvalue"
							disabled="disabled" />
					</p>
					<p >
						<label class="leftlable">
							实时表显示字段:
						</label>
						<input type="text" id="actualLayerFields" value=""
							class="labelvalue" disabled="disabled" />
					</p>
					<p >
						<label class="leftlable">
							实时表标题:
						</label>
						<input type="text" id="actualTitle" value="" class="labelvalue"
							disabled="disabled" />
					</p>
					<p >
						<label class="leftlable">
							传感数据刷新时间:
						</label>
						<input type="text" id="refreshTime" value="5000"
							class="labelvalue" disabled="disabled" />
						<label style="position: relative; top: 6px; left: 0px;">
							(单位：毫秒)
						</label>
					</p>
					<p >
						<label class="leftlable">
							历史展示:
						</label>
						<input class="radiocss" type="radio" name="isHistory" value="1" />
						<label class="otherlabel">
							是
						</label>
						<input class="radiocss" type="radio" name="isHistory"
							checked="checked" value="0" />
						<label class="otherlabel">
							否
						</label>
					</p>
					<p >
						<label class="leftlable">
							传感数据图片维护:
						</label>
						<textarea rows="3" id="cgsjRuleArea" cols="40" name="ff" >{iconRefresh:false}</textarea>
						<input id="cgsjBtn" type="button" value="管理"
							onclick="showImageManage()" />
					</p>
				</div>
				<div id="layerTypeCamera"
					style="height: 245; width: 100%; overflow-y: scroll; OVERFLOW-x: none; display: none;">
					<p >
						<label class="leftlable">
							设备id字段:
						</label>
						<input type="text" id="sbidfield" value="" class="labelvalue"
							disabled="disabled">
					</p>
				</div>
				<div id ="savediv" >
					<input type="button" value="保存" id="saveBut" />
					<input type="button" value="取消" id="cancelBut" onclick="formReset()" />
				</div>
			</form>
		</div>
		</div>
	</body>
</html>
