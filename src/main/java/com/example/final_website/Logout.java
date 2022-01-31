package com.example.final_website;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/logout")
public class Logout extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String sql_query = "SELECT token FROM users WHERE token=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, request.getParameter("token"));
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                Cookie token_cookie = new Cookie("token", null);
                token_cookie.setMaxAge(0);
                response.addCookie(token_cookie);
                response.sendRedirect("login.jsp");

            }
        }
        catch (Exception e) {
            e.printStackTrace();

        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
