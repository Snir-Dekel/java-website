<%@ page import="com.example.final_website.Functions" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="org.ocpsoft.prettytime.PrettyTime" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="org.ocpsoft.prettytime.TimeUnit" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.ocpsoft.prettytime.units.JustNow" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    Cookie[] cookies = request.getCookies();
    String code = "";
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("admin_code")) {
                code = cookie.getValue();
            }
        }
    }
    if (!Functions.is_user_admin(code, response)) {
        out.println("<!doctype html>\n" +
                "\n" +
                "<html lang=\"en\">\n" +
                "<head>\n" +
                "    <title>● Admin Panel</title>\n" +
                "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                "    <link rel=\"stylesheet\" href=\"styles/svg_animation.css\"/>\n" +
                "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js\"></script>\n" +
                "    <script src=\"https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js\"></script>\n" +
                "\n" +
                "    <style>\n" +
                "        * {\n" +
                "            font-family: Arial, Helvetica, sans-serif;\n" +
                "            background: rgb(33, 37, 41);\n" +
                "            color: rgb(225, 225, 225);\n" +
                "        }\n" +
                "\n" +
                "        html, body {\n" +
                "            max-width: 100%;\n" +
                "            max-height: 100%;\n" +
                "            overflow: hidden;\n" +
                "        }\n" +
                "\n" +
                "        .button {\n" +
                "            font-size: 200%;\n" +
                "            margin-top: 1rem;\n" +
                "            transition: all 0.2s;\n" +
                "            background-color: rgb(58, 61, 71);\n" +
                "            color: rgb(225, 225, 225);\n" +
                "            border-radius: 8px;\n" +
                "            padding: 7px;\n" +
                "            cursor: pointer;\n" +
                "            border: 1px solid #bbb\n" +
                "        }\n" +
                "\n" +
                "        .button:hover {\n" +
                "            background-color: rgb(98, 101, 112);\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "<div class=\"standup_animation\" style=\"  margin: 0 auto; text-align: center;  width: 50%;\n" +
                "  \">\n" +
                "    <h1 style=\"margin-top: 5px;font-weight: bolder; color: #dd191a\">\n" +
                "       ONLY THE ADMIN CAN ACCESS THIS PAGE!\n" +
                "    </h1>\n" +
                "    <button onclick=\"window.location.href = '/'\" class=\"button\">\n" +
                "        Go back\n" +
                "    </button>\n" +
                "\n" +
                "</div>\n" +
                "<div id=\"sign_div\" style=\"height: 28rem;width: 50rem; margin: 9rem auto auto;\">\n" +
                "    <svg\n" +
                "            id=\"sign_element\"\n" +
                "            width=\"915\"\n" +
                "            height=\"353\"\n" +
                "            viewBox=\"0 0 915 353\"\n" +
                "            fill=\"none\"\n" +
                "            xmlns=\"http://www.w3.org/2000/svg\"\n" +
                "    >\n" +
                "        <g clip-path=\"url(#clip0)\">\n" +
                "            <g filter=\"url(#filter0_d)\">\n" +
                "                <path\n" +
                "                        id=\"path\"\n" +
                "                        d=\"M179.191 12C159.458 16.9373 141.334 25.5579 123.066 34.4012C92.4225 49.2362 62.3306 65.3793 33.8677 84.1075C29.2562 87.1419 5.27702 99.4617 8.25519 108.403C9.37543 111.767 13.2491 114.119 15.9389 115.982C25.0368 122.285 34.8531 127.528 44.5582 132.81C71.1892 147.304 98.9407 160.353 124.012 177.502C140.854 189.021 159.5 203.355 166.496 223.419C174.705 246.961 169.173 274.57 151.519 292.239C132.2 311.572 100.538 320.09 74.6807 325.841C66.11 327.746 57.4583 329.35 48.7898 330.745C44.5549 331.426 47.7268 331.935 50.3488 331.97C77.5948 332.338 104.492 336.881 131.753 336.985C167.392 337.122 202.974 336.516 238.601 335.926C253.899 335.673 269.113 334.046 284.425 333.976C295.704 333.924 307.087 334.48 318.334 333.475C322.681 333.087 326.961 333.135 331.308 332.973C333.747 332.883 330.964 329.83 330.528 328.738C324.017 312.449 321.41 294.455 319.726 277.137C317.978 259.151 317.972 240.722 319.113 222.695C320.488 201.001 321.255 179.628 321.564 157.886C322.207 112.435 323.011 169.979 323.011 125.344C321.007 112.304 323.011 64.994 323.011 78.7023C323.011 100.899 321.508 106.546 321.508 128.743C321.508 136.943 321.644 161.63 321.644 153.429C321.644 143.604 325.535 131.568 331.753 124.341C356.206 95.9199 398.637 113.554 423.234 131.92C487.392 179.822 498.935 257.776 487.878 332.472C486.828 339.566 484.958 342.728 493.39 341.555C506.757 339.698 521.397 341.555 534.203 341.555C554.471 339.995 575.573 338.379 595.618 336.985C616.665 336.985 638.658 335.982 659.872 332.973C667.116 332.973 673.235 332.973 681.531 332.973C686.264 332.973 691.387 331.07 694.783 331.07C696.328 331.07 691.268 330.933 690.83 328.961C685.457 304.766 687.322 276.862 687.322 252.228C687.322 218.202 691.331 187.425 691.331 153.429C691.331 148.171 688.324 153.429 683.814 150.531C681.195 150.531 679.907 146.542 678.302 144.179C676.184 141.061 674.794 135.374 675.796 131.362C678.302 126.347 680.306 122.823 689.326 122.335C707.868 121.332 707.366 147.912 695.841 149.918C694.337 151.534 693.574 153.166 692.333 151.924C691.4 150.99 690.259 150.991 689.326 151.924C687.318 153.935 691.182 162.244 691.888 164.964C695.917 180.517 694.337 197.42 694.337 213.389C694.337 249.853 689.326 285.976 689.326 322.497C689.326 324.069 688.176 330.89 690.272 330.967C697.211 331.224 703.43 330.967 710.373 330.967C741.757 330.967 774.2 328.961 805.585 328.961C820.544 328.961 835.504 328.961 850.463 328.961C856.478 328.961 854.567 320.376 854.75 315.81C855.054 308.201 856.917 300.772 857.478 293.186C858.215 283.224 858.589 273.231 859.204 263.262C861.086 232.75 861.593 201.823 861.71 171.261C861.758 158.725 861.095 146.037 862.211 133.536C862.494 130.362 860.82 121.625 862.935 124.007C864.531 125.804 863.714 130.3 863.714 132.421C863.714 137.901 863.714 143.379 863.714 148.859C863.714 167.163 861.71 185.347 861.71 203.581C861.71 210.194 861.71 216.806 861.71 223.419C861.71 224.605 861.71 219.094 861.71 218.404C861.71 210.732 863.402 203.79 867.278 197.117C873.093 187.106 879.817 178.38 891.777 176.053C897.271 174.984 901.756 176.499 906.81 176.499\"\n" +
                "                        stroke=\"white\"\n" +
                "                        stroke-width=\"15\"\n" +
                "                        stroke-linecap=\"round\"\n" +
                "                        stroke-linejoin=\"round\"></path>\n" +
                "            </g>\n" +
                "        </g>\n" +
                "        <defs>\n" +
                "            <filter\n" +
                "                    id=\"filter0_d\"\n" +
                "                    x=\"-3.51056\"\n" +
                "                    y=\"4.49823\"\n" +
                "                    width=\"921.821\"\n" +
                "                    height=\"352.796\"\n" +
                "                    filterUnits=\"userSpaceOnUse\"\n" +
                "                    color-interpolation-filters=\"sRGB\"\n" +
                "            >\n" +
                "                <feFlood flood-opacity=\"0\" result=\"BackgroundImageFix\"></feFlood>\n" +
                "                <feColorMatrix\n" +
                "                        in=\"SourceAlpha\"\n" +
                "                        type=\"matrix\"\n" +
                "                        values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0\"></feColorMatrix>\n" +
                "                <feOffset dy=\"4\"></feOffset>\n" +
                "                <feGaussianBlur stdDeviation=\"2\"></feGaussianBlur>\n" +
                "                <feColorMatrix\n" +
                "                        type=\"matrix\"\n" +
                "                        values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0\"></feColorMatrix>\n" +
                "                <feBlend\n" +
                "                        mode=\"normal\"\n" +
                "                        in2=\"BackgroundImageFix\"\n" +
                "                        result=\"effect1_dropShadow\"></feBlend>\n" +
                "                <feBlend\n" +
                "                        mode=\"normal\"\n" +
                "                        in=\"SourceGraphic\"\n" +
                "                        in2=\"effect1_dropShadow\"\n" +
                "                        result=\"shape\"></feBlend>\n" +
                "            </filter>\n" +
                "            <clipPath id=\"clip0\">\n" +
                "                <rect width=\"915\" height=\"353\" fill=\"white\"></rect>\n" +
                "            </clipPath>\n" +
                "        </defs>\n" +
                "    </svg>\n" +
                "</div>\n" +
                "<script>\n" +
                "    let my_path = document.getElementById(\"path\")\n" +
                "    let sign_element = document.getElementById(\"sign_element\")\n" +
                "    sign_element.addEventListener(\n" +
                "        \"mouseover\",\n" +
                "        function () {\n" +
                "            sign_element.setAttribute(\"data-sign-element-was-hovered\", \"true\")\n" +
                "        },\n" +
                "        false,\n" +
                "    )\n" +
                "    my_path.addEventListener(\n" +
                "        \"mouseover\",\n" +
                "        function () {\n" +
                "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                "                \"paused\"\n" +
                "        },\n" +
                "        false,\n" +
                "    )\n" +
                "    my_path.addEventListener(\n" +
                "        \"mouseout\",\n" +
                "        function () {\n" +
                "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                "                \"running\"\n" +
                "        },\n" +
                "        false,\n" +
                "    )\n" +
                "    $(\"svg\").tilt({\n" +
                "        perspective: 550,\n" +
                "        speed: 2500,\n" +
                "    })\n" +
                "</script>\n" +
                "</body>\n" +
                "</html>");
        System.out.println(code + "is not valid");
        return;
    }
    else {
        Functions.update_and_set_admin_code(response);
        request.setAttribute("admin_code", Functions.get_admin_code());
    }
