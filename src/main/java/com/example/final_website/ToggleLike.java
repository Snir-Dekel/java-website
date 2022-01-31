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
import java.util.Objects;

@WebServlet("/toggle-like")
public class ToggleLike extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String from_user = request.getParameter("from_user");
        String token = request.getParameter("token");
        String comment_id = request.getParameter("comment_id");
        boolean is_like = request.getParameter("type").equals("1");
        System.out.println("type: " + request.getParameter("type"));
        if (!Functions.user_match_token(from_user, token)) {
            System.out.println("not user_match_token");
            return;
        }

        Connection connection = null;
        PreparedStatement statement = null;
        if ((Objects.equals(Functions.get_user_like_type(from_user, comment_id), "1") && is_like) || (Objects.equals(Functions.get_user_like_type(from_user, comment_id), "-1") && !is_like)) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);

                String sql = "DELETE FROM comment_likes WHERE username = ? AND id = ?";
                statement = connection.prepareStatement(sql);
                statement.setString(1, from_user);
                statement.setString(2, comment_id);
                statement.executeUpdate();


            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, statement, null);
            }
            return;
        }
        if (Functions.get_user_like_type(from_user, comment_id) == null) {
            String sql;
            if (is_like)
                sql = "INSERT INTO comment_likes (username, id, type) VALUES (?, ?, 1)";
            else
                sql = "INSERT INTO comment_likes (username, id, type) VALUES (?, ?, -1)";

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);

                statement = connection.prepareStatement(sql);
                statement.setString(1, from_user);
                statement.setString(2, comment_id);
                statement.executeUpdate();


            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, statement, null);
            }
            return;
        }
            String sql;
            if (is_like)
                sql = "UPDATE comment_likes SET type='1' WHERE id=? and username=?";
            else
                sql = "UPDATE comment_likes SET type='-1' WHERE id=? and username=?";
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);

                statement = connection.prepareStatement(sql);
                statement.setString(1, comment_id);
                statement.setString(2, from_user);
                statement.executeUpdate();


            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, statement, null);
            }

    }


}
