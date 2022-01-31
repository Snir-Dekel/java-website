package com.example.final_website;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/email-verification")
public class EmailVerification extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (Functions.check_email_verified(request.getParameter("email"))) {

            out.println("<HTML><HEAD><TITLE>● You Are Already Verified</TITLE>" + "<link rel=icon type=image/png href=logo.png>" +
                    "</HEAD><BODY><font size=50px>You Are Already Verified</BODY></HTML>");
            return;
        }
        else if (!Functions.code_exists(request.getParameter("verificationCode"), "verification_code")) {
            out.println("<HTML><HEAD><TITLE>● Verification Code Is Not Valid</TITLE>" + "<link rel=icon type=image/png href=logo.png>" +
                    "</HEAD><BODY><font size=50px>Verification Code Is Not Valid</BODY></HTML>");
            return;
        }
        else if (ip_need_cooldown(Functions.getClientIp(request))) {
            out.println("<HTML><HEAD><TITLE>● Verification Failed</TITLE>" + "<link rel=icon type=image/png href=logo.png>" +
                    "</HEAD><BODY><font size=50px>Verification Failed-You Are Verifying Accounts Too Fast, Please Wait A While</BODY></HTML>");
            return;
        }
        else if (!Functions.can_verify_account(request) || Functions.ip_exist_verify(Functions.getClientIp(request))) {
            out.print("<html>\n" +
                    "<head>\n" +
                    "    <title>● Verification failed</title>\n" +
                    "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                    "    <style>\n" +
                    "        * {\n" +
                    "            background: #2a324b;\n" +
                    "            font-size: 55px;\n" +
                    "            font-family: Arial, Helvetica, sans-serif;\n" +
                    "        }\n" +
                    "\n" +
                    "        h1 {\n" +
                    "            color: rgb(225, 225, 225);\n" +
                    "        }\n" +
                    "\n" +
                    "        a:hover {\n" +
                    "            color: #0aceff;\n" +
                    "        }\n" +
                    "\n" +
                    "        a {\n" +
                    "            color: #0689c6;\n" +
                    "        transition-duration: 0.2s;}\n" +
                    "    </style>\n" +
                    "</head>\n" +
                    "<body>\n" +
                    "    <h1>You cant verify another account, because you already have one!\n" +
                    "    " +
                    "</body>\n" +
                    "</html>\n");
            return;
        }
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "UPDATE users SET is_verified = '1' WHERE verification_code = ? AND email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            String verificationCode = request.getParameter("verificationCode");
            String email = request.getParameter("email");
            System.out.println("email is: " + email);
            preparedStatement.setString(1, verificationCode);
            preparedStatement.setString(2, email);
            System.out.println("IP: " + Functions.getClientIp(request));
            if (preparedStatement.executeUpdate() <= 0) {
                throw new Exception("Can Not Update Table, verificationCode [" + verificationCode + "] does not match the email [" + email + "]");
            }
            Functions.insert_ip_email(email, Functions.getClientIp(request));
            Functions.insert_verified_ip(Functions.getClientIp(request));
            Cookie verification_code_cookie = new Cookie("verified", "snirdekel.com");
            verification_code_cookie.setMaxAge(60 * 60 * 24 * 365 * 10);
            response.addCookie(verification_code_cookie);
            response.sendRedirect("login.jsp");
            update_verification_code(email);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }


    void update_verification_code(String email) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "UPDATE users SET verification_code = ? WHERE email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, Functions.get_code("verification_code"));
            preparedStatement.setString(2, email);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }

    boolean ip_need_cooldown(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT COUNT(*) FROM ip_email WHERE TIME > now() - INTERVAL 1 HOUR AND ip=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) > 10) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return false;
    }
}
