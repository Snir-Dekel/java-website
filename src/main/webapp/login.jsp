<%@ page import="com.example.final_website.Functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%
    System.out.println("in login" + " " + Functions.getClientIp(request));
    System.out.println("User-Agent: " + request.getHeader("User-Agent"));

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
    <% response.sendRedirect("/");
        request.setAttribute("redirected", "redirected"); %>

</c:if>

<% if (request.getAttribute("redirected") != null) {
    return;
}%>

<html>
<head>
    <title>● Login</title>
    <link rel="icon" type="image/png" href="logo.png">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="styles/standup_animation.css"/>

    <link rel="stylesheet" href="styles/login.css">
    <link href="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/css/bootstrap4-toggle.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="styles/navbar_standup.css"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://www.google.com/recaptcha/api.js"></script>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/js/bootstrap4-toggle.min.js"></script>


    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <script src="javascript/checkbox.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">

    <style>
        @import url('https://fonts.googleapis.com/icon?family=Material+Icons');

    </style>
    <script>
      let failed = false
      let wrong_username_password_combinations = []
      let button_disabled = false

      async function check_input() {
        let button = document.getElementById("login_button")
        button.disabled = true

        document.querySelector("form").classList.add('my-was-validated');
        if (is_combination_wrong()) {
          return
        }

        let span_loading = document.getElementById("loading_span")

        failed = document.getElementsByName("password")[0].value.length < 4 ||
            document.getElementsByName("password")[0].value.length > 20 ||
            document.getElementsByName("username")[0].value.length < 4 ||
            document.getElementsByName("username")[0].value.length > 20;

        if (!recaptcha_valid()) {
          if (document.getElementById("recaptcha_invalid") == null) {
            let paragraph = document.getElementById("my_recaptcha");
            let text = document.createElement("h1");
            text.setAttribute("id", "recaptcha_invalid");
            text.innerHTML = "Please Verify That You Are Not A Robot."
            text.style.fontSize = "17px"
            text.style.transform = "translate(0%, 49%)"
            text.style.color = "rgb(220, 53, 69)"
            paragraph.appendChild(text);
          }

          failed = true
        }
        if (failed) {
          console.log("failed, returning")
          handle_username_validity()
          handle_password_validity()
          return
        }
        span_loading.classList.toggle("spinner-border")
        document.getElementById("login_text_span").style.display = "none"
        await new Promise((r) => setTimeout(r, Math.floor(Math.random() * 500) + 1000))
        let remember_me = (document.getElementById('remember_me').checked) ? "on" : null
        $.ajax({
          type: "post",
          url: "https://${pageContext.request.serverName}/check-login" + "?remember=" + remember_me + "&username=" +
              encodeURIComponent(document.getElementsByName("username")[0].value) +
              "&password=" + encodeURIComponent(document.getElementsByName("password")[0].value) +
              "&g-recaptcha-response=" +
              grecaptcha.getResponse(),
          dataType: "html",
          async: false,
          success: function(response) {
            console.log(response)
            if (response === "ok") {
              window.location.href = "/"
            }
            else if (response === "admin") {
              window.location.href = "admin.jsp";
            }
            else if (response.search("Please Wait A While") !== -1) {
              button_disabled = true
              $("#login_cooldown").modal({
                backdrop: 'static',
                keyboard: false
              });
            }
            else if (response.search("Your Account Is Not Verified") !== -1) {
              new Audio("sounds/fail.wav").play();
              $("#not_verified").modal({
                backdrop: 'static',
                keyboard: false
              });
            }
            else if (response.search("Invalid Username And Password") !== -1) {
              new Audio("sounds/fail.wav").play();

              document.getElementById("username_error").innerHTML = "Wrong username or password."
              document.getElementById("password_error").innerHTML = "Wrong username or password."
              button_disabled = true
              document.querySelector("#username").classList.add("is-invalid")
              document.querySelector("#password").classList.add("is-invalid")
              wrong_username_password_combinations.push({
                username: document.getElementsByName("username")[0].value,
                password: document.getElementsByName("password")[0].value
              })
            }
            else if (response.search("Different IP Address") !== -1) {
              button_disabled = true
              new Audio("sounds/fail.wav").play();
              $("#different_ip_address").modal({
                backdrop: 'static',
                keyboard: false
              });
            }
          }
        })
        handle_username_validity()
        handle_password_validity()
        span_loading.classList.toggle("spinner-border")
        document.getElementById("login_text_span").style.display = "inline"
        if (!button_disabled)
          button.disabled = false
        grecaptcha.reset();

      }

      function recaptcha_valid() {
        return grecaptcha.getResponse().length !== 0;
      }
    </script>
