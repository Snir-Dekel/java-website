package com.example.final_website;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/profile-pictures")
public class GetProfilePicture extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement statement = null;
        ResultSet result = null;
            String sql = "SELECT profile_picture, profile_picture_type FROM profile_pictures WHERE profile_picture_name=?";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, sql_user, sql_pass);
            statement = conn.prepareStatement(sql);
            statement.setString(1, request.getParameter("id"));
            result = statement.executeQuery();
            if (result.next()) {
                String file_type = result.getString("profile_picture_type");
                Blob blob = result.getBlob("profile_picture");
                byte[] bytes = blob.getBytes(1, (int) blob.length());
                response.setContentType("image/" + file_type);
                response.getOutputStream().write(bytes);
            }
        }
        catch (Exception throwables) {
            throwables.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(conn, statement, result);

        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
