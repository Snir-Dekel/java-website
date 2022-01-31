package com.example.final_website;


import okhttp3.*;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.imageio.ImageIO;
import javax.mail.internet.InternetAddress;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class Functions {
    static final String url = "jdbc:mysql://localhost:3306/login_website";
    static final String sql_user = "USER";
    static final String sql_pass = "YOUR_PASSWORD";
    static final String PEPPER = "RANDOM_LONG_STRING";
    static final String passwords_symmetric_key = "RANDOM_LONG_STRING";
    static final String files_symmetric_key = "RANDOM_LONG_STRING";

    public static boolean email_exists(String email) {
        String sql_query = "SELECT * FROM users WHERE email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return false;
    }

    public static String get_code(String code_type) {
        String[] chars = new String[]{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
        Random rnd = new Random();
        String code;
        do {
            code = "";
            for (int i = 0; i < 100; i++) {
                code += chars[rnd.nextInt(chars.length)];
            }
        } while (code_exists(code, code_type));

        return code;

    }

    static boolean code_exists(String code, String code_type) {
        String sql_query = "SELECT verification_code FROM users WHERE " + code_type + "=?";
        if (code_type.equals("admin_code")){
            sql_query = "SELECT code FROM admin_data WHERE code=?";
        }
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, code);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }

    public static String getClientIp(HttpServletRequest request) {

        String remoteAddr = "";

        if (request != null) {
            remoteAddr = request.getHeader("X-FORWARDED-FOR");
            if (remoteAddr == null || "".equals(remoteAddr)) {
                remoteAddr = request.getRemoteAddr();
            }
        }
        if (remoteAddr.contains(",")) {
            remoteAddr = remoteAddr.split(",")[1];
        }
        return remoteAddr;
    }

    public static void set_not_verified(String email) {
        String sql_query = "UPDATE users SET is_verified = '0' WHERE email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }


    }
    public static void set_remember_me(String email, String zero_or_one) {
        String sql_query = "UPDATE users SET is_remember_me = " + zero_or_one + " WHERE email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
    }
      public static boolean is_remember_me(String token) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "SELECT is_remember_me FROM users WHERE token=?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, token);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (resultSet.getString(1).equals("1")) {
                    return true;
                }

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }
      public static boolean is_user_admin(String code, HttpServletResponse response) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "SELECT code FROM admin_data WHERE code=?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, code);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }
        public static void update_and_set_admin_code(HttpServletResponse response) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String new_code = Functions.get_code("admin_code");
        try {
            String sql_query = "UPDATE admin_data SET code = ?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, new_code);
            preparedStatement.executeUpdate();


        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
        Cookie cookie = new Cookie("admin_code", new_code);
        cookie.setHttpOnly(true);
        cookie.setSecure(true);
        response.addCookie(cookie);
    }
  public static String get_admin_code() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "SELECT code FROM admin_data";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
 static String get_admin_pass() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "SELECT password FROM admin_data";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
      public static String get_admin_code_from_cookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("admin_code")) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
    public static void update_verification_code(String email, String code) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "UPDATE users SET verification_code = ? WHERE email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, code);
            preparedStatement.setString(2, email);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }

    static boolean check_email_verified(String email) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT is_verified FROM users WHERE email=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (resultSet.getString(1).equals("1")) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return false;
    }