</head>

<body class="bg-dark">
    <nav class="navbar navbar-expand-xl
 navbar-dark bg-dark" style="
    background-color: rgb(22,22,22) !important;
">
        <a href="/" class="navbar-brand" style="font-size: 150%;">
            <img id="website_logo" style="padding-right: 8px;margin-top: -4px;cursor:pointer;"
                 src="logo_transparent.png" alt="website logo">SnirDekel.com</a>
        <button class="navbar-toggler" data-toggle="collapse" data-target="#navbarMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div id="navbarMenu" class="navbar-collapse collapse">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="signup.jsp">Create New Account <i class="fa-solid fa-user-plus"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="forgot_password.jsp">Forgot Password <i class="fa-solid fa-question"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" target="_blank" href="restore_account.jsp">Restore Account <i
                            class="fa-solid fa-trash-arrow-up"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" target="_blank" href="https://github.com/Snir-Dekel">Snir's GitHub <i
                            class="fa-brands fa-github"></i></a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="center">
        <h1 class="text-primary" id="login_div">Login to SnirDekel.com</h1>
        <form style="width: 50%;" class="needs-validation container bg-dark mt-2 border_rotate" novalidate
              onsubmit="return false">
            <div class="form-floating mb-3">
                <input name="username" type="text" autocomplete="username" class="form-control text-light bg-dark"
                       id="username" placeholder="username" required minlength="4" dir=auto
                       maxlength="20">
                <label for="username">Username</label>
                <div id="username_error" class="invalid-feedback">Username must be 4 to 20 characters long.</div>
            </div>


            <div class="mb-3 form-floating" id="my_input-container">
                <input name="password" id="password" class="form-control text-light bg-dark"
                       autocomplete="current-password" type="password" required minlength="4" dir=auto
                       maxlength="20" placeholder="password">

                <label for="password">Password</label>
                <div id="password_error" class="invalid-feedback">Password must be 4 to 20 characters long.</div>

                <div id="checkbox1_div" style="margin: 0;position: relative;transform: translate(0%, 9%);"><p
                        style="display: inline;font-size: 140%;color: rgba(255,255,255,0.75)">Show Password:</p>
                    <input id="checkbox" data-width="50" data-height="35" type="checkbox" data-toggle="toggle"
                           data-onstyle="outline-success"
                           data-offstyle="outline-danger">
                </div>
            </div>
            <div id="main" style="display: table;margin: 0 auto;">
                <div class="g-recaptcha" data-callback="recaptcha_check" data-theme="dark"
                     data-sitekey="6LfpQkUbAAAAAF-QISZ4j4GRLgIBj9U5xhQ1B6HV"
                     id="my_recaptcha">
                </div>

                <div id="checkbox2_div" style="
    margin-top: 1rem;
    margin-left: 1rem;
