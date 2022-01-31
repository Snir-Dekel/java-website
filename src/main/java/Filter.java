import com.example.final_website.Functions;

import javax.servlet.*;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class Filter implements javax.servlet.Filter {

    static void update_last_active(String username) {
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        try {
            String sql_query = "INSERT INTO last_active (username, time) VALUES(?, now()) ON DUPLICATE KEY UPDATE\n" +
                    "username=?, time=now()";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            preparedStatement.setString(2, username);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
    }

    public void init(FilterConfig arg0) {
    }

    public void doFilter(ServletRequest req, ServletResponse resp,
                         FilterChain chain) throws IOException, ServletException {
        Cookie[] cookies = ((HttpServletRequest) req).getCookies();
        String token = null;
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("token")) {
                    token = cookie.getValue();
                }
            }
        }
        if (token != null) {
            String username = Functions.get_username_from_token(token);
            if (username != null) {
                System.out.println(username + " requested: " + ((((HttpServletRequest) req).getRequestURL().toString().substring(25).length()) == 0 ? "welcome.jsp" : ((HttpServletRequest) req).getRequestURL().toString().substring(25)));
                update_last_active(username);
            }
        }


        if (!Functions.check_ip_blocked(Functions.getClientIp((HttpServletRequest) req))) {
            chain.doFilter(req, resp);
        }
        else {
            resp.setContentType("text/html; charset=UTF-8");
            PrintWriter out = resp.getWriter();

            System.out.println(Functions.getClientIp((HttpServletRequest) req) + " is banned from the website");
            out.print("<!doctype html>\n" +
                    "<html lang=\"en\">\n" +
                    "<head>\n" +
                    "    <title>● IP Ban</title>\n" +
                    "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                    "\n" +
                    "    <style>\n" +
                    "        * {\n" +
                    "            font-size: 55px;\n" +
                    "            font-family: Arial, Helvetica, sans-serif;\n" +
                    "            background: rgb(33,37,41);\n" +
                    "            color: rgb(225, 225, 225);\n" +
                    "        }\n" +
                    "\n" +
                    "        html, body {\n" +
                    "            max-width: 100%;\n" +
                    "            max-height: 100%;\n" +
                    "            overflow: hidden;\n" +
                    "        }\n" +
                    "    </style>\n" +
                    "</head>\n" +
                    "<body>\n" +
                    "    <h1 style=\"margin-top: 5px;font-weight: bold\">Sorry, your IP address: " + Functions.getClientIp((HttpServletRequest) req) + " has been blocked by the admin of the website from gaining access to the website.\n" + "</h1>\n" +
                    "</body>\n" +
                    "</html>");
        }

    }

    public void destroy() {
    }
}