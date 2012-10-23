<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>jquery tab </title>
<link href="/factarjava/css/tab.css" type="text/css" rel="stylesheet">
<script type="text/javascript" src="/factarjava/js/jquery.min.js"></script>
<script type="text/javascript" src="/factarjava/js/tab.js"></script>
<script type="text/javascript">
$("#container");
 console.log();
</script>
</head>
<body>
<div id="container" class="container_style">
<div id="li_area" class="li_area_style">
    <ul id="ul_area" class="ul_area_style">
        <li class="listli">标签1</li>
        <li >标签2</li>
        <li >标签3</li>
    </ul>
</div>
<div id="tab_area" class="tab_area_style">
    <div class="content_area">标签1下内容</div>
    <div>标签2下内容</div>
    <div>标签3下内容</div>
</div>
</div>
</body>
</html>