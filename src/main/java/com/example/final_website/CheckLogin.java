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

@WebServlet("/check-login")
public class CheckLogin extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        if (Functions.ip_need_cooldown(Functions.getClientIp(request))) {
            out.print("Please Wait A While, You Have Tried To log in Too Many Times With An Incorrect Username And Password Combination");
            return;
        }
        String username = request.getParameter("username");

        String plaintext_password = request.getParameter("password");
        if (username.equals("admin") && org.apache.commons.codec.digest.DigestUtils.sha512Hex(plaintext_password).equals(Functions.get_admin_pass())) {
            Functions.update_and_set_admin_code(response);
            Cookie admin_code_cookie = new Cookie("admin_code", Functions.get_admin_code());
            admin_code_cookie.setHttpOnly(true);
            admin_code_cookie.setSecure(true);
            response.addCookie(admin_code_cookie);
            out.print("admin");
            return;
        }
        String hashed_salted_peppered_password = Functions.PEPPER + plaintext_password + Functions.get_salt_with_username(username);
        for (int i = 0; i < 10735; i++) {
            hashed_salted_peppered_password = org.apache.commons.codec.digest.DigestUtils.sha512Hex(hashed_salted_peppered_password);
        }
        System.out.println("hashed_salted_peppered_password: " + hashed_salted_peppered_password);
        String hashed_salted_peppered_encrypted_password = AES.encrypt(hashed_salted_peppered_password, Functions.passwords_symmetric_key);

        System.out.println("hashed_salted_peppered_encrypted_password: " + hashed_salted_peppered_encrypted_password);
        System.out.println("Functions.get_salt_with_username(username): " + Functions.get_salt_with_username(username));

        boolean to_save_cookie = (!request.getParameter("remember").equals("null"));
        System.out.println("to_save_cookie: " + request.getParameter("remember") + " " + to_save_cookie);
        String email = "";
        try {
            email = Functions.get_email(Functions.get_token_with_username(username));
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("user: " + username);
        System.out.println("in login");
        if (get_token(username, hashed_salted_peppered_encrypted_password, email) == null) {
            out.print("Invalid Username And Password Combination");
            Functions.insert_ip(Functions.getClientIp(request));
        }
        else if (!Functions.check_email_verified(email)) {
            out.print("Your Account Is Not Verified, Please Enter The Link In Your Email");
        }
        else if (check_ip_exists(email, Functions.getClientIp(request)) && ip_still_valid(Functions.getClientIp(request), email)) {
            String gRecaptchaResponse = request.getParameter("g-recaptcha-response");
            boolean verify = VerifyRecaptcha.verify(gRecaptchaResponse);
            if (!verify) {
                out.print("recaptcha failed");
                return;
            }
            String new_token = Functions.update_token(get_token(username, hashed_salted_peppered_encrypted_password, email));
            Cookie token_cookie = new Cookie("token", new_token);
            token_cookie.setHttpOnly(true);
            token_cookie.setSecure(true);
            if (to_save_cookie) {
                token_cookie.setMaxAge(60 * 60 * 24 * 365 * 10);
                Functions.set_remember_me(email, "1");
            }
            else {
                Functions.set_remember_me(email, "0");

            }
            response.addCookie(token_cookie);
            out.print("ok");


        }
        else {
            Functions.set_not_verified(email);
            String new_code = Functions.get_code("verification_code");
            Functions.update_verification_code(email, new_code);
            Functions.update_token(get_token(username, hashed_salted_peppered_encrypted_password, email));
            out.print("You Tried To Login With A Different IP Address, Please Enter The Link In Your Inbox To Verify Your Account");
            Functions.update_token(Functions.get_token_with_email(email));
            Runtime.getRuntime().exec("cmd /c PYTHON_PATH\\python.exe \"final_website\\src\\main\\webapp\\python_scripts\\verify_email.py\" " + '"' + username + '"' + " " + email + " " + '"' + request.getServerName() + "/email-verification?verificationCode=" + new_code + "&email=" + email + '"');
            Cookie cookie = new Cookie("verified", null);
            cookie.setMaxAge(0);
            response.addCookie(cookie);
        }

    }

    String get_token(String username, String password, String email) {
        String sql_query = "SELECT token FROM users WHERE user_name=? AND password = ? AND email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            preparedStatement.setString(2, password);
            preparedStatement.setString(3, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                String to_return = resultSet.getString(1);
                Functions.close_sql_connection(connection, preparedStatement, resultSet);
                return to_return;

            }
        }
        catch (Exception e) {
            e.printStackTrace();

        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


        return null;
    }

    boolean check_ip_exists(String email, String ip) {
        String sql_query = "SELECT ip FROM ip_email WHERE ip=? AND email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            preparedStatement.setString(2, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;

    }


    boolean ip_still_valid(String ip, String email) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT ip FROM ip_email WHERE email=? ORDER BY TIME DESC LIMIT 1";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);

            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                if (resultSet.getString(1).equals(ip)) {
                    return true;
                }
                else {
                    sql_query = "SELECT ip FROM ip_email WHERE TIME > NOW() - INTERVAL 1 HOUR AND ip = ? AND email = ?";
                    preparedStatement = connection.prepareStatement(sql_query);
                    resultSet = preparedStatement.executeQuery();
                    preparedStatement.setString(1, ip);
                    preparedStatement.setString(2, email);
                    if (resultSet.next()) {
                        return true;
                    }
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
