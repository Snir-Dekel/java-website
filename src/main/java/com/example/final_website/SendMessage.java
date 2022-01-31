package com.example.final_website;

import org.unbescape.html.HtmlEscape;

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

@WebServlet("/send-message")
public class SendMessage extends HttpServlet {
    static String url = "jdbc:mysql://localhost:3306/login_website";
    static String sql_user = "USER";
    static String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String message = request.getParameter("message");
        String token = request.getParameter("token");
        String from_user = request.getParameter("from_user");
        String to_user = request.getParameter("to_user");
        String email = Functions.get_email(token);
        System.out.println(message);
        System.out.println(from_user);
        System.out.println(to_user);
        System.out.println(email);
        System.out.println("in send message");
        try {
            if (!Functions.get_token_with_username(HtmlEscape.unescapeHtml(from_user)).equals(token)) {
                System.out.println("get_token_with_username failed: " + to_user + " " + token);
                return;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        if (Functions.user_blocked(from_user, to_user)) {
            System.out.println("user is blocked from sending messages");
            return;
        }

        if (message.length() > 1000 || message.length() < 4) {
            System.out.println("message too long or too short");
            return;
        }


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        ResultSet resultSet2 = null;
        try {
            String sql_query = "SELECT message FROM messages WHERE TIME > NOW() - INTERVAL 10 SECOND AND from_user=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, from_user);
            resultSet = preparedStatement.executeQuery();
            sql_query = "SELECT COUNT(*) FROM messages WHERE TIME > NOW() - INTERVAL 10 MINUTE AND from_user=?";
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, from_user);
            resultSet2 = preparedStatement.executeQuery();
            resultSet2.next();
            System.out.println(resultSet2.getString(1) + "resultSet2.getString(1)");
            if (!resultSet.next() && Integer.parseInt(resultSet2.getString(1)) <= 20) {
                System.out.println("message sent");
                String sql_query1 = "INSERT INTO messages (message, from_user, to_user,is_admin, time) VALUES (?, ?, ?, ?, NOW())";
                preparedStatement = connection.prepareStatement(sql_query1);
                preparedStatement.setString(1, message);
                preparedStatement.setString(2, from_user);
                preparedStatement.setString(3, to_user);
                if (Functions.get_admin_code_from_cookie(request) == null) {
                    preparedStatement.setString(4, "0");
                }
                else {
                    if (Functions.is_user_admin(Functions.get_admin_code_from_cookie(request), response)) {
                        preparedStatement.setString(4, "1");
                    }
                }

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
