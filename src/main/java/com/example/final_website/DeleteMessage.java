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

@WebServlet("/delete-message")
public class DeleteMessage extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        String to_user = request.getParameter("username");
        System.out.println(to_user);
        if (!Functions.user_match_token(to_user, token)) {
            System.out.println("not user_match_token");
            return;
        }

        String time = request.getParameter("time");

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "DELETE FROM messages WHERE to_user=? AND TIME=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, to_user);
            preparedStatement.setString(2, time);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }
}
