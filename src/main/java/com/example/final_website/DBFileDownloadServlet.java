package com.example.final_website;

import org.apache.commons.io.IOUtils;
import org.unbescape.html.HtmlEscape;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.Arrays;
import java.util.Base64;

@WebServlet("/download-file")
public class DBFileDownloadServlet extends HttpServlet {

    private static final int BUFFER_SIZE = 4096;
    String url = "jdbc:mysql://localhost:3306/login_website";
    String sql_user = "USER";
    String sql_pass = "YOUR_PASSWORD";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        String username = HtmlEscape.unescapeHtml(request.getParameter("username"));
        String token = request.getParameter("token");
        System.out.println(username);
        if (!Functions.user_match_token(username, token)) {
            System.out.println("not user_match_token");
            return;
        }
        String files_names = request.getParameter("file_name");
        System.out.println("files_names: " + files_names);
        System.out.println(Arrays.toString(files_names.split("\\|")));
        for (String str : files_names.split("\\|")) {
            Connection conn = null;

            PreparedStatement statement = null;
            ResultSet result = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, sql_user, sql_pass);

                String sql = "SELECT file, file_name FROM user_files WHERE file_name=? AND username=?";
                statement = conn.prepareStatement(sql);
                statement.setString(1, str);
                statement.setString(2, username);

                result = statement.executeQuery();
                if (result.next()) {
                    String fileName = result.getString("file_name");
                    Blob blob = result.getBlob("file");
                    InputStream inputStream = blob.getBinaryStream();
                    assert inputStream != null;
                    byte[] bytes = IOUtils.toByteArray(inputStream);
                    bytes = AES.decrypt(bytes, Functions.files_symmetric_key);
                    assert bytes != null;
                    System.out.println(bytes.length);
                    MyByteArrayDecompress mba = new MyByteArrayDecompress();
                    byte[] decom = mba.decompressByteArray(bytes);
                    inputStream = new ByteArrayInputStream(decom);


                    int fileLength = inputStream.available();

                    System.out.println("fileLength = " + fileLength);

                    ServletContext context = getServletContext();

                    String mimeType = context.getMimeType(fileName);
                    if (mimeType == null) {
                        mimeType = "application/octet-stream";
                    }

                    response.setContentType(mimeType);
                    response.setContentLength(fileLength);
                    String headerKey = "Content-Disposition";
                    String base64_file_name = Base64.getEncoder().encodeToString(fileName.getBytes(StandardCharsets.UTF_8));
                    String headerValue = "attachment; filename==?UTF-8?B?" + base64_file_name;
                    response.setHeader(headerKey, headerValue);

                    OutputStream outStream = response.getOutputStream();

                    byte[] buffer = new byte[BUFFER_SIZE];
                    int bytesRead = -1;

                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outStream.write(buffer, 0, bytesRead);
                    }

                    inputStream.close();
                    outStream.close();
                }
                else {
                    System.out.println("no file found");
                }
            }
            catch (SQLException ex) {
                ex.printStackTrace();
                response.getWriter().print("SQL Error: " + ex.getMessage());
            }
            catch (IOException ex) {
                ex.printStackTrace();
                response.getWriter().print("IO Error: " + ex.getMessage());
            }
            catch (ClassNotFoundException e) {
                e.printStackTrace();
            } finally {
                Functions.close_sql_connection(conn, statement, result);
            }
        }
    }
}