public static boolean check_ip_blocked(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT ip FROM blocked_ips WHERE ip=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                    return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return false;
    }
    public static boolean user_exist(String username) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT user_name FROM users WHERE user_name=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }

        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


        return false;
    }

    public static boolean user_match_token(String username, String token) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT user_name FROM users WHERE user_name=? AND token=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            preparedStatement.setString(2, token);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }

        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


        return false;
    }

    static String get_email(String token) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "SELECT email FROM users WHERE token=?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, token);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }

    static String get_email_from_deleted_users(String verification_code) {
        String sql_query = "SELECT email FROM deleted_users WHERE verification_code=?";


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, verification_code);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


        return null;
    }

    static String get_username(String email) {
        String sql_query = "SELECT user_name FROM deleted_users WHERE email=?";

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }

    static String get_username_from_users(String email) {
        String sql_query = "SELECT user_name FROM users WHERE email=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return null;
    }

    static String get_verification_code(String email) {
        String sql_query = "SELECT verification_code FROM deleted_users WHERE email=?";


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return null;
    }
    public static String update_token(String token) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        String new_token = Functions.get_code("token");
        try {
            String sql_query = "UPDATE users SET token = ? WHERE token=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, new_token);
            preparedStatement.setString(2, token);
            preparedStatement.executeUpdate();


        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return new_token;

    }
    public static String get_token_with_email(String email) {
        String sql_query = "SELECT token FROM users WHERE email=?";


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
    static String get_token_with_username(String username) {
        String sql_query = "SELECT token FROM users WHERE user_name=?";


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
    static String get_salt_with_username(String username) {
        String sql_query = "SELECT salt FROM users WHERE user_name=?";


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, username);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
    static void insert_ip_email(String email, String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "INSERT INTO ip_email (ip, email, time) VALUES (?, ?, now())";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            preparedStatement.setString(2, email);
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("HH:mm:ss");
            LocalDateTime now = LocalDateTime.now();
            System.out.println("preparedStatement.executeUpdate();" + preparedStatement.executeUpdate() + " " + dtf.format(now));
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }

    }


    static void insert_ip(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "INSERT INTO ip_data_base (ip, time) VALUES (?, now());";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
    }

    static void insert_verified_ip(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "INSERT INTO verified_ip (ip, time) VALUES (?, now())";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
    }
    static void insert_signup_ip(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            String sql_query = "INSERT INTO signup_ip (ip, time) VALUES (?, now())";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }
    }
    static boolean ip_exist_verify(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT COUNT(*) FROM verified_ip WHERE ip=? AND TIME > NOW() - INTERVAL 1 MONTH";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) > 15) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }
    static boolean ip_exist_signup(String ip) {

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT COUNT(*) FROM signup_ip WHERE ip=? AND TIME > NOW() - INTERVAL 1 MONTH";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) >= 15) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }
    static boolean can_verify_account(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("verified") && cookie.getValue().equals("snirdekel.com")) {
                    return false;
                }
            }
        }
        return true;
    }

    static boolean ip_need_cooldown(String ip) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "SELECT COUNT(*) FROM ip_data_base WHERE TIME > now() - INTERVAL 1 HOUR AND ip=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) > 10) {
                    return true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }

    static boolean isValidEmailAddress(String email) {
        boolean result = true;
        try {
            InternetAddress emailAddr = new InternetAddress(email);
            emailAddr.validate();
        }
        catch (javax.mail.internet.AddressException ex) {
            result = false;
        }
        return result;
    }

    public static boolean user_blocked(String from_user, String to_user) {
        String sql_query = "SELECT * FROM user_block_messages WHERE from_user=? AND to_user=?";

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, from_user);
            preparedStatement.setString(2, to_user);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }

        return false;
    }

    public static String GetNewFileName(String fileName, String userName) {
        String sql_query = "SELECT file_name FROM user_files WHERE username=?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, userName);
            resultSet = preparedStatement.executeQuery();
            List<String> list = new ArrayList<String>();
            while (resultSet.next()) {
                list.add(resultSet.getString(1));
            }
            System.out.println(Arrays.toString(list.toArray()));
            int i = 2;
            if (fileNameExists(fileName, list)) {
                System.out.println(fileName);
                String temp_file_name = fileName;
                int dot_index = temp_file_name.lastIndexOf('.');
                if (dot_index == -1) {
                    String tempname = temp_file_name;
                    do {
                        temp_file_name = tempname + " (" + String.valueOf(i) + ")";
                        i++;
                        System.out.println(temp_file_name);
                    } while (fileNameExists(temp_file_name, list));
                    return temp_file_name;
                }
                String name_before_dot = fileName.substring(0, dot_index);
                String file_extension = fileName.substring(dot_index);
                System.out.println("name_before_dot: " + name_before_dot);
                System.out.println("file_extension: " + file_extension);
                do {
                    temp_file_name = name_before_dot + " (" + String.valueOf(i) + ")" + file_extension;
                    i++;

                } while (fileNameExists(temp_file_name, list));
                System.out.println("final name: " + temp_file_name);
                return temp_file_name;
            }

        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return fileName;
    }

    public static boolean fileNameExists(String search, List<String> list) {

        for (String str : list) {
            if (str.contains(search)) {
                return true;
            }
        }

        return false;
    }

    public static void insert_send_email(String email, String ip, String str) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "";
        if (str.equals("password")) {
            sql_query = "INSERT INTO email_ip_forgot_password (ip, email, time) VALUES (?, ?, NOW())";
        }
        else if (str.equals("restore")) {
            sql_query = "INSERT INTO email_ip_restore_account (ip, email, time) VALUES (?, ?, NOW())";
        }
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            preparedStatement.setString(2, email);
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
    }

    public static boolean can_send_email(String email, String ip, String str) {


        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            String sql_query = "";
            if (str.equals("password")) {
                sql_query = "SELECT COUNT(*) FROM email_ip_forgot_password WHERE TIME > NOW() - INTERVAL 1 DAY AND ip=?";
            }
            else if (str.equals("restore")) {
                sql_query = "SELECT COUNT(*) FROM email_ip_restore_account WHERE TIME > NOW() - INTERVAL 1 DAY AND ip=?";
            }
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, ip);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                if (Integer.parseInt(resultSet.getString(1)) > 15) {
                    return false;
                }
                else {
                    if (str.equals("password")) {
                        sql_query = "SELECT COUNT(*) FROM email_ip_forgot_password WHERE TIME > NOW() - INTERVAL 2 HOUR AND email = ?";
                    }
                    else if (str.equals("restore")) {
                        sql_query = "SELECT COUNT(*) FROM email_ip_restore_account WHERE TIME > NOW() - INTERVAL 2 HOUR AND email = ?";
                    }
                    preparedStatement = connection.prepareStatement(sql_query);
                    preparedStatement.setString(1, email);
                    resultSet = preparedStatement.executeQuery();
                    resultSet.next();
                    if (Integer.parseInt(resultSet.getString(1)) >= 7) {
                        return false;
                    }
                }
            }

        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return true;
    }

    static String get_email_with_password_reset_code(String password_reset_code) {
        String sql_query = "SELECT email FROM users WHERE password_reset_code=?";

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, password_reset_code);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


        return null;
    }
   static String get_salt_with_password_reset_code(String password_reset_code) {
        String sql_query = "SELECT salt FROM users WHERE password_reset_code=?";

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, password_reset_code);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }


        return null;
    }
    public static boolean link_valid(String email, String str) {
        String sql_query = "";
        if (str.equals("password")) {
            sql_query = "SELECT email FROM email_ip_forgot_password WHERE time > NOW() - INTERVAL 5 MINUTE AND email = ?";
        }
        else if (str.equals("restore")) {
            sql_query = "SELECT email FROM email_ip_restore_account WHERE time > NOW() - INTERVAL 5 MINUTE AND email = ?";
        }
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }
    public static boolean link_valid_password(String email, String password_reset_code) {
        String sql_query = "SELECT email FROM users WHERE password_reset_code=? AND email = ?";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, password_reset_code);
            preparedStatement.setString(2, email);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return true;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return false;
    }

    public static String change_password_reset_code(String password_reset_code) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        String new_code = Functions.get_code("password_reset_code");
        try {
            String sql_query = "UPDATE users SET password_reset_code = ? WHERE password_reset_code=?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, new_code);
            preparedStatement.setString(2, password_reset_code);
            preparedStatement.executeUpdate();


        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return new_code;

    }


    public static void ip_not_valid(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        Cookie verification_code_cookie = new Cookie("token", null);
        verification_code_cookie.setMaxAge(0);
        response.addCookie(verification_code_cookie);
        Functions.set_not_verified((String) request.getAttribute("email"));
        String new_code = Functions.get_code("verification_code");
        Functions.update_verification_code((String) request.getAttribute("email"), new_code);
        Functions.update_token(Functions.get_token_with_email((String) request.getAttribute("email")));
        out.print("<!doctype html>\n" +
                "\n" +
                "<html lang=\"en\">\n" +
                "<head>\n" +
                "    <title>● Login from new location</title>\n" +
                "    <link rel=\"icon\" type=\"image/png\" href=\"logo.png\">\n" +
                "    <link rel=\"stylesheet\" href=\"styles/svg_animation.css\"/>\n" +
                "    <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js\"></script>\n" +
                "    <script src=\"https://unpkg.com/tilt.js@1.2.1/dest/tilt.jquery.min.js\"></script>\n" +
                "\n" +
                "    <style>\n" +
                "        * {\n" +
                "            font-family: Arial, Helvetica, sans-serif;\n" +
                "            background: rgb(33, 37, 41);\n" +
                "            color: #007bff !important;\n" +
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
                "    <div class=\"standup_animation\" style=\"margin: 0 auto; text-align: center;  width: 50%;\">\n" +
                "        <h1 style=\"margin-top: 5px;font-weight: bold;\">\n" +
                "            You tried to log in with a different IP address, please enter the link in your email to verify your account.\n" +
                "        </h1>\n" +
                "    </div>\n" +
                "\n" +
                "    <div id=\"sign_div\" style=\"height: 28rem;width: 50rem; margin: 9rem auto auto;\">\n" +
                "        <svg\n" +
                "                id=\"sign_element\"\n" +
                "                width=\"915\"\n" +
                "                height=\"353\"\n" +
                "                viewBox=\"0 0 915 353\"\n" +
                "                fill=\"none\"\n" +
                "                xmlns=\"http://www.w3.org/2000/svg\"\n" +
                "        >\n" +
                "            <g clip-path=\"url(#clip0)\">\n" +
                "                <g filter=\"url(#filter0_d)\">\n" +
                "                    <path\n" +
                "                            id=\"path\"\n" +
                "                            d=\"M179.191 12C159.458 16.9373 141.334 25.5579 123.066 34.4012C92.4225 49.2362 62.3306 65.3793 33.8677 84.1075C29.2562 87.1419 5.27702 99.4617 8.25519 108.403C9.37543 111.767 13.2491 114.119 15.9389 115.982C25.0368 122.285 34.8531 127.528 44.5582 132.81C71.1892 147.304 98.9407 160.353 124.012 177.502C140.854 189.021 159.5 203.355 166.496 223.419C174.705 246.961 169.173 274.57 151.519 292.239C132.2 311.572 100.538 320.09 74.6807 325.841C66.11 327.746 57.4583 329.35 48.7898 330.745C44.5549 331.426 47.7268 331.935 50.3488 331.97C77.5948 332.338 104.492 336.881 131.753 336.985C167.392 337.122 202.974 336.516 238.601 335.926C253.899 335.673 269.113 334.046 284.425 333.976C295.704 333.924 307.087 334.48 318.334 333.475C322.681 333.087 326.961 333.135 331.308 332.973C333.747 332.883 330.964 329.83 330.528 328.738C324.017 312.449 321.41 294.455 319.726 277.137C317.978 259.151 317.972 240.722 319.113 222.695C320.488 201.001 321.255 179.628 321.564 157.886C322.207 112.435 323.011 169.979 323.011 125.344C321.007 112.304 323.011 64.994 323.011 78.7023C323.011 100.899 321.508 106.546 321.508 128.743C321.508 136.943 321.644 161.63 321.644 153.429C321.644 143.604 325.535 131.568 331.753 124.341C356.206 95.9199 398.637 113.554 423.234 131.92C487.392 179.822 498.935 257.776 487.878 332.472C486.828 339.566 484.958 342.728 493.39 341.555C506.757 339.698 521.397 341.555 534.203 341.555C554.471 339.995 575.573 338.379 595.618 336.985C616.665 336.985 638.658 335.982 659.872 332.973C667.116 332.973 673.235 332.973 681.531 332.973C686.264 332.973 691.387 331.07 694.783 331.07C696.328 331.07 691.268 330.933 690.83 328.961C685.457 304.766 687.322 276.862 687.322 252.228C687.322 218.202 691.331 187.425 691.331 153.429C691.331 148.171 688.324 153.429 683.814 150.531C681.195 150.531 679.907 146.542 678.302 144.179C676.184 141.061 674.794 135.374 675.796 131.362C678.302 126.347 680.306 122.823 689.326 122.335C707.868 121.332 707.366 147.912 695.841 149.918C694.337 151.534 693.574 153.166 692.333 151.924C691.4 150.99 690.259 150.991 689.326 151.924C687.318 153.935 691.182 162.244 691.888 164.964C695.917 180.517 694.337 197.42 694.337 213.389C694.337 249.853 689.326 285.976 689.326 322.497C689.326 324.069 688.176 330.89 690.272 330.967C697.211 331.224 703.43 330.967 710.373 330.967C741.757 330.967 774.2 328.961 805.585 328.961C820.544 328.961 835.504 328.961 850.463 328.961C856.478 328.961 854.567 320.376 854.75 315.81C855.054 308.201 856.917 300.772 857.478 293.186C858.215 283.224 858.589 273.231 859.204 263.262C861.086 232.75 861.593 201.823 861.71 171.261C861.758 158.725 861.095 146.037 862.211 133.536C862.494 130.362 860.82 121.625 862.935 124.007C864.531 125.804 863.714 130.3 863.714 132.421C863.714 137.901 863.714 143.379 863.714 148.859C863.714 167.163 861.71 185.347 861.71 203.581C861.71 210.194 861.71 216.806 861.71 223.419C861.71 224.605 861.71 219.094 861.71 218.404C861.71 210.732 863.402 203.79 867.278 197.117C873.093 187.106 879.817 178.38 891.777 176.053C897.271 174.984 901.756 176.499 906.81 176.499\"\n" +
                "                            stroke=\"white\"\n" +
                "                            stroke-width=\"15\"\n" +
                "                            stroke-linecap=\"round\"\n" +
                "                            stroke-linejoin=\"round\"></path>\n" +
                "                </g>\n" +
                "            </g>\n" +
                "            <defs>\n" +
                "                <filter\n" +
                "                        id=\"filter0_d\"\n" +
                "                        x=\"-3.51056\"\n" +
                "                        y=\"4.49823\"\n" +
                "                        width=\"921.821\"\n" +
                "                        height=\"352.796\"\n" +
                "                        filterUnits=\"userSpaceOnUse\"\n" +
                "                        color-interpolation-filters=\"sRGB\"\n" +
                "                >\n" +
                "                    <feFlood flood-opacity=\"0\" result=\"BackgroundImageFix\"></feFlood>\n" +
                "                    <feColorMatrix\n" +
                "                            in=\"SourceAlpha\"\n" +
                "                            type=\"matrix\"\n" +
                "                            values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0\"></feColorMatrix>\n" +
                "                    <feOffset dy=\"4\"></feOffset>\n" +
                "                    <feGaussianBlur stdDeviation=\"2\"></feGaussianBlur>\n" +
                "                    <feColorMatrix\n" +
                "                            type=\"matrix\"\n" +
                "                            values=\"0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0\"></feColorMatrix>\n" +
                "                    <feBlend\n" +
                "                            mode=\"normal\"\n" +
                "                            in2=\"BackgroundImageFix\"\n" +
                "                            result=\"effect1_dropShadow\"></feBlend>\n" +
                "                    <feBlend\n" +
                "                            mode=\"normal\"\n" +
                "                            in=\"SourceGraphic\"\n" +
                "                            in2=\"effect1_dropShadow\"\n" +
                "                            result=\"shape\"></feBlend>\n" +
                "                </filter>\n" +
                "                <clipPath id=\"clip0\">\n" +
                "                    <rect width=\"915\" height=\"353\" fill=\"white\"></rect>\n" +
                "                </clipPath>\n" +
                "            </defs>\n" +
                "        </svg>\n" +
                "    </div>\n" +
                "    <script>\n" +
                "      let my_path = document.getElementById(\"path\")\n" +
                "      let sign_element = document.getElementById(\"sign_element\")\n" +
                "      sign_element.addEventListener(\n" +
                "          \"mouseover\",\n" +
                "          function() {\n" +
                "            sign_element.setAttribute(\"data-sign-element-was-hovered\", \"true\")\n" +
                "          },\n" +
                "          false,\n" +
                "      )\n" +
                "      my_path.addEventListener(\n" +
                "          \"mouseover\",\n" +
                "          function() {\n" +
                "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                "                \"paused\"\n" +
                "          },\n" +
                "          false,\n" +
                "      )\n" +
                "      my_path.addEventListener(\n" +
                "          \"mouseout\",\n" +
                "          function() {\n" +
                "            document.getElementById(\"sign_element\").style.animationPlayState =\n" +
                "                \"running\"\n" +
                "          },\n" +
                "          false,\n" +
                "      )\n" +
                "      $(\"svg\").tilt({\n" +
                "        perspective: 550,\n" +
                "        speed: 2500,\n" +
                "      })\n" +
                "    </script>\n" +
                "</body>\n" +
                "</html>");
        Runtime.getRuntime().exec("cmd /c PYTHON_PATH\\python.exe \"final_website\\src\\main\\webapp\\python_scripts\\verify_email.py\" " + '"' + request.getAttribute("username") + '"' + " " + request.getAttribute("email") + " " + '"' + request.getServerName() + "/email-verification?verificationCode=" + new_code + "&email=" + request.getAttribute("email") + '"');
        Cookie cookie = new Cookie("verified", null);
        cookie.setMaxAge(0);
        response.addCookie(cookie);
    }


    public static String get_username_from_token(String token) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);

            String sql = "SELECT user_name FROM users WHERE token=?";
            statement = connection.prepareStatement(sql);
            statement.setString(1, token);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, statement, resultSet);
        }

        return null;
    }


    static String get_old_photo_name(String username) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);

            String sql = "SELECT profile_picture_name FROM users WHERE user_name=?";
            statement = connection.prepareStatement(sql);
            statement.setString(1, username);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String profile_picture_name = resultSet.getString(1);
                if (!profile_picture_name.contains("logo"))
                    return profile_picture_name;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, statement, resultSet);
        }

        return null;
    }

    public static void update_user_profile_picture_name(String username, String profile_picture_name) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";

        try {
            String sql_query = "UPDATE users SET profile_picture_name=? WHERE user_name = ?";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, profile_picture_name);
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

    public static boolean can_delete_profile_picture(String username) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);

            String sql = "SELECT COUNT(*) FROM profile_pictures WHERE profile_picture_name = (SELECT profile_picture_name FROM users WHERE user_name = ?)";
            statement = connection.prepareStatement(sql);
            statement.setString(1, username);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return Integer.parseInt(resultSet.getString(1)) == 1;
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

    public static void delete_old_photo(String username) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String url = "jdbc:mysql://localhost:3306/login_website";
        String sql_user = "USER";
        String sql_pass = "YOUR_PASSWORD";

        try {
            String sql_query = "DELETE FROM profile_pictures WHERE profile_picture_name=?;";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, get_old_photo_name(username));
            preparedStatement.executeUpdate();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            Functions.close_sql_connection(connection, preparedStatement, null);
        }


    }

 static String get_user_like_type(String username, String id) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        String sql_query = "SELECT type FROM comment_likes WHERE id=? and username=?";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, sql_user, sql_pass);
            preparedStatement = connection.prepareStatement(sql_query);
            preparedStatement.setString(1, id);
            preparedStatement.setString(2, username);
            resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString(1);

            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            Functions.close_sql_connection(connection, preparedStatement, resultSet);
        }
        return null;
    }
    public static boolean is_nsfw(BufferedImage image, String file_extension) throws IOException {
        File file = new File(org.apache.commons.codec.digest.DigestUtils.sha512Hex(String.valueOf(image)) + "." + file_extension);
        ImageIO.write(image, file_extension, file);
        System.out.println("temp image created");
        OkHttpClient client = new OkHttpClient();
        MediaType MEDIA_TYPE = MediaType.parse("image/" + file_extension);


        RequestBody requestBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("modelId", "1db47912-88dc-4f09-8075-210202a2bf49")
                .addFormDataPart("file", "test." + file_extension, RequestBody.create(file, MEDIA_TYPE))
                .build();

        Request request = new Request.Builder()
                .url("https://app.nanonets.com/api/v2/ImageCategorization/LabelFile/")
                .post(requestBody)
                .addHeader("Authorization", Credentials.basic("YOUR_API_KEY", ""))
                .build();

        Response response = client.newCall(request).execute();
        System.out.println(response);
        JSONObject jsonObj = new JSONObject(Objects.requireNonNull(response.body()).string());
        JSONArray arrObj = jsonObj.getJSONArray("result");
        JSONArray arrObj3 = arrObj.getJSONObject(0).getJSONArray("prediction");
        System.out.println(arrObj3.getJSONObject(0).get("label") + ": " + arrObj3.getJSONObject(0).get("probability"));
        System.out.println(arrObj3.getJSONObject(1).get("label") + ": " + arrObj3.getJSONObject(1).get("probability"));
        file.delete();
        System.out.println("temp image deleted");
        return arrObj3.getJSONObject(0).get("label").equals("nsfw");
    }

    public static void close_sql_connection(Connection connection, PreparedStatement preparedStatement, ResultSet result) {
        if (result != null) {
            try {
                result.close();
            }
            catch (SQLException e) {
            }
        }
        if (preparedStatement != null) {
            try {
                preparedStatement.close();
            }
            catch (SQLException e) {
            }
        }
        if (connection != null) {
            try {
                connection.close();
            }
            catch (SQLException e) {
            }
        }
    }
}