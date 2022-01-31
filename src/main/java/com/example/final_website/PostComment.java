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
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/post-comment")
public class PostComment extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String comment = request.getParameter("comment");
        String token = request.getParameter("token");
        String username = request.getParameter("username");
        String email = Functions.get_email(token);
        System.out.println(comment);
        System.out.println(username);
        System.out.println(email);
        if (comment.length() > 300 || comment.trim().length() < 4) {
            System.out.println("comment too long or too short, comment length trimmed: " + comment.trim().length());
            return;
        }
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        ResultSet resultSet2 = null;
        try {
            String sql_query = "SELECT comment FROM comments_email WHERE TIME > NOW() - INTERVAL 10 SECOND AND email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");

            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            sql_query = "SELECT COUNT(*) FROM comments_email WHERE TIME > NOW() - INTERVAL 10 MINUTE AND username=?";
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            resultSet2 = preparedStatement.executeQuery();
            resultSet2.next();
            System.out.println(resultSet2.getString(1));
            if (!resultSet.next() && Integer.parseInt(resultSet2.getString(1)) <= 20) {
                System.out.println("comment posted");
                sql_query = "INSERT INTO comments_email (comment, username, email, is_admin, time, id) VALUES (?, ?, ?, ?, NOW(), ?)";
                preparedStatement = connection.prepareStatement(sql_query);
                preparedStatement.setString(1, comment);
                preparedStatement.setString(2, username);
                preparedStatement.setString(3, email);
                if (Functions.get_admin_code_from_cookie(request) == null) {
                    preparedStatement.setString(4, "0");
                }
                else {
                    if (Functions.is_user_admin(Functions.get_admin_code_from_cookie(request), response)) {
                        preparedStatement.setString(4, "1");
                    }
                    else {
                        preparedStatement.setString(4, "0");
                    }
                }
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
                LocalDateTime now = LocalDateTime.now();
                preparedStatement.setString(5, org.apache.commons.codec.digest.DigestUtils.sha512Hex(username + dtf.format(now)));

                preparedStatement.executeUpdate();

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
            Functions.close_sql_connection(connection, preparedStatement, resultSet2);
        }
    }


}
