<?php
$url = $_REQUEST['url'];
$like = '&like='.$_REQUEST['like'];
$page = '&page='.$_REQUEST['page'];
$url = $url.$like.$page;
$contents = file_get_contents($url);
echo $contents;
// echo $like;
// echo $page;