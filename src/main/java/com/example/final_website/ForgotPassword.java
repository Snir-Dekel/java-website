package com.example.final_website;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/forgot_password")
public class ForgotPassword extends HttpServlet {
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
        try {
            String email = request.getParameter("email");
            String password_reset_code = get_password_reset_code_with_email(email);
            String gRecaptchaResponse = request.getParameter("g-recaptcha-response");
            boolean verify = VerifyRecaptcha.verify(gRecaptchaResponse);
            if (!verify) {
                out.print("recaptcha failed");
                return;
            }
            String ip = Functions.getClientIp(request);
            if (!Functions.can_send_email(email, ip, "password")) {
                out.print("Please wait a while, you are sending emails too fast");
                return;
            }

            if (password_reset_code != null) {
                System.out.println(email);
                if (Functions.can_send_email(email, ip, "password")) {
                    String new_password_reset_code = Functions.change_password_reset_code(password_reset_code);
                    Runtime.getRuntime().exec("cmd /c PYTHON_PATH\\python.exe \"final_website\\src\\main\\webapp\\python_scripts\\reset_password.py\" " + '"' + get_username(email) + '"' + " " + email + " " + '"' + request.getServerName() + "/reset_password.jsp?password_reset_code=" + new_password_reset_code + "&email=" + email + '"');
                    Functions.insert_send_email(email, ip, "password");
                }
                else {
                    System.out.println("can_send_email returned false");
                    out.print("Please wait a while, you are sending emails too fast");
                    return;
                }
            }
            else {
                out.print("This email does not registered in the website");
                Functions.insert_send_email(email, ip, "password");

                return;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        out.print("Check Your Email");

        out.close();

    }

    String get_password_reset_code_with_email(String email) throws ClassNotFoundException, SQLException {
        String sql_query = "SELECT password_reset_code FROM users WHERE email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        String to_return = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();


        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {

            if (resultSet!=null && resultSet.next()) {
                to_return = resultSet.getString(1);

            }
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return to_return;
    }

    String get_username(String email) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            String sql_query = "SELECT user_name FROM users WHERE email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (!resultSet.next()) {
                return null;
            }
            return resultSet.getString(1);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
}
