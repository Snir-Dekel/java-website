<%@ page import="com.example.final_website.Functions" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (!Functions.link_valid(request.getParameter("email"), "password") || !Functions.link_valid_password(request.getParameter("email"), request.getParameter("password_reset_code"))) {
        System.out.println(request.getParameter("email") + " email");
        System.out.println("link is not valid");
        out.print("\n" +
                "<!doctype html>\n" +
                "<html lang=\"en\">\n" +
                "<head>\n" +
                "    <title>● Link invalid</title>\n" +
                "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                "    <link rel=\"stylesheet\" href=\"styles/svg_animation.css\"/>\n" +
                "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js\"></script>\n" +
                "    <script src=\"https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js\"></script>\n" +
                "\n" +
                "    <style>\n" +
                "        * {\n" +
                "            font-family: Arial, Helvetica, sans-serif;\n" +
                "            background: rgb(33, 37, 41);\n" +
                "            color: #e0293b;\n" +
                "        }\n" +
                "\n" +
                "        html, body {\n" +
                "            max-width: 100%;\n" +
                "            max-height: 100%;\n" +
                "            overflow: hidden;\n" +
                "        }\n" +
                "\n" +
                "        a:hover {\n" +
                "            color: #0aceff;\n" +
                "        }\n" +
                "\n" +
                "        a {\n" +
                "            transition: all 0.2s ease-in-out;\n" +
                "            color: #0689c6;\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "\n" +
                "    <div class=\"standup_animation\" style=\"  margin: 0 auto; text-align: center;  width: 50%;\">\n" +
                "        <h1 style=\"margin-top: 5px;font-weight: bold;\">The link you followed has expired or invalid, you can request another one in this link</h1>\n" +
                "    <a style=\"font-size: 200%\" href=\"forgot_password.jsp\">Forgot Password</a>\n" +
                "\n" +
                "    </div>\n" +
                "\n" +
                "    <div id=\"sign_div\" style=\"height: 28rem;width: 50rem; margin: 9rem auto auto;\">\n" +
                "        <svg\n" +
                "                id=\"sign_element\"\n" +
                "                width=\"915\"\n" +
                "                height=\"353\"\n" +
                "                viewBox=\"0 0 915 353\"\n" +
                "                fill=\"none\"\n" +
                "                xmlns=\"http://www.w3.org/2000/svg\"\n" +
                "        >\n" +
                "            <g clip-path=\"url(#clip0)\">\n" +
                "                <g filter=\"url(#filter0_d)\">\n" +
                "                    <path\n" +
                "                            id=\"path\"\n" +
                "                            d=\"M179.191 12C159.458 16.9373 141.334 25.5579 123.066 34.4012C92.4225 49.2362 62.3306 65.3793 33.8677 84.1075C29.2562 87.1419 5.27702 99.4617 8.25519 108.403C9.37543 111.767 13.2491 114.119 15.9389 115.982C25.0368 122.285 34.8531 127.528 44.5582 132.81C71.1892 147.304 98.9407 160.353 124.012 177.502C140.854 189.021 159.5 203.355 166.496 223.419C174.705 246.961 169.173 274.57 151.519 292.239C132.2 311.572 100.538 320.09 74.6807 325.841C66.11 327.746 57.4583 329.35 48.7898 330.745C44.5549 331.426 47.7268 331.935 50.3488 331.97C77.5948 332.338 104.492 336.881 131.753 336.985C167.392 337.122 202.974 336.516 238.601 335.926C253.899 335.673 269.113 334.046 284.425 333.976C295.704 333.924 307.087 334.48 318.334 333.475C322.681 333.087 326.961 333.135 331.308 332.973C333.747 332.883 330.964 329.83 330.528 328.738C324.017 312.449 321.41 294.455 319.726 277.137C317.978 259.151 317.972 240.722 319.113 222.695C320.488 201.001 321.255 179.628 321.564 157.886C322.207 112.435 323.011 169.979 323.011 125.344C321.007 112.304 323.011 64.994 323.011 78.7023C323.011 100.899 321.508 106.546 321.508 128.743C321.508 136.943 321.644 161.63 321.644 153.429C321.644 143.604 325.535 131.568 331.753 124.341C356.206 95.9199 398.637 113.554 423.234 131.92C487.392 179.822 498.935 257.776 487.878 332.472C486.828 339.566 484.958 342.728 493.39 341.555C506.757 339.698 521.397 341.555 534.203 341.555C554.471 339.995 575.573 338.379 595.618 336.985C616.665 336.985 638.658 335.982 659.872 332.973C667.116 332.973 673.235 332.973 681.531 332.973C686.264 332.973 691.387 331.07 694.783 331.07C696.328 331.07 691.268 330.933 690.83 328.961C685.457 304.766 687.322 276.862 687.322 252.228C687.322 218.202 691.331 187.425 691.331 153.429C691.331 148.171 688.324 153.429 683.814 150.531C681.195 150.531 679.907 146.542 678.302 144.179C676.184 141.061 674.794 135.374 675.796 131.362C678.302 126.347 680.306 122.823 689.326 122.335C707.868 121.332 707.366 147.912 695.841 149.918C694.337 151.534 693.574 153.166 692.333 151.924C691.4 150.99 690.259 150.991 689.326 151.924C687.318 153.935 691.182 162.244 691.888 164.964C695.917 180.517 694.337 197.42 694.337 213.389C694.337 249.853 689.326 285.976 689.326 322.497C689.326 324.069 688.176 330.89 690.272 330.967C697.211 331.224 703.43 330.967 710.373 330.967C741.757 330.967 774.2 328.961 805.585 328.961C820.544 328.961 835.504 328.961 850.463 328.961C856.478 328.961 854.567 320.376 854.75 315.81C855.054 308.201 856.917 300.772 857.478 293.186C858.215 283.224 858.589 273.231 859.204 263.262C861.086 232.75 861.593 201.823 861.71 171.261C861.758 158.725 861.095 146.037 862.211 133.536C862.494 130.362 860.82 121.625 862.935 124.007C864.531 125.804 863.714 130.3 863.714 132.421C863.714 137.901 863.714 143.379 863.714 148.859C863.714 167.163 861.71 185.347 861.71 203.581C861.71 210.194 861.71 216.806 861.71 223.419C861.71 224.605 861.71 219.094 861.71 218.404C861.71 210.732 863.402 203.79 867.278 197.117C873.093 187.106 879.817 178.38 891.777 176.053C897.271 174.984 901.756 176.499 906.81 176.499\"\n" +
                "                            stroke=\"white\"\n" +
                "                            stroke-width=\"15\"\n" +
                "                            stroke-linecap=\"round\"\n" +
                "                            stroke-linejoin=\"round\"></path>\n" +
                "                </g>\n" +
                "            </g>\n" +
                "            <defs>\n" +
                "                <filter\n" +
                "                        id=\"filter0_d\"\n" +
                "                        x=\"-3.51056\"\n" +
                "                        y=\"4.49823\"\n" +
                "                        width=\"921.821\"\n" +
                "                        height=\"352.796\"\n" +
                "                        filterUnits=\"userSpaceOnUse\"\n" +
                "                        color-interpolation-filters=\"sRGB\"\n" +
                "                >\n" +
                "                    <feFlood flood-opacity=\"0\" result=\"BackgroundImageFix\"></feFlood>\n" +
                "                    <feColorMatrix\n" +
                "                            in=\"SourceAlpha\"\n" +
                "                            type=\"matrix\"\n" +
                "                            values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0\"></feColorMatrix>\n" +
                "                    <feOffset dy=\"4\"></feOffset>\n" +
                "                    <feGaussianBlur stdDeviation=\"2\"></feGaussianBlur>\n" +
                "                    <feColorMatrix\n" +
                "                            type=\"matrix\"\n" +
                "                            values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0\"></feColorMatrix>\n" +
                "                    <feBlend\n" +
                "                            mode=\"normal\"\n" +
                "                            in2=\"BackgroundImageFix\"\n" +
                "                            result=\"effect1_dropShadow\"></feBlend>\n" +
                "                    <feBlend\n" +
                "                            mode=\"normal\"\n" +
                "                            in=\"SourceGraphic\"\n" +
                "                            in2=\"effect1_dropShadow\"\n" +
                "                            result=\"shape\"></feBlend>\n" +
                "                </filter>\n" +
                "                <clipPath id=\"clip0\">\n" +
                "                    <rect width=\"915\" height=\"353\" fill=\"white\"></rect>\n" +
                "                </clipPath>\n" +
                "            </defs>\n" +
                "        </svg>\n" +
                "    </div>\n" +
                "    <script>\n" +
                "      let my_path = document.getElementById(\"path\")\n" +
                "      let sign_element = document.getElementById(\"sign_element\")\n" +
                "      sign_element.addEventListener(\n" +
                "          \"mouseover\",\n" +
                "          function() {\n" +
                "            sign_element.setAttribute(\"data-sign-element-was-hovered\", \"true\")\n" +
                "          },\n" +
                "          false,\n" +
                "      )\n" +
                "      my_path.addEventListener(\n" +
                "          \"mouseover\",\n" +
                "          function() {\n" +
                "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                "                \"paused\"\n" +
                "          },\n" +
                "          false,\n" +
                "      )\n" +
                "      my_path.addEventListener(\n" +
                "          \"mouseout\",\n" +
                "          function() {\n" +
                "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                "                \"running\"\n" +
                "          },\n" +
                "          false,\n" +
                "      )\n" +
                "      $(\"#sign_element\").tilt({\n" +
                "        perspective: 550,\n" +
                "        speed: 2500,\n" +
                "      })\n" +
                "    </script>\n" +
                "</body>\n" +
                "</html>");
        return;
    }
    else {
        System.out.println("link is valid");
    }
