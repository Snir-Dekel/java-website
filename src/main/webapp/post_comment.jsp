<%@ page import="com.example.final_website.Functions" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.Connection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("token")) {
                request.setAttribute("code", cookie.getValue());
            }
        }
    }
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("admin_code") && Functions.is_user_admin(cookie.getValue(), response)) {
                Functions.update_and_set_admin_code(response);
                request.setAttribute("admin_code", cookie.getValue());
            }
        }
    }
%>

<c:if test="${code!=null}">

    <sql:setDataSource var="db" driver="com.mysql.cj.jdbc.Driver" url="jdbc:mysql://localhost:3306/login_website"
                       user="USER" password="YOUR_PASSWORD"/>
    <sql:query var="result"
               dataSource="${db}">SELECT user_name, verification_code, token, email FROM users WHERE token = ? AND is_verified='1';<sql:param
            value='${code}'/></sql:query>
    <c:forEach var="row" items="${result.rows}">
        <c:set var="username" value="${row.user_name}" scope="request"/>
        <c:set var="email" value="${row.email}" scope="request"/>
        <c:set var="verificationCode" value="${row.verification_code}" scope="request"/>
        <c:set var="token" value="${row.token}" scope="request"/>
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
                String sql_query = "SELECT ip FROM ip_email WHERE email=? ORDER BY TIME DESC LIMIT 1";//most recent
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
                request.setAttribute("token", new_token);
                response.addCookie(token_cookie);
            }
            request.setAttribute("is_ip_valid", is_ip_valid);
        %>
        <c:if test="${is_ip_valid=='0'}">
            <%
                Functions.ip_not_valid(request, response);
            %>
        </c:if>


    </c:when>
    <c:otherwise>
        <% response.sendRedirect("login.jsp");
            request.setAttribute("return", "return");%>

    </c:otherwise>
</c:choose>
<% if (request.getAttribute("return") != null) {
    return;
}%>
<html>
<head>
    <title>● Post Comment</title>
    <link rel="icon" type="image/png" href="logo.png">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css"
          integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous"/>
    <link rel="stylesheet" href="styles/standup_animation.css"/>
    <link rel="stylesheet" href="styles/navbar_standup.css"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">

    <link rel="stylesheet" href="styles/post_comment.css">
    <script>
      function on_delete_account_button() {
        $("#delete_account_modal").modal({
          backdrop: 'static',
          keyboard: false
        });
      }
    </script>
</head>

<body>

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
                <c:if test="${admin_code!=null}">
                    <li class="nav-item">
                        <a class="nav-link" href="admin.jsp">Admin Panel <i class="fa-solid fa-user-gear"></i></a>
                    </li>
                </c:if>

            </ul>
        </div>
    </nav>


    <div class="center" style="margin: auto;width: 50%;">
        <h1 class="text-primary" id="post_comment_h1">Post comment to comment section</h1>
        <form onsubmit="return false">

            <br/>

            <div class="form-group">
                           <textarea id="textarea" class="form-control bg-dark" name="comment"
                                     placeholder="Write comment"
                                     maxlength="300" dir=auto
                                     oninput="update_chars_left()" autofocus></textarea>
                <span id="count_message"><span id="current"
                >0 </span> <span id="maximum"> / 300</span>
            </div>
            <br/>
            <br/>


            <button class="btn btn-primary btn-lg btn-rounded" id="post_comment_button" type="submit"
                    onclick="postComment()">
                <span id="post_comment_text_span">Post comment</span><span id="loading_span"
                                                                           style="margin-right:0.7rem"></span>
            </button>


            <label id="label_time_left" for="progress_bar" style="
    display: block;
    margin: 2rem auto auto;
    text-align: center;
    color: #06c306;
    font-size: 200%;
">Your comment has been successfully posted! <br> You can post again in <span id="time_left">10</span> seconds</label>
            <label id="label_can_post" for="progress_bar" style="
    display: block;
    margin: 2rem auto auto;
    text-align: center;
    color: #06c306;
    font-size: 200%;
