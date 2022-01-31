package com.example.final_website;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/reset_password")
public class ResetPassword extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doPost(request, response);


    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws
            ServletException, IOException {

        String new_password = request.getParameter("new-password");
        if (new_password.length()<4){
            System.out.println("password too short");
            return;
        }
        String password_reset_code = request.getParameter("password_reset_code");
        new_password = Functions.PEPPER + new_password + Functions.get_salt_with_password_reset_code(password_reset_code);
        for (int i = 0; i < 10735; i++) {
            new_password = org.apache.commons.codec.digest.DigestUtils.sha512Hex(new_password);
        }
        new_password = AES.encrypt(new_password, Functions.passwords_symmetric_key);

        if (!Functions.link_valid(request.getParameter("email"), "password") || !Functions.link_valid_password(request.getParameter("email"), request.getParameter("password_reset_code"))) {
            System.out.println("email: " + request.getParameter("email"));
            System.out.println("link is not valid");
            System.out.println(Functions.get_email_with_password_reset_code(password_reset_code));
            return;
        }
        System.out.println("password_reset_code, :" + password_reset_code);
        System.out.println("new_password: " + new_password);
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "UPDATE users SET password = ? WHERE password_reset_code = ?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, new_password);
            preparedStatement.setString(2, password_reset_code);

            if (preparedStatement.executeUpdate() <= 0) {
                throw new Exception("can not update table, password_reset_code is invalid");
            }
            Functions.change_password_reset_code(password_reset_code);
            System.out.println("password changed");
            out.print("ok");

        }
        catch (Exception e) {
            e.printStackTrace();
            out.print("password reset code is invalid");
            System.out.println("cant reset password: password reset code is invalid");
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }




}
