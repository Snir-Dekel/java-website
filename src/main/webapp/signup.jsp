<%@ page import="java.util.function.Function" %>
<%@ page import="com.example.final_website.Functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%
    System.out.println("in signup" + " " + Functions.getClientIp(request));
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
        <c:set var="email" value="${row.email}"/>
    </c:forEach>
</c:if>
<c:if test="${username!=null}">
    <%
        response.sendRedirect("/");
        request.setAttribute("redirected", "redirected");
    %>


</c:if>
<% if (request.getAttribute("redirected") != null) {
    return;
}%>

<html>
<head>
    <title>● Signup</title>
    <link rel="icon" type="image/png" href="logo.png">
    <script src="https://www.google.com/recaptcha/api.js"></script>
    <link rel="stylesheet" href="styles/standup_animation.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="styles/standup_animation.css"/>
    <link rel="stylesheet" href="styles/navbar_standup.css"/>

    <link rel="stylesheet" href="styles/signup.css">
    <link href="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/css/bootstrap4-toggle.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://www.google.com/recaptcha/api.js"></script>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/js/bootstrap4-toggle.min.js"></script>


    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">


    <script>
      let failed = false
      let taken_usernames = []
      let taken_emails = []

      async function check_input() {
        let button = document.getElementsByClassName("button")[0]
        let span_loading = document.getElementById("loading_span")

        document.querySelector("form").classList.add('my-was-validated');
        let password_input = document.querySelector("#password")
        let username_input = document.querySelector("#username")
        let email_input = document.querySelector("#email")
        if (!recaptcha_valid()) {
          button.disabled = true
        }
        if ((document.querySelector("#email").validity.valueMissing ||
            document.querySelector("#email").validity.patternMismatch)) {
          document.getElementById("email_error").innerHTML = "Please enter a valid email address."
          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          button.disabled = true
        }

        else if (!(document.querySelector("#email").validity.valueMissing ||
            document.querySelector("#email").validity.patternMismatch)) {
          email_input.classList.remove("is-invalid")
          email_input.classList.add("is-valid")
          if ((password_input.value.length >= 4 &&
              password_input.value.length <= 20) && (username_input.value.length >= 4 &&
              username_input.value.length <= 20) && recaptcha_valid()) {
            button.disabled = false
          }

        }

        if (password_input.value.length >= 4 &&
            password_input.value.length <= 20) {
          password_input.classList.remove("is-invalid")
          password_input.classList.add("is-valid")
          if ((username_input.value.length >= 4 &&
              username_input.value.length <= 20) && (!(document.querySelector("#email").validity.valueMissing ||
              document.querySelector("#email").validity.patternMismatch)) && recaptcha_valid()) {
            button.disabled = false
          }
        }
        else {
          password_input.classList.remove("is-valid")
          password_input.classList.add("is-invalid")
          button.disabled = true
        }
        if (username_input.value.length >= 4 &&
            username_input.value.length <= 20) {
          username_input.classList.remove("is-invalid")
          username_input.classList.add("is-valid")
          if ((password_input.value.length >= 4 &&
              password_input.value.length <= 20) && (!(document.querySelector("#email").validity.valueMissing ||
              document.querySelector("#email").validity.patternMismatch)) && recaptcha_valid()) {
            button.disabled = false
          }

        }
        else {
          username_input.classList.remove("is-valid")
          username_input.classList.add("is-invalid")
          button.disabled = true
        }
        if (button.style.cursor === "not-allowed") {
          return
        }

        failed = document.querySelector("#email").validity.valueMissing ||
            document.querySelector("#email").validity.patternMismatch ||
            document.getElementsByName("password")[0].value.length < 4 ||
            document.getElementsByName("password")[0].value.length > 20 ||
            document.getElementsByName("username")[0].value.length < 4 ||
            document.getElementsByName("username")[0].value.length > 20 ||
            taken_emails.includes(document.getElementById("email").value) ||
            taken_usernames.includes(document.getElementById("username").value);

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
        else {
          if (document.getElementById("recaptcha_invalid") != null) {
            document.getElementById("recaptcha_invalid").remove();

          }
        }
        if (failed) {
          console.log("failed, returning")
          return
        }
        button.disabled = !button.disabled
        span_loading.classList.toggle("spinner-border")
        document.getElementById("signup_text_span").style.display = "none"
        await new Promise((r) => setTimeout(r, Math.floor(Math.random() * 500) + 1000))
        if (!failed) {
          $.ajax({
            type: "post",
            url: "https://${pageContext.request.serverName}/user-exist?username=" +
                encodeURIComponent(document.querySelector("input[name=username]").value),
            dataType: "html",
            async: false,
            success: function(response) {
              console.log("user-exist: " + response)
              let paragraph = document.getElementById("username_error")
              if (response === "yes") {
                document.querySelector("#username").classList.add("is-invalid")
                document.querySelector("#email").classList.add("is-valid")
                document.querySelector("#password").classList.add("is-valid")
                document.querySelector("form").classList.remove("was-validated")
                taken_usernames.push(document.getElementById("username").value)
                paragraph.innerHTML = "This username is already taken. Try using another name."
                failed = true
              }
              else {
                document.querySelector("#username").classList.remove("is-invalid")
                document.querySelector("form").classList.add("was-validated")
                paragraph.innerHTML = "Username must be 4 to 20 characters long."
              }
            }
          })
        }
        $.ajax({
          type: "post",
          url: "https://${pageContext.request.serverName}/email-exist?email=" +
              encodeURIComponent(document.getElementById("email").value),
          dataType: "html",
          async: false,
          success: function(response) {
            console.log("email-exist: " + response)
            let paragraph = document.getElementById("email_error");

            if (response === "yes") {
              document.querySelector("#username").classList.add("is-valid")
              document.querySelector("#email").classList.add("is-invalid")
              document.querySelector("#password").classList.add("is-valid")
              document.querySelector("form").classList.remove("was-validated")
              if (document.getElementById("email_taken") == null) {
                taken_emails.push(document.getElementById("email").value)
                paragraph.innerHTML = "This email is already registered in the website."
              }

              failed = true
            }
            else {
              document.querySelector("#username").classList.remove("is-invalid")
              document.querySelector("form").classList.add("was-validated")
              paragraph.innerHTML = "Please enter a valid email address."
            }
          }
        })
        if (!failed) {
          console.log("sending the request")
          $.ajax({
            type: "post",
            url: "https://${pageContext.request.serverName}/signup?email=" +
                encodeURIComponent(document.getElementById("email").value)
                + "&username=" +
                encodeURIComponent(document.getElementById("username").value) + "&password=" +
                encodeURIComponent(document.getElementById("password").value) + "&g-recaptcha-response=" +
                grecaptcha.getResponse(),
            dataType: "html",
            async: false,
            success: function(response) {
              console.log(response)
              if (response.search("You Already") === -1) {
                new Audio("sounds/success.wav").play();
                $("#signup_success").modal({
                  backdrop: 'static',
                  keyboard: false
                });
              }
              else {
                new Audio("sounds/fail.wav").play();
                $("#signup_failed").modal({
                  backdrop: 'static',
                  keyboard: false
                });
                button.style.cursor = "not-allowed"

              }
            }
          })

        }
        if (button.style.cursor !== "not-allowed") {
          button.disabled = !button.disabled
        }
        span_loading.classList.toggle("spinner-border")
        document.getElementById("signup_text_span").style.display = "inline"
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
                    <a class="nav-link" href="login.jsp">Login <i class="fa-solid fa-right-to-bracket"></i></a>
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
        <h1 class="text-primary" id="signup_h1">Sign up to SnirDekel.com</h1>
        <form style="width: 50%;" class="needs-validation container bg-dark mt-2 border_rotate" novalidate
              onsubmit="return false">
            <div class="form-floating mb-3">
                <input autocomplete="username" name="username" type="text" class="form-control text-light bg-dark"
                       id="username" placeholder="username" required minlength="4" dir=auto
                       maxlength="20">
                <label for="username">Username</label>
                <div id="username_error" class="invalid-feedback">Username must be 4 to 20 characters long.</div>
            </div>
            <div class="form-floating mb-3">
                <input pattern="[A-Za-z0-9._%+-]{3,}@[a-zA-Z]{3,}([.]{1}[a-zA-Z]{2,}|[.]{1}[a-zA-Z]{2,}[.]{1}[a-zA-Z]{2,})"
                       autocomplete="email" name="email" type="email" class="form-control text-light bg-dark" id="email"
                       placeholder="email" required dir=auto>
                <label for="email">Email address</label>
                <div id="email_error" class="invalid-feedback">Please enter a valid email address.</div>

            </div>

            <div class="mb-3 form-floating" id="my_input-container">
                <input autocomplete="off" name="password" id="password" class="form-control text-light bg-dark"
                       type="password" required minlength="4" dir=auto
                       maxlength="20" placeholder="password">

                <label for="password">Password</label>
                <div class="invalid-feedback">Password must be 4 to 20 characters long.</div>
                <%--            <i id="hide_show" class="material-icons visibility">visibility_off</i>--%>
                <div id="checkbox1_div" style="margin: 0;position: relative;transform: translate(0%, 35%);"><p
                        style="display: inline;font-size: 140%;color: rgba(255,255,255,0.75)">Show Password:</p>
                    <input id="checkbox" data-width="50" data-height="35" type="checkbox" data-toggle="toggle"
                           data-onstyle="outline-success"
                           data-offstyle="outline-danger">
                </div>
            </div>
            <div id="main" style="display: table;margin: 0 auto;padding-top:1rem;user-select: none">
                <%--            <div id="recaptcha_div">--%>
                <div class="g-recaptcha" data-callback="recaptcha_check" data-theme="dark"
                     data-sitekey="6LfpQkUbAAAAAF-QISZ4j4GRLgIBj9U5xhQ1B6HV"
                     id="my_recaptcha">
                </div>
                <%--            </div>--%>


                <button class="btn btn-primary btn-lg btn-rounded button" id="signup_button" type="submit"
                        onclick="check_input()" style="
    width: 12rem;
    margin-top: 2rem;
    height: 4.4rem;
    transform: translateX(35%);
    font-size: 220%;
    border: 1px solid #bbb;
    padding-right: 0.5rem;
            "
                ><span id="signup_text_span">Sign Up</span><span id="loading_span" style="margin-right:0.7rem"></span>

                </button>

            </div>
        </form>

        <%--        <form onsubmit="return false">--%>
        <%--            <h1>enter username</h1> <input type="text" name="username" placeholder="username" maxlength="20" autofocus>--%>
        <%--            <h1>enter password</h1> <input type="password" name="password" placeholder="password">--%>
        <%--            <p style="font-size: 35px">--%>
        <%--                Show Password--%>
        <%--                <input type='checkbox' id='checkbox'/>--%>
        <%--            </p>--%>
        <%--            <br style="line-height: 45%">--%>
        <%--            <h1>enter email</h1><input type="text" name="email" id="my_mail" placeholder="email">--%>
        <%--            <br>--%>
        <%--            <div class="g-recaptcha" data-theme="dark" data-sitekey="6LfpQkUbAAAAAF-QISZ4j4GRLgIBj9U5xhQ1B6HV"--%>
        <%--                 id="my_recaptcha"></div>--%>
        <%--            <button class="button" onclick="check_input()">--%>
        <%--                <span class="button__text">Sign Up</span>--%>
        <%--            </button>--%>
        <%--            --%>
        <%--        </form>--%>


    </div>
    <div class="modal fade" id="signup_failed">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Signup Failed</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">You can't create another account,
                        because you already have one</p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69)" class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>

                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="signup_success">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #1fff00;" class="modal-content">
                <div style="border-bottom:1px solid #289f43" class="modal-header">
                    <h2 style="color: #28a745" class="modal-title">Signup Completed!</h2>
                </div>
                <div class="modal-body">
                    <p style="color: #28a745;font-size: 1.3rem;">A verification link has been sent to your inbox. Please
                        click the link to verify your account</p>
                </div>
                <div style="border-top: 1px solid #28a744" class="modal-footer">
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
        if ((!(taken_emails.includes(document.getElementById("email").value))) &&
            (!(document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch)) && (username_input.value.length >= 4 &&
                username_input.value.length <= 20) &&
            (!(taken_usernames.includes(document.getElementById("username").value))) &&
            (password_input.value.length >= 4 &&
                password_input.value.length <= 20)
        ) {
          let button = document.getElementById("signup_button")
          button.disabled = false
        }
      }

      function toggleVisibility() {
        let password_input = document.querySelector("#password")
        password_input.type = password_input.type === "password" ? "text" : "password"
      }

      $('#username').on('input', handle_username_validity);
      $('#email').on('input', handle_email_validity);
      $('#password').on('input', handle_password_validity);

      $('#checkbox').change(function() {
        toggleVisibility()
      })

      function handle_username_validity() {
        let username_input = document.querySelector("#username")
        let password_input = document.querySelector("#password")
        let button = document.getElementById("signup_button")
        if ((username_input.value.length < 4 ||
                username_input.value.length > 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          document.getElementById("username_error").innerHTML = "Username must be 4 to 20 characters long."
          username_input.classList.add("is-invalid")
          username_input.classList.remove("is-valid")
          button.disabled = true

        }
        if (taken_usernames.includes(document.getElementById("username").value)) {
          username_input.classList.add("is-invalid")
          username_input.classList.remove("is-valid")
          document.getElementById(
              "username_error").innerHTML = "This username is already taken. Try using another name."
          button.disabled = true

        }
        else if ((username_input.value.length >= 4 &&
                username_input.value.length <= 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          username_input.classList.remove("is-invalid")
          username_input.classList.add("is-valid")
          if (password_input.value.length >= 4 &&
              password_input.value.length <= 20 && (!(document.querySelector("#email").validity.valueMissing ||
                  document.querySelector("#email").validity.patternMismatch)) && recaptcha_valid()) {
            button.disabled = false
          }

        }
      }

      function handle_password_validity() {
        let password_input = document.querySelector("#password")
        let username_input = document.querySelector("#username")
        let button = document.getElementById("signup_button")
        if ((password_input.value.length < 4 ||
                password_input.value.length > 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          password_input.classList.add("is-invalid")
          password_input.classList.remove("is-valid")
          button.disabled = true

        }
        else if ((password_input.value.length >= 4 &&
                password_input.value.length <= 20) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          password_input.classList.remove("is-invalid")
          password_input.classList.add("is-valid")
          if (username_input.value.length >= 4 &&
              username_input.value.length <= 20 && (!(document.querySelector("#email").validity.valueMissing ||
                  document.querySelector("#email").validity.patternMismatch)) && recaptcha_valid()) {
            button.disabled = false
          }

        }
      }

      function handle_email_validity() {
        let email_input = document.querySelector("#email")
        let username_input = document.querySelector("#username")
        let password_input = document.querySelector("#password")

        let button = document.getElementById("signup_button")
        if ((document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          document.getElementById("email_error").innerHTML = "Please enter a valid email address."
          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          button.disabled = true

        }
        if (taken_emails.includes(document.getElementById("email").value)) {
          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          document.getElementById("email_error").innerHTML = "This email is already registered in the website."
          button.disabled = true

        }
        else if ((!(document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch)) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          email_input.classList.remove("is-invalid")
          email_input.classList.add("is-valid")
          if ((username_input.value.length >= 4 && username_input.value.length <= 20) &&
              (password_input.value.length >= 4 && password_input.value.length <= 20) && recaptcha_valid()) {
            button.disabled = false
          }

        }

      }

      $(document).ready(function() {
        document.querySelector("#checkbox1_div > div > div > span").addEventListener(
            "mouseover",
            function() {
              document.querySelector(
                  "#checkbox1_div > div > div > label.btn.btn-outline-danger.toggle-off").style.color = "white"
              document.querySelector(
                  "#checkbox1_div > div > div > label.btn.btn-outline-success.toggle-on").style.color = "white"

            },
            false,
        )
        document.querySelector("#checkbox1_div > div > div > span").addEventListener(
            "mouseout",
            function() {
              document.querySelector(
                  "#checkbox1_div > div > div > label.btn.btn-outline-danger.toggle-off").style.color = ""
              document.querySelector(
                  "#checkbox1_div > div > div > label.btn.btn-outline-success.toggle-on").style.color = ""

            },
            false,
        )
      });


    </script>

</body>
</html>
