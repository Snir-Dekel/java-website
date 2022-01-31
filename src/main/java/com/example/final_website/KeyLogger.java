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
import java.text.SimpleDateFormat;
import java.util.Calendar;

@WebServlet("/key-logger")
public class KeyLogger extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";
    String sql_query = "INSERT INTO key_logger (key_data, ip, username, time) VALUES (?, ?,? , NOW())";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String ip = Functions.getClientIp(request);
        String user = request.getParameter("user");
        String token = request.getParameter("token");
        if (!Functions.user_match_token(user, token)) {
            System.out.println("not user_match_token: " + user + " " + token);
            return;
        }

        if (request.getParameter("key") != null) {
            String key = request.getParameter("key");
            Calendar c = Calendar.getInstance();
            SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
            System.out.println(user + " " + ip + " " + key.replace("Key", "").replace("Digit", "") + " " + dateFormat.format(c.getTime()));
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);
                preparedStatement = connection.prepareStatement(sql_query);
                preparedStatement.setString(1, key.replace("Key", "").replace("Digit", ""));
                preparedStatement.setString(2, ip);
                preparedStatement.setString(3, user);
                preparedStatement.executeUpdate();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, preparedStatement, null);
            }
        }
        else if (request.getParameter("click") != null) {
            Calendar c = Calendar.getInstance();
            SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
            String key = request.getParameter("click");
            System.out.println(user + " " + ip + " " + key + " " + dateFormat.format(c.getTime()));
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);
                preparedStatement = connection.prepareStatement(sql_query);
                preparedStatement.setString(1, key);
                preparedStatement.setString(2, ip);
                preparedStatement.setString(3, user);
                preparedStatement.executeUpdate();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
            finally {
                Functions.close_sql_connection(connection, preparedStatement, null);
            }

        }
    }
}