%>
<html>
<head>
    <title>● Admin</title>
    <link rel="icon" type="image/png" href="logo.png">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link rel="stylesheet" href="styles/svg_animation.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <link rel="stylesheet" href="styles/admin.css">
</head>

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
                    <a class="nav-link" href="/">Home <i class="fa-solid fa-house"></i></a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="comment_section.jsp">Browse Comments <i
                            class="fa-solid fa-comment-dots"></i></a>
                </li>
            </ul>
        </div>
    </nav>


    <h1 class="text-primary" id="admin_div">Admin Panel</h1>


    <sql:setDataSource var="db" driver="com.mysql.cj.jdbc.Driver" url="jdbc:mysql://localhost:3306/login_website"
                       user="USER" password="YOUR_PASSWORD"/>
    <sql:query var="result"
               dataSource="${db}">SELECT user_name, email,is_verified, token, profile_picture_name FROM users a
        LEFT JOIN last_active b on a.user_name = b.username
        ORDER BY b.time DESC</sql:query>
    <c:forEach var="row" items="${result.rows}" varStatus="loop">


    <sql:query var="result123"
               dataSource="${db}">SELECT IF(COUNT(1) > 0, 1, 0) as 'data_exists', DATE_FORMAT(time, '%d/%m/%Y') as 'date', TIME_FORMAT(time, '%H:%i') as 'my_date', DATE_FORMAT(time, '%S/%i/%H/%e/%c/%Y') as 'full_date' FROM last_active WHERE username=? ORDER BY time DESC LIMIT 1<sql:param
            value='${row.user_name}'/></sql:query>

    <c:forEach var="row123" items="${result123.rows}">
        <c:choose>
            <c:when test="${row123.data_exists==0}">
                <c:set var="date" value="never" scope="request"/>
                <c:set var="my_date" value="never" scope="request"/>
                <c:set var="full_date" value="never" scope="request"/>
                test
            </c:when>

            <c:otherwise>
                <c:set var="date" value="${row123.date}" scope="request"/>
                <c:set var="my_date" value="${row123.my_date}" scope="request"/>
                <c:set var="full_date" value="${row123.full_date}" scope="request"/>
            </c:otherwise>
        </c:choose>


    </c:forEach>

    <%
        if (!((String) request.getAttribute("full_date")).equals("never")) {

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
                request.setAttribute("last_active", "moments ago");
            }
            else {
                request.setAttribute("last_active", p.format(dateObject));
            }
        }
        else {
            request.setAttribute("last_active", "never");
        }


    %>


    <c:choose>
    <c:when test="${loop.index==0}">
    <div class="container mt-5" style="margin-top: -45px" id="${row.email}">
        </c:when>
        <c:when test="${fn:length(result.rows)==loop.index+1}">
        <div class="container mt-5" style="padding-bottom: 45px" id="${row.email}">

            </c:when>
            <c:otherwise>
            <div class="container mt-5" id="${row.email}">
                </c:otherwise>
                </c:choose>
                <div class="row d-flex justify-content-center">
                    <div class="col-md-12">
                        <div class="card p-3">
                            <div class="d-flex justify-content-between align-items-center">
                                <div style="font-size:130%;width: 57rem;"
                                     class="user d-flex flex-row align-items-lg-start"><img style="height: 3rem"
                                                                                            src="profile-pictures?id=${row.profile_picture_name}"
                                                                                            width="45"
                                                                                            class="user-img  mr-2"
                                                                                            alt="profile_picture">
                                    <span><small id="username_${row.email}"
                                                 class="font-weight-bold text-primary"><c:out
                                            value='${row.user_name}'/></small>
                         <small class="text-info" style="display:inline;font-weight:bold">(${row.email})</small>

                                    <br>

        <sql:query var="result2"
                   dataSource="${db}">SELECT DISTINCT ip FROM ip_email WHERE email = (SELECT email FROM users WHERE user_name=?)<sql:param
                value='${row.user_name}'/>
        </sql:query>






        <c:set var="blocked" value="false"/>
        <c:set var="ip_exist" value="false"/>

        <c:forEach var="row1" items="${result2.rows}">
            <c:set var="ip_exist" value="true"/>

            <sql:query var="result3"
                       dataSource="${db}">SELECT ip FROM blocked_ips WHERE ip=?<sql:param
                    value='${row1.ip}'/>

            </sql:query>
            <c:forEach var="row3" items="${result3.rows}">
                <c:set var="blocked" value="true"/>

            </c:forEach>


        </c:forEach>



                                <small style="font-size: 100%" class="font-weight-bold text-warning">
                                    <c:choose>
                                        <c:when test="${fn:length(result2.rows)==0}">
                                            No IP
                                        </c:when>
                                        <c:when test="${fn:length(result2.rows)==1}">
                                            IP:
                                        </c:when>
                                        <c:otherwise>
                                            IPs:
                                        </c:otherwise>
                                    </c:choose>

                                            <c:forEach var="row1" items="${result2.rows}" varStatus="loop1">
                                                <c:choose>
                                                    <c:when test="${fn:length(result2.rows)!=loop1.index+1}">
                                                        ${row1.ip},

                                                    </c:when>
                                                    <c:otherwise>
                                                        ${row1.ip}

                                                    </c:otherwise>
                                                </c:choose>

                                            </c:forEach>
                                </small>
                            </span></div>
                                <c:choose>
                                    <c:when test="${last_active=='never'}">
                                        <small class="date">${last_active}</small>
                                    </c:when>
                                    <c:otherwise>
                                        <small data-toggle="tooltip" data-placement="top" title="${my_date}, ${date}"
                                               class="date">${last_active}</small>
                                    </c:otherwise>
                                </c:choose>

                            </div>
                            <div class="action d-flex mt-1" style=" user-select: none">
                                <c:choose>
                                    <c:when test="${row.is_verified=='1'}">
                                        <button style="margin-left: 0.6rem;margin-top: 0.6rem" id="${row.token}_button"
                                                onclick="my_unverify_account('${row.email}', '${row.token}')"
                                                class="unverify_button btn btn-danger btn-sm">Unverify Account
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button style="margin-left: 0.6rem;margin-top: 0.6rem" id="${row.token}_button"
                                                onclick="my_verify_account('${row.email}', '${row.token}')"
                                                class="verify_button btn btn-success btn-sm">Verify Account
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${ip_exist=='true'}">
                                    <c:choose>
                                        <c:when test="${blocked=='false'}">
                                            <button style="margin-left: 0.6rem;margin-top: 0.6rem"
                                                    onclick="my_block_ip('${row.email}', 'block', '${loop.index}')"
                                                    id="block_${loop.index}"
                                                    class="block btn btn-danger btn-sm"> Block IP
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button style="margin-left: 0.6rem;margin-top: 0.6rem"
                                                    onclick="my_block_ip('${row.email}', 'unblock', '${loop.index}')"
                                                    class="unblock btn btn-success btn-sm" id="unblock_${loop.index}">
                                                Unblock IP
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>

                                <button onclick="my_delete_account('<c:out value="${row.email}"/>')"
                                        type="button"
                                        style="margin-left: 0.6rem;margin-top: 0.6rem"
                                        class="btn btn-danger btn-sm">Delete account
                                </button>


                            </div>
                        </div>
                    </div>
                </div>
            </div>


            </c:forEach>


            <script>
              function my_delete_account(email) {
                $("#admin_delete").modal({
                  backdrop: 'static',
                  keyboard: false
                });
                document.getElementById("username_span").innerHTML = document.getElementById(
                    "username_" + email).innerText
                document.getElementById("confirm_delete_account").
                    setAttribute(`onClick`, "on_confirm_delete_account('" + email + "')");

              }

              function on_confirm_delete_account(email) {
                $.post("https://${pageContext.request.serverName}/delete-account?email=" + encodeURIComponent(email))
                document.getElementById(email).remove();
              }

              function my_verify_account(email, token) {
                $.post(
                    "https://${pageContext.request.serverName}/admin-verify-account?email=" + encodeURIComponent(email))
                let my_verify_button = document.getElementById(token + "_button")
                my_verify_button.innerHTML = "Unverify Account"
                my_verify_button.setAttribute(`onClick`, "my_unverify_account('" + email + "', '" + token + "')");
                my_verify_button.classList.remove("btn-success");
                my_verify_button.classList.add("btn-danger");

              }

              function my_unverify_account(email, token) {
                $.post("https://${pageContext.request.serverName}/unverify-account?email=" + encodeURIComponent(email))
                let my_verify_button = document.getElementById(token + "_button")
                my_verify_button.innerHTML = "Verify Account"
                my_verify_button.setAttribute(`onClick`, "my_verify_account('" + email + "', '" + token + "')");
                my_verify_button.classList.add("btn-success");
                my_verify_button.classList.remove("btn-danger");
              }

              function my_block_ip(email, block_unblock, button_id) {
                if (block_unblock === "block") {
                  let block_button = document.getElementById("block_" + button_id)
                  block_button.innerHTML = "Unblock IP"
                  block_button.setAttribute(`onClick`, "my_block_ip('" + email + "', 'unblock', '" + button_id + "')");
                  block_button.classList.remove("btn-danger");
                  block_button.classList.add("btn-success");
                  block_button.setAttribute("id", "unblock_" + button_id);
                }
                else if (block_unblock === "unblock") {
                  let unblock_button = document.getElementById("unblock_" + button_id)
                  unblock_button.innerHTML = "Block IP"
                  unblock_button.setAttribute(`onClick`, "my_block_ip('" + email + "', 'block', '" + button_id + "')");
                  unblock_button.classList.add("btn-danger");
                  unblock_button.classList.remove("btn-success");
                  unblock_button.setAttribute("id", "block_" + button_id);

                }
                $.post("https://${pageContext.request.serverName}/block-ip?email=" + encodeURIComponent(email) +
                    `&block_unblock=\${block_unblock}`);
              }

              $(function() {
                $('[data-toggle="tooltip"]').tooltip()
              })
            </script>
            <div class="modal fade" id="admin_delete">
                <div class="modal-dialog modal-lg">
                    <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                        <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                            <h2 style="color: #ff3e3e" class="modal-title">Delete <span class="no-standup"
                                                                                        id="username_span"></span>'s
                                account?</h2>
                        </div>
                        <div class="modal-body">
                            <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">All the data related to
                                the account will be deleted permanently (files, comments, messages etc.), but the
                                account can always be recovered (NOT the data).</p>
                        </div>
                        <div style="border-top: 1px solid rgb(220, 53, 69);display: flex;justify-content: space-between;"
                             class="modal-footer">
                            <button type="button" class="btn btn-primary no-standup" data-dismiss="modal">Cancel
                            </button>
                            <button id="confirm_delete_account" type="button" class="btn btn-danger no-standup"
                                    data-dismiss="modal">Delete Account
                            </button>

                        </div>
                    </div>
                </div>
            </div>
</body>
</html>