">You can post again now!</label>
            <br>
            <br>
            <div style="height: 2rem;background: #212529;border:solid 1px #ffffff69" id="progress_bar_parent">
                <div id="progress_bar" class="progress-bar progress-bar-striped test progress-bar-animated"
                     role="progressbar"
                     style="width: 100%;font-size: 1.8rem;border-radius: 0.3rem"
                     aria-valuenow="100"
                     aria-valuemin="0" aria-valuemax="100">
                </div>
            </div>


        </form>

    </div>


    <div class="modal fade" id="min_length_comment">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Minimum comment length is 4 characters.</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">To keep the comment section free of
                        spam, your comments must be 4 to 300 characters long.
                    </p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69);"
                     class="modal-footer">
                    <button type="button" class="btn btn-primary no-standup" data-dismiss="modal">Close</button>


                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="comments_cooldown">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">You are posting comments too often, please wait a
                        while.</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">To keep the comment section free of
                        spam, we limited the amount of comments you can post.</p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69);"
                     class="modal-footer">
                    <button type="button" class="btn btn-primary no-standup" data-dismiss="modal">Close</button>


                </div>
            </div>
        </div>
    </div>


    <script>
      document.getElementById("progress_bar").style.display = "none";
      document.getElementById("progress_bar_parent").style.display = "none";
      document.querySelector('#label_time_left').style.display = "none"
      document.querySelector('#label_can_post').style.display = "none"

      async function postComment() {
        let button = document.getElementById("post_comment_button")
        let comment_element = document.querySelector("textarea")
        if (comment_element.value.length < 4) {
          $("#min_length_comment").modal()
          return
        }
        let cooldown = false
        button.disabled = true
        document.getElementById("post_comment_text_span").style.display = "none"
        let span_loading = document.getElementById("loading_span")
        span_loading.classList.toggle("spinner-border")

        await new Promise((r) => setTimeout(r, Math.floor(Math.random() * 500) + 1000))
        $.ajax({
          type: "post",
          url: "https://${pageContext.request.serverName}/comments-cooldown?username=" +
              encodeURIComponent('<c:out value='${username}'/>'),
          dataType: "html",
          async: false,
          success: function(response) {
            console.log(response)
            if (response === "yes") {
              cooldown = true
            }
          }
        })

        if (cooldown) {
          document.getElementById("post_comment_text_span").style.display = "inline"
          span_loading.classList.toggle("spinner-border")
          $("#comments_cooldown").modal({
            backdrop: 'static',
            keyboard: false,
          })
          return;
        }

        document.getElementById("current").innerHTML = "0 "
        document.querySelector('#time_left').innerHTML = "10"

        $.post("https://${pageContext.request.serverName}/post-comment?comment=" +
            encodeURIComponent(document.querySelector("textarea").value) +
            "&token=" + '${token}' + "&username=" +
            encodeURIComponent(`<c:out value='${username}'/>`))
        comment_element.value = ""
        document.getElementById("current").style.color = "white";
        document.getElementById("maximum").style.color = "white";
        document.getElementById("maximum").style.fontWeight = "normal";
        document.getElementById("current").style.fontWeight = "normal";
        document.getElementById("progress_bar").style.display = "flex";
        document.getElementById("progress_bar_parent").style.display = "flex";
        document.getElementById("progress_bar_parent").classList.add("progress");
        document.getElementById('label_time_left').style.display = "block"
        document.getElementById("label_can_post").style.display = "none"
        let elem = document.getElementById("progress_bar")
        elem.style.width = "100%"
        let width = 100
        let id = setInterval(function() {

          document.getElementById("time_left").innerHTML = Math.ceil(width / 10)

          if (width === 0) {
            elem.style.display = "none";
            document.getElementById('label_time_left').style.display = "none"
            document.getElementById("label_can_post").style.display = "block"
            document.getElementById("progress_bar_parent").style.display = "none"
            document.getElementById("progress_bar_parent").classList.remove("progress");
            console.log("width is 0")
            button.disabled = false
            clearInterval(id)
          }
          else {
            width--
            elem.style.width = width + '%'
          }
        }, 100);

        document.getElementById("post_comment_text_span").style.display = "inline"
        span_loading.classList.toggle("spinner-border")

      }

      function update_chars_left() {
        document.getElementById("current").innerHTML = document.querySelector("textarea").value.length + " "
        if ((document.querySelector("textarea").value.length < 120)) {
          document.getElementById("current").style.color = "white";
          document.getElementById("maximum").style.color = "white";
          document.getElementById("maximum").style.fontWeight = "normal";
          document.getElementById("current").style.fontWeight = "normal";
        }
        if (document.getElementById("current").innerHTML.length === 2) {
          document.getElementById("current").style.color = "white";
          document.getElementById("maximum").style.color = "white";
          document.getElementById("maximum").style.fontWeight = "normal";
          document.getElementById("current").style.fontWeight = "normal";
        }
        if (document.getElementById("current").innerHTML.length > 2 &&
            document.getElementById("current").innerHTML.length < 4) {
        }
        else if (document.getElementById("current").innerHTML.length >= 4) {
        }
        if (document.querySelector("textarea").value.length >= 120 && document.querySelector("textarea").value.length <=
            200) {
          document.getElementById("current").style.color = "yellow"
          document.getElementById("maximum").style.color = "yellow"
          document.getElementById("maximum").style.fontWeight = "normal"
          document.getElementById("current").style.fontWeight = "normal"
        }
        else if (document.querySelector("textarea").value.length > 200 &&
            document.querySelector("textarea").value.length <= 250) {
          document.getElementById("current").style.color = "#FF213F"
          document.getElementById("maximum").style.color = "#FF213F"
          document.getElementById("maximum").style.fontWeight = "normal"
          document.getElementById("current").style.fontWeight = "normal"
        }
        else if (document.querySelector("textarea").value.length >= 250) {
          document.getElementById("current").style.color = "#FF213F"
          document.getElementById("maximum").style.color = "#FF213F"
          document.getElementById("maximum").style.fontWeight = "bold"
          document.getElementById("current").style.fontWeight = "bold"

        }
      }
    </script>
    <%@include file="delete_account_modal.jsp" %>

</body>
</html>
