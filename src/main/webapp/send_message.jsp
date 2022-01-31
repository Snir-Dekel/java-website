<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.example.final_website.Functions" %>
<%@ page import="java.sql.Connection" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c-rt" %>

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
            request.setAttribute("redirected", "redirected");
            System.out.println("redirected");
        %>

    </c:otherwise>
</c:choose>
<% if (request.getAttribute("redirected") != null) {
    return;
}%>
<% if (request.getParameter("to_user") == null) {
    System.out.println("request.getParameter(to_user)==null)");
    response.sendRedirect("login.jsp");
    return;
}%>

<%
    String is_user_valid = "0";
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";
    System.out.println("to_user: " + request.getParameter("to_user"));

    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;

    try {
        String sql_query = "SELECT user_name FROM users WHERE user_name=?";
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(url, sql_user, sql_pass);
        preparedStatement = connection.prepareStatement(sql_query);
        preparedStatement.setString(1, request.getParameter("to_user"));
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            is_user_valid = "1";
        }
    }
    catch (Exception e) {
        e.printStackTrace();
        is_user_valid = "1";
    }
    finally {
        Functions.close_sql_connection(connection, preparedStatement, resultSet);
    }

    if (!is_user_valid.equals("1")) {
        response.sendRedirect("login.jsp");
        System.out.println("username is invalid");
        return;
    }
%>

<html>
<head>
    <title>● Send message</title>
    <link rel="stylesheet" href="styles/standup_animation.css"/>
    <link rel="icon" type="image/png" href="logo.png">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css"
          integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous"/>
    <link rel="stylesheet" href="styles/navbar_standup.css"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">

    <link rel="stylesheet" href="styles/send_message.css">
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
                <c:if test="${admin_code!=null}">
                    <li class="nav-item">
                        <a class="nav-link" href="admin.jsp">Admin Panel <i class="fa-solid fa-user-gear"></i></a>
                    </li>
                </c:if>

            </ul>
        </div>
    </nav>


    <div class="center" style="margin: auto;width: 50%;">
        <h1 class="text-primary" id="send_message_h1">Send private message to <span
                style="margin-left: -1px;color: rgb(13,201,253)"><c-rt:out
                value="${param.to_user}"/></span></h1>
        <form onsubmit="return false">

            <br/>

            <div class="form-group">
                           <textarea id="textarea" class="form-control bg-dark" name="comment"
                                     placeholder="Write message"
                                     maxlength="300" dir=auto
                                     oninput="update_chars_left()" autofocus></textarea>
                <span id="count_message"><span id="current"
                >0 </span> <span id="maximum"> / 300</span>
            </div>
            <br/>
            <br/>


            <button class="btn btn-primary btn-lg btn-rounded" id="send_message_button" type="submit"
                    onclick="send_message()">
                <span id="send_message_text_span">Send message</span><span id="loading_span"
                                                                           style="margin-right:0.7rem"></span>
            </button>


            <label id="label_time_left" for="progress_bar" style="
    display: block;
    margin: 2rem auto auto;
    text-align: center;
    color: #06c306;
    font-size: 200%;
">Your message has been successfully sent! <br> You can send again in <span id="time_left">10</span> seconds</label>
            <label id="label_can_post" for="progress_bar" style="
    display: block;
    margin: 2rem auto auto;
    text-align: center;
    color: #06c306;
    font-size: 200%;
