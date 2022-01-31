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

@WebServlet("/delete-comment")
public class DeleteComment extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!Functions.is_user_admin(Functions.get_admin_code_from_cookie(request), response)) {
            System.out.println("not admin in delete-comment");
            return;
        }
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";
        String comment_id = request.getParameter("comment_id");
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String sql_query = "DELETE FROM comment_likes WHERE id=?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, comment_id);
            preparedStatement.executeUpdate();
            sql_query = "DELETE FROM comments_email WHERE id =?";
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, comment_id);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }
}
