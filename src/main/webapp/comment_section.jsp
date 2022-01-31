<%@ page import="com.example.final_website.Functions" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.ocpsoft.prettytime.PrettyTime" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="org.ocpsoft.prettytime.units.JustNow" %>
<%@ page import="org.ocpsoft.prettytime.TimeUnit" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("token")) {
                request.setAttribute("code", cookie.getValue());
            }
        }
    }
%>

<c:if test="${code!=null}">

    <sql:setDataSource var="db" driver="com.mysql.cj.jdbc.Driver" url="jdbc:mysql://localhost:3306/login_website"
                       user="USER" password="YOUR_PASSWORD"/>
    <sql:query var="result"
               dataSource="${db}">SELECT user_name, email FROM users WHERE token = ? AND is_verified='1';<sql:param
            value='${code}'/></sql:query>
    <c:forEach var="row" items="${result.rows}">
        <c:set var="username" value="${row.user_name}" scope="request"/>
        <c:set var="email" value="${row.email}" scope="request"/>
    </c:forEach>
</c:if>
<c:if test="${username!=null}">

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
        else {
            Functions.ip_not_valid(request, response);
            return;
        }
    %>
</c:if>

<%
    String code = "";
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("admin_code") && Functions.is_user_admin(cookie.getValue(), response)) {
                Functions.update_and_set_admin_code(response);
                request.setAttribute("admin_code", cookie.getValue());
            }
        }
    }
%>
<html>
<head>
    <title>● Comment Section</title>
    <link rel="icon" type="image/png" href="logo.png">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="styles/svg_animation.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <script src="https://unpkg.com/scroll-out/dist/scroll-out.min.js"></script>


    <style>
        :root {
            color-scheme: dark;
        }

    </style>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">

    <link rel="stylesheet" href="styles/comment_section.css">