">You can send again now!</label>
            <br>
            <br>
            <div style="width: 59rem;height: 2rem;background: #212529;border:solid 1px #ffffff69"
                 id="progress_bar_parent">
                <div id="progress_bar" class="progress-bar progress-bar-striped test progress-bar-animated"
                     role="progressbar"
                     style="width: 100%;font-size: 1.8rem;border-radius: 0.3rem"
                     aria-valuenow="100"
                     aria-valuemin="0" aria-valuemax="100">
                </div>
            </div>


        </form>

    </div>


    <script>
      document.getElementById("progress_bar").style.display = "none";
      document.getElementById("progress_bar_parent").style.display = "none";
      document.querySelector('#label_time_left').style.display = "none"
      document.querySelector('#label_can_post').style.display = "none"

      function htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
      }

      async function send_message() {
        let button = document.getElementById("send_message_button")
        let comment_element = document.querySelector("textarea")
        if (comment_element.value.length < 4) {
          $("#min_length_message").modal()
          return
        }
        button.disabled = true
        let cooldown = ""
        document.getElementById("send_message_text_span").style.display = "none"
        let span_loading = document.getElementById("loading_span")
        span_loading.classList.toggle("spinner-border")

        await new Promise((r) => setTimeout(r, Math.floor(Math.random() * 500) + 1000))
        $.ajax({
          type: "post",
          url: "https://${pageContext.request.serverName}/messages-cooldown?username=" +
              encodeURIComponent(htmlDecode('<c:out value='${username}'/>')) + "&to_user=" +
              encodeURIComponent(htmlDecode(`<c-rt:out value="${param.to_user}"/>`)),
          dataType: "html",
          async: false,
          success: function(response) {
            cooldown = response
          }
        })

        if (cooldown === "yes") {
          document.getElementById("send_message_text_span").style.display = "inline"
          span_loading.classList.toggle("spinner-border")
          $("#messages_cooldown").modal({
            backdrop: 'static',
            keyboard: false,
          })
          return;
        }
        else if (cooldown === "blocked") {
          document.getElementById("send_message_text_span").style.display = "inline"
          span_loading.classList.toggle("spinner-border")
          $("#user_blocked").modal({
            backdrop: 'static',
            keyboard: false,
          })
          return;
        }

        document.getElementById("current").innerHTML = "0 "
        document.querySelector('#time_left').innerHTML = "10"

        $.post("https://${pageContext.request.serverName}/send-message?message=" +
            encodeURIComponent(document.querySelector("textarea").value) +
            "&token=" + '${token}' + "&from_user=" +
            encodeURIComponent(htmlDecode(`<c:out value='${username}'/>`)) + "&to_user=" +
            encodeURIComponent(htmlDecode(`<c-rt:out value="${param.to_user}"/>`)))

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

        document.getElementById("send_message_text_span").style.display = "inline"
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
    <div class="modal fade" id="user_blocked">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Sending Failed</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">Sorry, you can't send messages to
                        <c-rt:out value="${param.to_user}"/> because he blocked you.
                    </p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69);display: flex;justify-content: space-between;"
                     class="modal-footer">
                    <button type="button" class="btn btn-secondary no-standup" data-dismiss="modal">Close</button>
                    <button onclick="window.location.href = 'comment_section.jsp'" type="button"
                            class="btn btn-primary no-standup" data-dismiss="modal">Back to comment section
                    </button>


                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="messages_cooldown">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">You are sending messages too often, please wait a
                        while.</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">To keep the inbox of <c-rt:out
                            value="${param.to_user}"/> free of
                        spam, we limited the amount of messages you can send.</p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69);display: flex;justify-content: space-between;"
                     class="modal-footer">
                    <button type="button" class="btn btn-secondary no-standup" data-dismiss="modal">Close</button>
                    <button onclick="window.location.href = 'comment_section.jsp'" type="button"
                            class="btn btn-primary no-standup" data-dismiss="modal">Back to comment section
                    </button>


                </div>
            </div>
        </div>
    </div>


    <div class="modal fade" id="min_length_message">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Minimum message length is 4 characters.</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">To keep the inbox of <c-rt:out
                            value="${param.to_user}"/> free of
                        spam, your messages must be 4 to 300 characters long.
                    </p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69);"
                     class="modal-footer">
                    <button type="button" class="btn btn-primary no-standup" data-dismiss="modal">Close</button>


                </div>
            </div>
        </div>
    </div>
    <%@include file="delete_account_modal.jsp" %>

</body>
</html>
