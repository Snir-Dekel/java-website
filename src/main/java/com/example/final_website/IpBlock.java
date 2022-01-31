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

@WebServlet("/block-ip")
public class IpBlock extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String block_unblock = request.getParameter("block_unblock");
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";

        if (Functions.get_admin_code_from_cookie(request) != null) {
            if (!Functions.is_user_admin(Functions.get_admin_code_from_cookie(request), response)) {
                System.out.println("not admin in IpBlock servlet, code: " + Functions.get_admin_code_from_cookie(request));
                return;
            }
        }
        else {
            return;
        }
        System.out.println("successfully " +  block_unblock  + " email:"+ email );

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        String sql_query = "SELECT ip FROM ip_email WHERE email = ?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        if (block_unblock.equals("block")) {
            while (true) {
                try {
                    if (!resultSet.next()) {
                        break;
                    }
                    String ip = resultSet.getString(1);

                    sql_query = "INSERT INTO blocked_ips (ip) VALUES (?);";

                    connection = DriverManager.getConnection(url, sql_user, sql_pass);
                    preparedStatement = connection.prepareStatement(sql_query);
                    preparedStatement.setString(1, ip);
                    preparedStatement.executeUpdate();
                }
                catch (Exception e) {
                    e.printStackTrace();
                    break;
                }
            }

        }
        else if (block_unblock.equals("unblock")) {

            while (true) {
                try {
                    if (!resultSet.next()){
                        break;
                    }
                    String ip = resultSet.getString(1);
                    sql_query = "DELETE FROM blocked_ips WHERE ip=?";
                    connection = DriverManager.getConnection(url, sql_user, sql_pass);
                    preparedStatement = connection.prepareStatement(sql_query);
                    preparedStatement.setString(1, ip);
                    preparedStatement.executeUpdate();
                }
                catch (Exception e) {
                    e.printStackTrace();
                    break;
                }
            }

        }
                    Functions.close_sql_connection(connection, preparedStatement, resultSet);

    }
}
