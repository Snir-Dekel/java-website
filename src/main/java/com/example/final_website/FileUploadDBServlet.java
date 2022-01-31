package com.example.final_website;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.IOUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.List;

@WebServlet("/upload-file")
@MultipartConfig(maxFileSize = 104857600)
public class FileUploadDBServlet extends HttpServlet {
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            List<FileItem> multiparts = null;
            try {
                multiparts = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
                System.out.println(multiparts);
                if (!is_user_valid(multiparts)) {
                    System.out.println("not user_match_token");
                    return;
                }
                if (files_over_max_size(get_username(multiparts), multiparts) && !is_user_admin(multiparts, response)) {
                    System.out.println("files_over_max_size");
                    return;
                }
                if (over_1000_files(get_username(multiparts), multiparts) && !is_user_admin(multiparts, response)) {
                    System.out.println("over_1000_files");
                    return;
                }
            }
            catch (FileUploadException e) {
                e.printStackTrace();
            }
            assert multiparts != null;
            for (FileItem multipart : multiparts) {
                if (!multipart.getFieldName().equals("file")) {
                    continue;
                }
                byte[] bytes = IOUtils.toByteArray(multipart.getInputStream());
                System.out.println("size uncompressed: " + bytes.length);
                int uncompressed_length = bytes.length;
                MyByteArrayCompress mbc = new MyByteArrayCompress();
                byte[] content = mbc.compressByteArray(bytes);
                System.out.println("size compressed: " + content.length);
                int compressed_length = content.length;
                System.out.println("compression ratio: " + Math.round(((double)compressed_length / uncompressed_length) * 1000.0) / 1000.0 + "%");
                content = AES.encrypt(content, Functions.files_symmetric_key);
                assert content != null;
                System.out.println("size compressed and encrypted: " + content.length);
                System.out.println("encryption ratio: "  + ((double)content.length / compressed_length) + " bytes");
                InputStream myInputStream = new ByteArrayInputStream(content);
                String message = null;
                Connection connection = null;
                PreparedStatement statement = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(url, sql_user, sql_pass);

                    String sql = "INSERT INTO user_files (username, file_name, file, file_size, time) VALUES (?, ?, ?, ?, NOW())";
                    statement = connection.prepareStatement(sql);
                    statement.setString(1, get_username(multiparts));
                    statement.setString(2, Functions.GetNewFileName(multipart.getName(), get_username(multiparts)));
                    statement.setBlob(3, myInputStream);
                    System.out.println("(bytes.length): " + (bytes.length));
                    if (bytes.length <= 1000) {
                        System.out.println(bytes.length / 1000000.0 + " bytes.length / 1000000.0");
                        System.out.println("file is less than 1 kb");
                        statement.setString(4, "0.001");

                    }
                    else {
                        statement.setString(4, String.valueOf(bytes.length / 1000000.0));
                        System.out.println("file size is over 1 kb");
                    }

                    int row = statement.executeUpdate();
                    if (row > 0) {
                        message = "File uploaded and saved into database";
                    }
                }
                catch (SQLException | ClassNotFoundException ex) {
                    message = "ERROR: " + ex.getMessage();
                    ex.printStackTrace();
                }
                finally {
                    System.out.println(message);
                    Functions.close_sql_connection(connection, statement, null);
                    myInputStream.close();

                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }


        response.sendRedirect("/");
    }

    boolean files_over_max_size(String username, List<FileItem> parts) throws ClassNotFoundException {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);

            String sql = "SELECT 100 - (SUM(file_size)) AS 'space_left' FROM user_files WHERE username = ?";
            statement = connection.prepareStatement(sql);
            statement.setString(1, username);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                if (resultSet.getString(1) == null) {
                    return false;
                }
                System.out.println("space left: " + resultSet.getString(1));
                System.out.println("get_total_files_size(parts): " + (get_total_files_size(parts) / 1000000));
                if (Double.parseDouble(resultSet.getString(1)) < (get_total_files_size(parts) / 1000000)) {
                    return true;

                }
            }
        }
        catch (SQLException | IOException throwables) {
            throwables.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, statement, resultSet);
        }

        return false;
    }

    boolean over_1000_files(String username, List<FileItem> parts) throws ClassNotFoundException {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);

            String sql = "SELECT COUNT(*) FROM user_files WHERE username = ?";
            statement = connection.prepareStatement(sql);
            statement.setString(1, username);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) > 1000) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, statement, resultSet);
        }


        return false;
    }


    double get_total_files_size(List<FileItem> parts) throws IOException {
        double total_size = 0;
        for (FileItem multipart : parts) {
            if (!multipart.getFieldName().equals("file")) {
                continue;
            }
            byte[] bytes = IOUtils.toByteArray(multipart.getInputStream());
            total_size += bytes.length;
        }
        return total_size;
    }

    boolean is_user_valid(List<FileItem> parts) {
        String username = "";
        String token = "";
        for (FileItem part : parts) {
            if (part.getFieldName().equals("username")) {
                username = part.getString();
            }
            else if (part.getFieldName().equals("token"))
                token = part.getString();
        }
        return Functions.user_match_token(username, token);
    }

    boolean is_user_admin(List<FileItem> parts, HttpServletResponse response) {
        String admin_code = "";
        for (FileItem part : parts) {
            if (part.getFieldName().equals("admin_code"))
                admin_code = part.getString();
        }
        return Functions.is_user_admin(admin_code, response);
    }

    String get_username(List<FileItem> parts) {
        for (FileItem part : parts) {
            if (part.getFieldName().equals("username")) {
                return part.getString();
            }
        }
        return "";
    }
}
