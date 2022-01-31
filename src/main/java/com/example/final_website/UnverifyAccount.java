package com.example.final_website;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/unverify-account")
public class UnverifyAccount extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String token = Functions.get_token_with_email(email);
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";
        if (Functions.get_admin_code_from_cookie(request) != null) {
            if (!Functions.is_user_admin(Functions.get_admin_code_from_cookie(request), response)) {
                System.out.println("not admin in unverify-account");
                return;
            }
        }
        else {
            System.out.println("not admin in unverify-account");
            return;
        }

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            String sql_query = "UPDATE users SET is_verified = '0' WHERE token = ? AND email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, token);
            preparedStatement.setString(2, email);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }
}
