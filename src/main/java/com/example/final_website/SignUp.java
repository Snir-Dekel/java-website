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
import java.util.Random;

@WebServlet("/signup")
public class SignUp extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";
    String sql_query = "INSERT INTO users (user_name, password, email, password_reset_code, verification_code, is_verified, is_remember_me, salt, token, profile_picture_name) VALUES (?, ?, ?, ?, ?, '0', '0', ?, ?, ?)";


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        String email = request.getParameter("email");
        if (Functions.user_exist(request.getParameter("username")) || request.getParameter("password").length() < 4 || request.getParameter("username").length() < 4 || request.getParameter("username").length()>20 || request.getParameter("email").length() < 4 || !Functions.isValidEmailAddress(email) || email.contains("'") || request.getParameter("username").contains("`") || request.getParameter("username").contains("\"")) {
            System.out.println("cant signup user");
            out.print("Can Not Signup");
            return;
        }
        else if (Functions.ip_exist_signup(Functions.getClientIp(request))) {
             out.print("You Already have An Account");
            return;
        }
        System.out.println("in SignUp");
        String gRecaptchaResponse = request.getParameter("g-recaptcha-response");
        boolean verify = VerifyRecaptcha.verify(gRecaptchaResponse);
        if (!verify) {
            out.print("<font color=red>Not Verified");
            return;
        }
             Connection connection = null;
            PreparedStatement preparedStatement = null;

        try {

            String username = request.getParameter("username");
            String verification_code = Functions.get_code("verification_code");
            String salt = Functions.get_code("salt");
            String plaintext_password = request.getParameter("password");
            String hashed_salted_peppered_password = Functions.PEPPER + plaintext_password + salt;
            for (int i = 0; i < 10735; i++) {
                hashed_salted_peppered_password = org.apache.commons.codec.digest.DigestUtils.sha512Hex(hashed_salted_peppered_password);
            }
            String hashed_salted_peppered_encrypted_password = AES.encrypt(hashed_salted_peppered_password, Functions.passwords_symmetric_key);
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            preparedStatement.setString(2, hashed_salted_peppered_encrypted_password);
            preparedStatement.setString(3, email);
            preparedStatement.setString(4, Functions.get_code("password_reset_code"));
            preparedStatement.setString(5, verification_code);
            preparedStatement.setString(6, salt);
            preparedStatement.setString(7, Functions.get_code("token"));
            preparedStatement.setString(8, "logo" + (new Random().nextInt(7) + 1));
            preparedStatement.executeUpdate();
            Runtime.getRuntime().exec("cmd /c PYTHON_PATH\\python.exe \"final_website\\src\\main\\webapp\\python_scripts\\sign_up.py\" " + '"' + username + '"' + " " + email + " " + '"' + request.getServerName() + "/email-verification?verificationCode=" + verification_code + "&email=" + email + '"');
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
        out.print("Signup Completed! Please Check Your Email To Verify Your Account");

        Functions.insert_signup_ip(Functions.getClientIp(request));
    }


}