</head>
<body>


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
                    <a class="nav-link" href="/">Home <i class="fa-solid fa-house"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="post_comment.jsp">Write Comment <i class="fa fa-edit"></i></a>
                </li>
                <c:choose>
                    <c:when test="${username!=null}">
                        <li class="nav-item">
                            <a class="nav-link" href="javascript:void(0)"
                               onclick="window.location.replace('logout?token=' + encodeURIComponent(`${code}`));">Logout
                                <i class="fa-solid fa-right-from-bracket"></i></a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="javascript:void(0)"
                               onclick="on_delete_account_button()">Delete Account <i class="fa-solid fa-trash-can"></i></a>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link" target="_blank" href="restore_account.jsp">Restore Account <i
                                    class="fa-solid fa-trash-arrow-up"></i></a>
                        </li>
                    </c:otherwise>
                </c:choose>
                <li class="nav-item">
                    <a class="nav-link" target="_blank" href="https://github.com/Snir-Dekel">Snir's GitHub <i
                            class="fa-brands fa-github"></i></a>
                </li>
                <c:if test="${admin_code!=null}">
                    <li class="nav-item">
                        <a class="nav-link" href="admin.jsp">Admin Panel <i class="fa-solid fa-user-gear"></i></a>
                    </li>
                </c:if>

            </ul>
        </div>
    </nav>

    <sql:setDataSource var="db" driver="com.mysql.cj.jdbc.Driver" url="jdbc:mysql://localhost:3306/login_website"
                       user="USER" password="YOUR_PASSWORD"/>
    <sql:query var="result"
               dataSource="${db}">SELECT *,DATE_FORMAT(time, '%d/%m/%Y') as 'date', TIME_FORMAT(time, '%H:%i') as 'my_date', DATE_FORMAT(time, '%S/%i/%H/%e/%c/%Y') as 'full_date' FROM comments_email ORDER BY time DESC</sql:query>


    <c:forEach var="row" items="${result.rows}" varStatus="loop">

    <sql:query var="result3"
               dataSource="${db}">SELECT profile_picture_name FROM users WHERE user_name=?<sql:param
            value='${row.username}'/></sql:query>


    <c:forEach var="row3" items="${result3.rows}">
        <c:set var="profile_picture_name" value="${row3.profile_picture_name}"/>
    </c:forEach>

    <c:choose>
    <c:when test="${loop.index==0}">
    <div class="container mt-5" style="margin-top: -45px" id="div_${loop.index}">
        </c:when>
        <c:when test="${fn:length(result.rows)==loop.index+1}">
        <div class="container mt-5" style="padding-bottom: 45px" id="div_${loop.index}">

            </c:when>
            <c:otherwise>
            <div class="container mt-5" id="div_${loop.index}">
                </c:otherwise>
                </c:choose>
                <div class="row d-flex justify-content-center">
                    <div class="col-md-12">
                        <div class="card p-3">
                            <div class="d-flex justify-content-between align-items-center">
                                <div data-scroll style="font-size:130%; width: 57rem;"
                                     class="user d-flex flex-row align-items-lg-start"><img style="height: 3rem"
                                                                                            src="profile-pictures?id=${profile_picture_name}"
                                                                                            width="45"
                                                                                            class="user-img  mr-2"
                                                                                            alt="profile_picture">
                                    <span><small
                                            class="font-weight-bold text-primary"><c:out
                                            value='${row.username}'/></small>         <c:if test="${row.is_admin=='1'}">
                                        <span style="color: rgb(255 238 36);font-weight: bold"> (Website Admin)</span>
                                    </c:if> <br><small class="font-weight-bold"
                                                       style="overflow-wrap: anywhere;font-size: 100%"><c:out
                                            value='${row.comment}'/></small></span></div>
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
                                        request.setAttribute("comment_date", "moments ago");
                                    }
                                    else {
                                        request.setAttribute("comment_date", p.format(dateObject));
                                    }

                                %>
                                <small data-toggle="tooltip" data-placement="top" title="${row.my_date}, ${(row.date)}"
                                       data-scroll class="date">${comment_date}</small>
                            </div>
                            <div class="action d-flex mt-1" style="justify-content: flex-end; user-select: none">

                                <c:choose>
                                    <c:when test="${(admin_code!=null) and (fn:escapeXml(username)!=row.username) and (username!=null)}">
                                        <button data-scroll
                                                onclick="redirect_to_message(`<c:out value='${row.username}'/>`)"
                                                type="button" style="position: relative;margin-top: 0.6rem"
                                                class="btn btn-primary btn-sm">Send message
                                        </button>

                                    </c:when>
                                    <c:when test="${(fn:escapeXml(username)!=row.username) and (username!=null)}">
                                        <button data-scroll
                                                onclick="redirect_to_message(`<c:out value='${row.username}'/>`)"
                                                type="button"
                                                style="position: relative; margin-right: auto;margin-top: 0.6rem"
                                                class="btn btn-primary btn-sm">Send message
                                        </button>

                                    </c:when>
                                </c:choose>
                                <c:if test="${(fn:escapeXml(username)!=row.username) and (username!=null)}">

                                </c:if>
                                <c:if test="${admin_code!=null}">
                                    <button data-scroll
                                            onclick="delete_comment(`<c:out value='${row.id}'/>`, ${loop.index})"
                                            type="button"
                                            style="position: relative;margin-left: 10px; margin-right: auto;margin-top: 0.6rem"
                                            class="btn btn-danger btn-sm">Delete comment
                                    </button>

                                </c:if>
                                <div data-scroll id="likes_div">

                                    <sql:query var="result1"
                                               dataSource="${db}">SELECT count(*) as 'dislikes' FROM comment_likes WHERE id='${row.id}' and type='-1';</sql:query>
                                    <c:forEach var="row1" items="${result1.rows}">
                                        <span id="dislike_count_${loop.index}"
                                              class="dislike_count">${row1.dislikes}</span>

                                    </c:forEach>
                                    <sql:query var="result2"
                                               dataSource="${db}">SELECT COUNT(*) AS 'user_already_disliked' FROM comment_likes WHERE id=? and username=? and type='-1'<sql:param
                                            value='${row.id}'/><sql:param
                                            value='${username}'/></sql:query>

                                    <c:forEach var="row2" items="${result2.rows}">
                                        <c:choose>
                                            <c:when test="${row2.user_already_disliked==0}">
                                                <svg class="dislike_svg"
                                                     onclick="toggle_dislike(`<c:out value='${username}'/>`, `<c:out
                                                             value='${row.id}'/>`,'${code}', ${loop.index})"
                                                     id="dislike_svg_${loop.index}" width="27" height="27"
                                                     viewBox="0 0 27 27"
                                                     fill="none" xmlns="http://www.w3.org/2000/svg">
                                                    <path class="like_svg_path" id="dislike_svg_path_${loop.index}"
                                                          d="M7.03824 15.9165L14.8813 24.9581C15.6255 25.8161 16.7963 26.1849 17.9059 25.9108L17.9776 25.8931C20.0031 25.3928 20.9155 23.0606 19.7575 21.344L16.0956 15.9165H22.9798C24.885 15.9165 26.314 14.1941 25.9404 12.3482L24.1289 3.39823C23.8466 2.00376 22.6075 1 21.1683 1H7.03824M7.03824 15.9165H1V1H7.03824V15.9165ZM7.03824 15.9165V1V15.9165Z"
                                                          stroke="white" stroke-width="1.5" stroke-linecap="round"
                                                          stroke-linejoin="round" fill="transparent"></path>
                                                </svg>

                                            </c:when>
                                            <c:otherwise>
                                                <svg class="dislike_svg"
                                                     onclick="toggle_dislike(`<c:out value='${username}'/>`, `<c:out
                                                             value='${row.id}'/>`,'${code}', ${loop.index})"
                                                     id="dislike_svg_${loop.index}" width="27" height="27"
                                                     viewBox="0 0 27 27"
                                                     fill="none" xmlns="http://www.w3.org/2000/svg">
                                                    <path class="like_svg_path dislike_active"
                                                          id="dislike_svg_path_${loop.index}"
                                                          d="M7.03824 15.9165L14.8813 24.9581C15.6255 25.8161 16.7963 26.1849 17.9059 25.9108L17.9776 25.8931C20.0031 25.3928 20.9155 23.0606 19.7575 21.344L16.0956 15.9165H22.9798C24.885 15.9165 26.314 14.1941 25.9404 12.3482L24.1289 3.39823C23.8466 2.00376 22.6075 1 21.1683 1H7.03824M7.03824 15.9165H1V1H7.03824V15.9165ZM7.03824 15.9165V1V15.9165Z"
                                                          stroke="white" stroke-width="1.5" stroke-linecap="round"
                                                          stroke-linejoin="round" fill="transparent"></path>
                                                </svg>

                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>


                                    <sql:query var="result1"
                                               dataSource="${db}">SELECT count(*) as 'likes' FROM comment_likes WHERE id='${row.id}' and type ='1';</sql:query>
                                    <c:forEach var="row1" items="${result1.rows}">
                                    <span id="like_count_${loop.index}" class="like_count">${row1.likes}</span>

                                    <sql:query var="result2"
                                               dataSource="${db}">SELECT COUNT(*) AS 'user_already_liked' FROM comment_likes WHERE id=? and username=? and type='1'<sql:param
                                            value='${row.id}'/><sql:param
                                            value='${username}'/></sql:query>

                                    <c:forEach var="row2" items="${result2.rows}">
                                    <c:choose>
                                        <c:when test="${row2.user_already_liked==0}">
                                            <svg id="like_svg_${loop.index}" class="like_svg"
                                                 onclick="toggle_like(`<c:out value='${username}'/>`, `<c:out
                                                         value='${row.id}'/>`,'${code}', ${loop.index})" width="27"
                                                 height="27" viewBox="0 0 27 27" fill="none"
                                                 xmlns="http://www.w3.org/2000/svg">
                                                <path class="like_svg_path" id="like_svg_path_${loop.index}"
                                                      d="M7.03824 11.0835L14.8813 2.04189C15.6255 1.18394 16.7963 0.815112 17.9059 1.08917L17.9776 1.10691C20.0031 1.60728 20.9155 3.93941 19.7575 5.65597L16.0956 11.0835H22.9798C24.885 11.0835 26.314 12.8058 25.9404 14.6519L24.1289 23.6017C23.8466 24.9963 22.6075 26 21.1683 26H7.03824M7.03824 11.0835H1V26H7.03824V11.0835ZM7.03824 11.0835V26V11.0835Z"
                                                      stroke="white" stroke-width="1.5" stroke-linecap="round"
                                                      stroke-linejoin="round" fill="transparent"></path>
                                            </svg>
                                        </c:when>
                                        <c:otherwise>
                                            <svg id="like_svg_${loop.index}" class="like_svg"
                                                 onclick="toggle_like(`<c:out value='${username}'/>`, `<c:out
                                                         value='${row.id}'/>`,'${code}', ${loop.index})" width="27"
                                                 height="27" viewBox="0 0 27 27" fill="none"
                                                 xmlns="http://www.w3.org/2000/svg">
                                                <path class="like_svg_path like_active" id="like_svg_path_${loop.index}"
                                                      d="M7.03824 11.0835L14.8813 2.04189C15.6255 1.18394 16.7963 0.815112 17.9059 1.08917L17.9776 1.10691C20.0031 1.60728 20.9155 3.93941 19.7575 5.65597L16.0956 11.0835H22.9798C24.885 11.0835 26.314 12.8058 25.9404 14.6519L24.1289 23.6017C23.8466 24.9963 22.6075 26 21.1683 26H7.03824M7.03824 11.0835H1V26H7.03824V11.0835ZM7.03824 11.0835V26V11.0835Z"
                                                      stroke="white" stroke-width="1.5" stroke-linecap="round"
                                                      stroke-linejoin="round" fill="transparent"></path>
                                            </svg>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                </c:forEach>


                                </c:forEach>


                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        </c:forEach>
        <c:if test="${admin_code!=null}">
        <script>
          function delete_comment(comment_id, index) {
            $.post("https://${pageContext.request.serverName}/delete-comment?comment_id=" + comment_id)
            document.getElementById(`div_\${index}`).remove()

          }

        </script>

        </c:if>

        <script>
          function htmlDecode(input) {
            var doc = new DOMParser().parseFromString(input, "text/html");
            return doc.documentElement.textContent;
          }

          function toggle_like(from_user, comment_id, token, index) {
            if ('<c:out value="${username}"/>' === "") {
              window.location.replace("login.jsp");
              return
            }
            $.post("https://${pageContext.request.serverName}/toggle-like?token=" + token + "&from_user=" +
                encodeURIComponent(from_user) +
                "&comment_id=" + comment_id + "&type=1")
            if (document.getElementById(`dislike_svg_path_\${index}`).classList.contains("dislike_active")) {
              document.getElementById(`dislike_svg_path_\${index}`).classList.toggle('dislike_active')
              document.getElementById(`dislike_count_\${index}`).innerHTML = String(
                  Number(document.getElementById(`dislike_count_\${index}`).innerHTML) - 1)
            }
            if (document.getElementById(`like_svg_path_\${index}`).classList.contains('like_active')) {
              document.getElementById(`like_count_\${index}`).innerHTML = String(
                  Number(document.getElementById(`like_count_\${index}`).innerHTML) - 1)

            }
            else {
              document.getElementById(`like_count_\${index}`).innerHTML = String(
                  Number(document.getElementById(`like_count_\${index}`).innerHTML) + 1)
            }

            document.getElementById(`like_svg_path_\${index}`).classList.toggle('like_active')
            document.getElementById(`like_svg_path_\${index}`).classList.toggle('like_active_hover')

          }

          function toggle_dislike(from_user, comment_id, token, index) {
            if ('<c:out value="${username}"/>' === "") {
              window.location.replace("login.jsp");
              return
            }
            $.post("https://${pageContext.request.serverName}/toggle-like?token=" + token + "&from_user=" +
                encodeURIComponent(from_user) +
                "&comment_id=" + comment_id + "&type=-1")
            if (document.getElementById(`like_svg_path_\${index}`).classList.contains("like_active")) {
              document.getElementById(`like_svg_path_\${index}`).classList.toggle('like_active')
              document.getElementById(`like_count_\${index}`).innerHTML = String(
                  Number(document.getElementById(`like_count_\${index}`).innerHTML) - 1)
            }
            if (document.getElementById(`dislike_svg_path_\${index}`).classList.contains('dislike_active')) {
              document.getElementById(`dislike_count_\${index}`).innerHTML = String(
                  Number(document.getElementById(`dislike_count_\${index}`).innerHTML) - 1)

            }
            else {
              document.getElementById(`dislike_count_\${index}`).innerHTML = String(
                  Number(document.getElementById(`dislike_count_\${index}`).innerHTML) + 1)
            }
            document.getElementById(`dislike_svg_path_\${index}`).classList.toggle('dislike_active')
            document.getElementById(`dislike_svg_path_\${index}`).classList.toggle('dislike_active_hover')

          }

          function redirect_to_message(to_user) {
            window.location.href = "https://${pageContext.request.serverName}/send_message.jsp?to_user=" +
                encodeURIComponent(htmlDecode(to_user))
          }

        </script>
        <script>
          let cnt = 0
          while (1) {
            let like_svg = document.getElementById(`like_svg_\${cnt}`)
            let like_svg_path = document.getElementById(`like_svg_path_\${cnt}`)
            if (like_svg === null)
              break

            like_svg.addEventListener(
                "mouseenter",
                function() {
                  if (like_svg_path.classList.contains("like_active"))
                    like_svg_path.classList.add("like_active_hover")

                  else
                    like_svg_path.classList.add("like_hover")
                },
                false
            );
            like_svg.addEventListener(
                "mouseleave",
                function() {
                  like_svg_path.classList.remove("like_hover")
                  like_svg_path.classList.remove("like_active_hover")
                },
                false
            );
            cnt++
          }
          cnt = 0
          while (1) {
            let dislike_svg = document.getElementById(`dislike_svg_\${cnt}`)
            let dislike_svg_path = document.getElementById(`dislike_svg_path_\${cnt}`)
            if (dislike_svg === null)
              break

            dislike_svg.addEventListener(
                "mouseenter",
                function() {
                  if (dislike_svg_path.classList.contains("dislike_active"))
                    dislike_svg_path.classList.add("dislike_active_hover")

                  else
                    dislike_svg_path.classList.add("dislike_hover")
                },
                false
            );
            dislike_svg.addEventListener(
                "mouseleave",
                function() {
                  dislike_svg_path.classList.remove("dislike_hover")
                  dislike_svg_path.classList.remove("dislike_active_hover")
                },
                false
            );
            cnt++
          }
          $(function() {
            $('[data-toggle="tooltip"]').tooltip()
          })

          function on_delete_account_button() {
            $("#delete_account_modal").modal({
              backdrop: 'static',
              keyboard: false
            });
          }

          ScrollOut();
        </script>

        <%@include file="delete_account_modal.jsp" %>


</body>
</html>
