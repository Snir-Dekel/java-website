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
import java.util.Arrays;

@WebServlet("/delete-file")
public class DeleteFile extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = HtmlEscape.unescapeHtml(request.getParameter("username"));
        String token = request.getParameter("token");
        if (!Functions.user_match_token(username, token)) {
            System.out.println("not user_match_token");
            return;
        }
        String files_names = request.getParameter("file_name");
        System.out.println(Arrays.toString(files_names.split("\\|")));
        for (String str : files_names.split("\\|")) {
            Connection connection = null;
            PreparedStatement preparedStatement = null;

            try {
                String sql_query = "DELETE FROM user_files WHERE file_name=? AND username=?";
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, sql_user, sql_pass);
                preparedStatement = connection.prepareStatement(sql_query);
                preparedStatement.setString(1, str);
                preparedStatement.setString(2, username);
                preparedStatement.executeUpdate();
            }
            catch (Exception e) {
                e.printStackTrace();
            } finally {
                Functions.close_sql_connection(connection, preparedStatement, null);
            }

        }

    }
}