%>
<html>
<head>
    <title>● Reset Password</title>
    <link rel="icon" type="image/png" href="logo.png">
    <link rel="stylesheet" href="styles/standup_animation.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="styles/navbar_standup.css"/>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://www.google.com/recaptcha/api.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/js/bootstrap4-toggle.min.js"></script>
    <link href="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/css/bootstrap4-toggle.min.css"
          rel="stylesheet">


    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <script src="javascript/checkbox.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta2/css/all.min.css">


    <link rel="stylesheet" href="styles/reset_password.css">

    <script>

      function recaptcha_valid() {
        return grecaptcha.getResponse().length !== 0;
      }

      function handle_passwords_validity() {
        let failed = false
        console.log("handle_passwords_validity")
        let password_input1 = document.querySelector("#password1")
        let password_input2 = document.querySelector("#password2")

        let button = document.getElementById("reset_password_button")

        if (password_input1.value.length < 4) {
          password_input1.classList.add("is-invalid")
          password_input1.classList.remove("is-valid")
          document.getElementById("password_error1").innerHTML = "Minimum password length is 4 letters."
          button.disabled = true
          failed = true
        }
        else {
          password_input1.classList.add("is-valid")
          password_input1.classList.remove("is-invalid")
        }
        if (password_input2.value.length < 4) {
          password_input2.classList.add("is-invalid")
          password_input2.classList.remove("is-valid")
          document.getElementById("password_error2").innerHTML = "Minimum password length is 4 letters."
          button.disabled = true
          failed = true
        }
        else {
          password_input2.classList.add("is-valid")
          password_input2.classList.remove("is-invalid")
        }
        if (failed) {
          return
        }
        if (password_input1.value !== password_input2.value) {
          document.getElementById("password_error1").innerHTML = "Passwords do not match."
          document.getElementById("password_error2").innerHTML = "Passwords do not match."
          password_input1.classList.add("is-invalid")
          password_input1.classList.remove("is-valid")
          password_input2.classList.add("is-invalid")
          password_input2.classList.remove("is-valid")
          button.disabled = true

        }

        else if (password_input1.value === password_input2.value && password_input1.value.length >= 4 &&
            password_input2.value.length >= 4) {
          password_input1.classList.remove("is-invalid")
          password_input1.classList.add("is-valid")
          password_input2.classList.remove("is-invalid")
          password_input2.classList.add("is-valid")
          if (recaptcha_valid()) {
            button.disabled = false
          }
        }

      }


      function recaptcha_check() {
        if (document.getElementById("recaptcha_invalid") != null) {
          document.getElementById("recaptcha_invalid").remove();
        }
        if (document.getElementById("password1").value === document.getElementById("password2").value &&
            document.getElementById("password1").value.length >= 4 &&
            document.getElementById("password2").value.length >= 4) {
          let button = document.getElementById("reset_password_button")
          button.disabled = false
        }
      }

      async function check_passwords() {
        $('#password1').on('input', handle_passwords_validity);
        $('#password2').on('input', handle_passwords_validity);

        let button = document.getElementById("reset_password_button")
        let span_loading = document.getElementById("loading_span")
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
        handle_passwords_validity()

        if (button.disabled) {
          return
        }

        let url_string = window.location.href;
        let url = new URL(url_string);
        let password_reset_code = url.searchParams.get("password_reset_code");
        document.getElementById("reset_password_text_span").style.display = "none"
        span_loading.classList.toggle("spinner-border")

        await new Promise((r) => setTimeout(r, Math.floor(Math.random() * 500) + 1000))

        $.ajax({
          type: "post",
          url: "https://${pageContext.request.serverName}/reset_password?password_reset_code=" + password_reset_code +
              "&new-password=" + encodeURIComponent(document.getElementsByName("new-password")[0].value) + "&email=" +
              encodeURIComponent(url.searchParams.get("email")),
          dataType: "html",
          async: false,
          success: function(response) {
            console.log(response)
            if (response === "ok") {
              new Audio("sounds/success.wav").play();

              $("#password_changed").modal({
                backdrop: 'static',
                keyboard: false,
              })
            }
            else if (response.search("password reset code is invalid") === -1) {
              new Audio("sounds/fail.wav").play();

              $("#link_expired").modal({
                backdrop: 'static',
                keyboard: false,
              })
            }
          }
        })

        span_loading.classList.toggle("spinner-border")
        document.getElementById("reset_password_text_span").style.display = "inline"
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
                    <a class="nav-link" href="signup.jsp">Create New Account <i class="fa-solid fa-user-plus"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" target="_blank" href="forgot_password.jsp">Forgot Password</a>
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
        <h1 class="text-primary" id="reset_password_h1">Reset password</h1>
        <form style="width: 50%;" class="needs-validation container bg-dark mt-2 border_rotate" novalidate
              onsubmit="return false">

            <div class="form-floating mb-3">
                <input autocomplete="new-password" name="new-password" type="password"
                       class="form-control text-light bg-dark" id="password1"
                       placeholder="new-password" required dir=auto maxlength="20">
                <label for="password1">New password</label>
                <div id="password_error1" class="invalid-feedback">Minimum password length is 4 letters.</div>
                <div id="checkbox1_div" style="margin: 0;position: relative;transform: translate(0%, 35%);">
                    <p style="display: inline;font-size: 140%;color: rgba(255,255,255,0.75)">Show Password:</p>
                    <input id="checkbox1" data-width="50" data-height="35" type="checkbox" data-toggle="toggle"
                           data-onstyle="outline-success"
                           data-offstyle="outline-danger">
                </div>
            </div>


            <div style="margin-top: 2.5rem;" class="form-floating mb-3">
                <input autocomplete="new-password" name="confirm_new_password" type="password"
                       class="form-control text-light bg-dark" id="password2"
                       placeholder="new-password" maxlength="20" required dir=auto>
                <label for="password2">Confirm new password</label>
                <div id="password_error2" class="invalid-feedback">Minimum password length is 4 letters.</div>
                <div id="checkbox2_div" style="margin: 0;position: relative;transform: translate(0%, 35%);"><p
                        style="display: inline;font-size: 140%;color: rgba(255,255,255,0.75)">Show Password:</p>
                    <input id="checkbox2" data-width="50" data-height="35" type="checkbox" data-toggle="toggle"
                           data-onstyle="outline-success"
                           data-offstyle="outline-danger">
                </div>
            </div>

            <div id="main" style="display: table;margin: 0 auto;padding-top:1rem;user-select: none">
                <div class="g-recaptcha" data-callback="recaptcha_check" data-theme="dark"
                     data-sitekey="6LfpQkUbAAAAAF-QISZ4j4GRLgIBj9U5xhQ1B6HV"
                     id="my_recaptcha">
                </div>


                <button class="btn btn-primary btn-lg btn-rounded button" id="reset_password_button" type="submit"
                        onclick="check_passwords()" style="
    width: 13rem;
    margin-top: 2rem;
    height: 4rem;
    transform: translateX(25%);
    font-size: 165%;
    border: 1px solid #bbb;
    padding-right: 0.5rem;
            "
                ><span id="reset_password_text_span">Reset password</span><span id="loading_span"
                                                                                style="margin-right:0.7rem"></span>

                </button>

            </div>
        </form>
    </div>


    <script>
      const toggleVisibility = (element) => {
        if (element.type === 'password') {
          element.type = 'text';
        }
        else {
          element.type = 'password';
        }
      };
      $('#checkbox1').change(function() {
        toggleVisibility(document.getElementById("password1"))
      })
      $('#checkbox2').change(function() {
        toggleVisibility(document.getElementById("password2"))
      })

    </script>


    <div class="modal fade" id="password_changed">
        <div class="modal-dialog modal-lg">
            <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #1fff00;" class="modal-content">
                <div style="border-bottom:1px solid #289f43" class="modal-header">
                    <h2 style="color: #28a745" class="modal-title">Reset successfully completed</h2>
                </div>
                <div class="modal-body">
                    <p style="color: #28a745;font-size: 1.3rem;">Your password has been successfully changed.</p>
                </div>
                <div style="border-top: 1px solid #28a744;" class="modal-footer">
                    <button onclick="window.location.href = 'login.jsp'" type="button" class="btn btn-primary"
                            data-dismiss="modal">Login
                    </button>
                </div>
            </div>
        </div>
    </div>


    <div class="modal fade" id="link_expired">
        <div class="modal-dialog modal-lg">
            <div style="background-color: rgb(24,24,24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                    <h2 style="color: #ff3e3e" class="modal-title">Reset failed</h2>
                </div>
                <div class="modal-body">
                    <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">It's been too long since the link was
                        sent to your email, please click here to send another link.</p>
                </div>
                <div style="border-top: 1px solid rgb(220, 53, 69);"
                     class="modal-footer">
                    <button style="font-size: 150%;" onclick="window.location.href = 'forgot_password.jsp'"
                            type="button" class="btn btn-primary no-standup" data-dismiss="modal">send another link
                    </button>


                </div>
            </div>
        </div>
    </div>


</body>
</html>
