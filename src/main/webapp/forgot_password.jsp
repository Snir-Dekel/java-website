<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>● Forgot Password</title>
    <link rel="icon" type="image/png" href="logo.png">
    <link rel="stylesheet" href="styles/standup_animation.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="styles/navbar_standup.css"/>
    <script src="https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js"></script>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://www.google.com/recaptcha/api.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/js/bootstrap4-toggle.min.js"></script>


    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">

</head>
<link rel="stylesheet" href="styles/forgot_password.css">

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
                    <a class="nav-link" href="signup.jsp">Create New Account <i class="fa-solid fa-user-plus"></i></a>
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
        <h1 class="text-primary" id="forgot_password_h1">Forgot password</h1>
        <form style="width: 50%;" class="needs-validation container bg-dark mt-2 border_rotate" novalidate
              onsubmit="return false">

            <div class="form-floating mb-3">
                <input pattern="[A-Za-z0-9._%+-]{3,}@[a-zA-Z]{3,}([.]{1}[a-zA-Z]{2,}|[.]{1}[a-zA-Z]{2,}[.]{1}[a-zA-Z]{2,})"
                       autocomplete="email" name="email" type="email" class="form-control text-light bg-dark" id="email"
                       placeholder="email" required dir=auto>
                <label for="email">Email address</label>
                <div id="email_error" class="invalid-feedback">Please enter a valid email address.</div>

            </div>


            <div id="main" style="display: table;margin: 0 auto;padding-top:1rem;user-select: none">
                <div class="g-recaptcha" data-callback="recaptcha_check" data-theme="dark"
                     data-sitekey="6LfpQkUbAAAAAF-QISZ4j4GRLgIBj9U5xhQ1B6HV"
                     id="my_recaptcha">
                </div>


                <button class="btn btn-primary btn-lg btn-rounded button" id="forgot_password_button" type="submit"
                        onclick="send_reset_password()" style="
    width: 13rem;
    margin-top: 2rem;
    height: 4.4rem;
    transform: translateX(25%);
    font-size: 220%;
    border: 1px solid #bbb;
    padding-right: 0.5rem;
            "
                ><span id="forgot_password_text_span">Send email</span><span id="loading_span"
                                                                             style="margin-right:0.7rem"></span>

                </button>

            </div>
        </form>



    </div>
    <script>

      function recaptcha_valid() {
        return grecaptcha.getResponse().length !== 0;
      }

      let unregistered_emails = []

      function handle_email_validity() {
        let email_input = document.querySelector("#email")

        let button = document.getElementById("forgot_password_button")
        if ((document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          document.getElementById("email_error").innerHTML = "Please enter a valid email address."

          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          button.disabled = true

        }
        else if (unregistered_emails.includes(document.getElementById("email").value)) {
          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          document.getElementById("email_error").innerHTML = "This email is not registered in the website."
          button.disabled = true

        }
        else if ((!(document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch)) &&
            document.querySelector("form").classList.contains("my-was-validated")) {
          email_input.classList.remove("is-invalid")
          email_input.classList.add("is-valid")
          if (recaptcha_valid()) {
            button.disabled = false
          }
        }

      }

      $('#email').on('input', handle_email_validity);

      async function send_reset_password() {
        let button = document.getElementById("forgot_password_button")
        let span_loading = document.getElementById("loading_span")
        let email_input = document.querySelector("#email")

        document.querySelector("form").classList.add('my-was-validated');
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

          button.disabled = true
        }
        if ((document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch) &&
            (!unregistered_emails.includes(document.getElementById("email").value))) {
          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          document.getElementById("email_error").innerHTML = "Please enter a valid email address."

          button.disabled = true
        }
        else if ((document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch) &&
            unregistered_emails.includes(document.getElementById("email").value)) {
          email_input.classList.add("is-invalid")
          email_input.classList.remove("is-valid")
          document.getElementById("email_error").innerHTML = "This email is not registered in the website."

          button.disabled = true
        }
        else {

          email_input.classList.add("is-valid")
          email_input.classList.remove("is-invalid")
        }
        if (button.disabled) {
          return
        }
        let email = document.getElementById("email").value
        document.getElementById("forgot_password_text_span").style.display = "none"
        span_loading.classList.toggle("spinner-border")

        await new Promise((r) => setTimeout(r, Math.floor(Math.random() * 500) + 1000))
        $.ajax({
          type: "post",
          url: "https://${pageContext.request.serverName}/forgot_password?email=" +
              encodeURIComponent(email) + "&g-recaptcha-response=" + grecaptcha.getResponse(),
          dataType: "html",
          async: false,
          success: function(response) {
            console.log(response)
            if (response.search("too fast") !== -1) {
              new Audio("sounds/fail.wav").play();

              $("#cooldown_email").modal({
                backdrop: 'static',
                keyboard: false,
              })

            }
            else if (response.search("Check Your Email") !== -1) {
              new Audio("sounds/success.wav").play();

              $("#email_sent").modal({
                backdrop: 'static',
                keyboard: false,
              })
            }
            else {
              new Audio("sounds/fail.wav").play();
              unregistered_emails.push(document.getElementById("email").value)
              email_input.classList.add("is-invalid")
              email_input.classList.remove("is-valid")
              document.getElementById("email_error").innerHTML = "This email is not registered in the website."

              $("#wrong_email").modal({
                backdrop: 'static',
                keyboard: false,
              })
            }
          }
        })
        span_loading.classList.toggle("spinner-border")
        document.getElementById("forgot_password_text_span").style.display = "inline"
        grecaptcha.reset();

      }

      function recaptcha_check() {
        if (document.getElementById("recaptcha_invalid") != null) {
          document.getElementById("recaptcha_invalid").remove();
        }
        if (!(document.querySelector("#email").validity.valueMissing ||
                document.querySelector("#email").validity.patternMismatch) &&
            (!unregistered_emails.includes(document.getElementById("email").value))) {
          let button = document.getElementById("forgot_password_button")
          button.disabled = false
        }
      }
    </script>

    <%@include file="email_modal.jsp" %>


</body>
</html>
