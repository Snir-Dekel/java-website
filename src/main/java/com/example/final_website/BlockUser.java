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

@WebServlet("/block-user")
public class BlockUser extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        String from_user = request.getParameter("from_user");
        String to_user = request.getParameter("to_user");
        System.out.println(from_user);
        System.out.println(to_user);
        System.out.println("in block user");
        if (!Functions.get_token_with_username(to_user).equals(token)) {
            System.out.println("get_token_with_username failed: " + to_user + " " + token);
            return;
        }
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            String sql_query = "INSERT INTO user_block_messages (from_user, to_user) VALUES (?, ?)";
            Class.forName("com.mysql.cj.jdbc.Driver");

            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, from_user);
            preparedStatement.setString(2, to_user);
            preparedStatement.executeUpdate();
            String sql_query1 = "DELETE FROM messages WHERE from_user=? AND to_user=?";
            preparedStatement = connection.prepareStatement(sql_query1);
            preparedStatement.setString(1, from_user);
            preparedStatement.setString(2, to_user);
            preparedStatement.executeUpdate();

        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);

        }
    }
}