"><p style="display: inline;font-size: 175%;color: rgba(255,255,255,0.75)">Remember me:</p>
                    <input id="remember_me" name="remember" type="checkbox" data-toggle="toggle"
                           data-onstyle="outline-success"
                           data-offstyle="outline-danger">


                </div>


                <button class="btn btn-primary btn-lg btn-rounded" id="login_button" type="submit"
                        onclick="check_input()" style="
    width: 12rem;
    margin-top: 2rem;
    height: 4.4rem;
    transform: translateX(35%);
    font-size: 220%;
    border: 1px solid #bbb;
    padding-right: 0.5rem;
            "
                >
                    <span id="login_text_span">Login</span><span id="loading_span" style="margin-right:0.7rem"></span>
                </button>
            </div>
        </form>
    </div>

    <div class="modal fade" id="not_verified">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Login Failed</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">Your account is not verified, please
                        enter the link in your email to verify your account.</p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69)" class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>

                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="login_cooldown">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Login Failed</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">Please wait a while, you have tried to
                        log in too many times with an incorrect username and password combination.</p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69)" class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>

                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="different_ip_address">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #ffc107;" class="modal-content">
                <div style="border-bottom:1px solid #ffc107" class="modal-header">
                    <h2 style="color: #ffc107" class="modal-title">Login from new location
                    </h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ffc107;">You have tried to log in with a
                        different ip address, please enter the link in your inbox to verify your account.</p>
                </div>
                <div style="border-top: 1px solid #ffc107" class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>

                </div>
            </div>
        </div>
    </div>


    <script>


      function fix_autocomplete() {
        setTimeout(() => {
          if ($(this).is(':-internal-autofill-selected')) {
            var clone = $(this).clone(true, true);
            $(this).after(clone);
            $(this).remove();
          }
        }, 10);
      }

      $('.form-control').on('input', fix_autocomplete);

      function recaptcha_check() {
        let username_input = document.querySelector("#username")
        let password_input = document.querySelector("#password")
        if (document.getElementById("recaptcha_invalid") != null) {
          document.getElementById("recaptcha_invalid").remove();
        }
        if ((username_input.value.length >= 4 &&
                username_input.value.length <= 20) &&
            (!(is_combination_wrong())) && (password_input.value.length >= 4 &&
                password_input.value.length <= 20)
        ) {
          let button = document.getElementById("login_button")
          button.disabled = false
        }
      }

      function toggleVisibility() {
        let password_input = document.querySelector("#password")
        password_input.type = password_input.type === "password" ? "text" : "password"
      }

      $('#checkbox').change(function() {
        toggleVisibility()
      })

      function is_combination_wrong() {
        if (wrong_username_password_combinations.length === 0) {
          return false
        }

        for (let i = 0; i < wrong_username_password_combinations.length; i++) {
          if (wrong_username_password_combinations[i].username === document.getElementsByName("username")[0].value &&
              wrong_username_password_combinations[i].password === document.getElementsByName("password")[0].value) {
            return true
          }
        }
        return false
      }

      function handle_username_validity() {
        let password_input = document.querySelector("#password")
        let username_input = document.querySelector("#username")
        let button = document.getElementById("login_button")
        if ((username_input.value.length < 4 ||
                username_input.value.length > 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          document.getElementById("username_error").innerHTML = "Username must be 4 to 20 characters long."
          username_input.classList.add("is-invalid")
          username_input.classList.remove("is-valid")
          button.disabled = true

        }
        if (is_combination_wrong()) {
          password_input.classList.add("is-invalid")
          username_input.classList.add("is-invalid")
          document.getElementById("username_error").innerHTML = "Wrong username or password."
          document.getElementById("password_error").innerHTML = "Wrong username or password."
          button.disabled = true

        }
        if (!is_combination_wrong() && (password_input.value.length >= 4 &&
                password_input.value.length <= 20) &&
            document.querySelector("form").classList.contains("my-was-validated") &&
            (username_input.value.length >= 4 &&
                username_input.value.length <= 20)) {
          password_input.classList.remove("is-invalid")
          password_input.classList.add("is-valid")
          if ((username_input.value.length < 4 ||
              username_input.value.length > 20) && recaptcha_valid()) {
            button.disabled = false
          }

        }
        if (!is_combination_wrong() && (username_input.value.length >= 4 &&
                username_input.value.length <= 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          username_input.classList.remove("is-invalid")
          username_input.classList.add("is-valid")
          if ((password_input.value.length >= 4 &&
              password_input.value.length <= 20) && recaptcha_valid()) {
            button.disabled = false
          }

        }
      }

      function handle_password_validity() {
        let password_input = document.querySelector("#password")
        let username_input = document.querySelector("#username")
        let button = document.getElementById("login_button")
        if ((password_input.value.length < 4 ||
                password_input.value.length > 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          document.getElementById("password_error").innerHTML = "Password must be 4 to 20 characters long."
          password_input.classList.add("is-invalid")
          button.disabled = true

        }
        if (is_combination_wrong()) {
          username_input.classList.add("is-invalid")
          password_input.classList.add("is-invalid")
          document.getElementById("username_error").innerHTML = "Wrong username or password."
          document.getElementById("password_error").innerHTML = "Wrong username or password."
          button.disabled = true
        }
        if (!is_combination_wrong() && (username_input.value.length >= 4 &&
                username_input.value.length <= 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          username_input.classList.remove("is-invalid")
          username_input.classList.add("is-valid")
          if ((password_input.value.length >= 4 &&
              password_input.value.length <= 20) && recaptcha_valid()) {
            button.disabled = false
          }

        }
        if (!is_combination_wrong() && (password_input.value.length >= 4 &&
                password_input.value.length <= 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          password_input.classList.remove("is-invalid")
          password_input.classList.add("is-valid")
          if ((username_input.value.length >= 4 &&
              username_input.value.length <= 20) && recaptcha_valid()) {
            button.disabled = false
          }

        }
      }

      $('#username').on('input', handle_username_validity);
      $('#password').on('input', handle_password_validity);

    </script>

</body>
</html>
